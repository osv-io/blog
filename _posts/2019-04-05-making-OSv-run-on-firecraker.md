---
layout: post
title: "Making OSv Run on Firecracker"
date: 2019-04-05 06:00:00 -0800
comments: true
published: true
---

**By: Waldek Kozaczuk**

## Firecracker

[Firecracker](https://firecracker-microvm.github.io/) is a new light KVM-based hypervisor written in Rust and announced during last AWS re:Invent in 2018.

...
Starts in 5ms, 2MB image, speed Linux in 125 ms
Describe what firecracker is in terms of KVM and emulated paravirtual devices [here?]
...

If you want to hear more about what it took to enhance OSv to make it **boot in 5ms** on Firecracker, please read remaining part of this article. In the next paragraph I will describe the implementation strategy I arrived at. In the following three paragraphs I will focus on what I had to change in relevant areas - .... Finally I will describe epology

## Implementation Strategy

OSv implements virtio drivers and is very well supported on QEMU/KVM. Given that Firecracker is based on KVM and implements virtio devices, at first it seamed OSv might boot and run on it out of the box with some small modifications. As first experiments and more resarch showed the task in reality was not as trivial. The initial attempts to boot OSv on Firecracker caused KVM exit and OSv did not even print its first status boot message.

For starters do we even understand which OSv artifact to use as an argument of  **/boot-source** API call? It cannot be usr.img or its derivative used with QEMU as Firecracker expects 64-bit ELF (Executable and Linking Format) vmlinux kernel. The closest to it in OSv-land is loader.elf which even though is a 64-bit ELF file it has 32-bit entry point start32. Finally given there is no debugger you can connect with how do you even start figuring out where stuff breaks?

## Booting
## Virtio

Firecracker implements mmio flavor of virtio which was modeled after PCI in behavior but different configuration. OSv was missing mmio implementation but what was worse it implemented legacy version (pre 1.0) of virtio. So two things had to be done - refactor OSv virtio layer to support both legacy and modern PCI devices and implement virtio mmio:
* Virtio device interface class
* Virtio pci modern and legacy device class
* Delegate to normal pci device
* Virtio mmio device class

Most differences between PCI modern and legacy is the initialization and configuration phase. Special register for configuration.

OSv has two orthogonal but related layers of abstraction in this matter - driver and device interface class. The virtio_driver is a generalization and virtio::blk, virtio::net,  are specializations for each type of virtio driver. Unfortunately virtio_driver implementation tied it to a pci::device class so in order to now support mmio device we had to refactor it. There were two options - somehow use multiple inheritance to ??? or introduce virtio_device class to represent transport layer and make virtio_driver to talk to it. First option would have big ripple efffect and nasty ...

OR: we have two problems - virtio_driver is tied to pci::device and virtio_driver implements legacy interface vs modern per virtio spec. 

virtio_device class method is_modern() is used only in one place during initialization to skip step 5 & 6 for legacy.

Important: why bother implementing modern pci device? Becuase we can then test most logic handling modern virtio device as Firecracker mmio is a modern one.

Ascii art to show old and new class hierarchies and dependencies between driver and device including all virtio_driver subclasses.  
As you can guess virtio_driver also implements virtio device logic which we need to extract as a seperate abstraction.
```

 hw_device <|---
               | 
       pci::function <|--- 
                         |
                  pci::device
                         ^                 |-- virtio::net
                  (uses) |                 |
                         |                 |-- virtio::blk
 hw_driver <|--- virtio::virtio_driver <|--|
                                           |-- virtio::scsi
                                           |
                                           |-- virtio::rng

```

Composition to link to a pci_device and delegate to it in many cases. 
Describe more what happens in this diagram.
```

               |-- pci::function <|--- pci::device
               |                              ^
               |               (delegates to) |
               |                              |        |-- virtio_legacy_pci_device
 hw_device <|--|             --- virtio_pci_device <|--|
               |             |                         |-- virtio_modern_pci_device
               |             _ 
               |             v
               |-- virtio::virtio_device <|--- virtio::mmio_device
                   ---------------------
                   | bool is_modern()  |
                   ---------------------
                             ^             |-- virtio::net
                      (uses) |             |
                             |             |-- virtio::blk
 hw_driver <|--- virtio::virtio_driver <|--|
                                           |-- virtio::scsi
                                           |
                                           |-- virtio::rng

```

## ACPI

Firecracker does not implement ACPI which is used by OSv to implement power handling and to discover CPUs. Instead OSv had to be changed to boot without ACPI and read CPU info from MP table … 
* modify OSv to detect if ACPI present
* in relevant places (CPU detection, power off) instead of aborting if ACPI not present simply continue and provide alternative solution
* pvpanic is probed -> no problem
* needs to extract info from MP table -> couple of places in memory to try to read from
* power off -> alternative way

## Epilogue 

We believe that the difficulties of running code on VMs will drive more and more application developers to look for alternatives for running their code, alternatives such as Function-as-a-Service (FaaS). We already explored this and related directions in the past in [this paper from 2013](http://nadav.harel.org.il/homepage/papers/paas-2013.pdf).

We showed in this post that it makes sense to implement FaaS on top of VMs, and that OSv is a better fit for running those VMs than either Linux or other unikernels. That is because OSv has the unique combination of allowing very fast boot and instantaneous shutdowns, at the same time as being able to run the complex runtime environments we wish to support (such as Node.js and Java).

An OSv-based implementation of FaaS will support "cloud bursting" - an unexpected, sudden, increase of load on a single application, thanks to our ability to boot many new OSv VMs very quickly. Cloud bursting is one of the important use cases being considered by the MIKELANGELO project, a European H2020 research project which the authors of this post contribute to, and which is based on OSv as we previously announced.
