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
Can run on Linu on bare-metal Intel based hardware or Nitro-based EC2 instance like i3.metal.
...

If you want to hear more about what it took to enhance OSv to make it **boot in 5ms** on Firecracker, please read remaining part of this article. In the next paragraph I will describe the implementation strategy I arrived at. In the following three paragraphs I will focus on what I had to change in relevant areas - .... Finally I will describe what the outcome of this exercise is and what possible things we could improve and benefit from in future are.

## Implementation Strategy

OSv implements virtio drivers and is very well supported on QEMU/KVM. Given Firecracker is based on [KVM](https://www.kernel.org/doc/ols/2007/ols2007v1-pages-225-230.pdf) and implements virtio drivers, at first it seamed OSv might boot and run on it out of the box with some small modifications. As first experiments and more resarch showed the task in reality was not as trivial. The initial attempts to boot OSv on Firecracker caused KVM exit and OSv did not even print its first status boot message.

For starters do we even understand which OSv artifact to use as an argument of  **/boot-source** API call? It cannot be usr.img or its derivative used with QEMU as Firecracker expects 64-bit ELF (Executable and Linking Format) vmlinux kernel. The closest to it in OSv-land is loader.elf which even though is a 64-bit ELF file it has 32-bit entry point start32. Finally given there is no debugger you can connect with how do you even start figuring out where stuff breaks?

It became clear to me that I should focus first on making OSv boot on Firecracker without any block and networking device. Luckily OSv can boot of RAMFS image ... 

Write more about virtio mmio - not the same as what OSv implemented - give hint it will be harder than what I thought

Finally ACPI

Plan:
* Make OSv boot without ...
* Enhance OSv to support 
* ACPI ...

## Booting

In order to make OSv boot on Firecracker first we need to understand how current OSv booting process works.

Originally OSv has been designed to boot in 16-bit mode (aka **real mode**) and expects hypervisor to load MBR (Master Boot Record) which is first 512 bytes of OSv image at address 0x7c00 and execute it by jumping to that address. A this point OSv bootloader ([code](https://github.com/cloudius-systems/osv/blob/master/arch/x64/boot16.S) in these 512 bytes) loads command line found in next 63.5 KB of the image using interrupt 13. Then it loads remaining part of the image which is lzloader.elf (loader.elf and decompression logic) at address 0x100000 in 32KB chunks using interrupt 13 and switching back and forth between real and protected mode. Then it reads size of available RAM using e820 other interrupt. Eventually it jumps to [the code in the beginning of 1st MB that decompresses](https://github.com/cloudius-systems/osv/blob/c8395118cb580f2395cac6c53999feb217fd2c2f/fastlz/lzloader.cc#L30-L79) lzloader.elf in 1MB chunks starting from the tail and going backwards. Eventually after loader.elf is placed in memory at the adress 0x200000 (2nd MB), logic in boot16.S switches to **protected mode** and jumps to start32 to prepare to switch to **long mode** (64-bit). Please note that start32 is a 32-bit entry point of otherwise 64-bit loader.elf. For more details please read [this Wiki]().

[Describe firecracker Linux]
[review] Firecracker on other hand expects image to be a vmlinux 64-bit ELF file and loads it in RAM at address specified by ELF header field ???. Firecracker also sets VM state which means all relevant registers to 64-bit mode per what Linux expects (function ??? from readelf) including paging. [What is paging and why important?] As you can see firecracker bypasses both 16- and 32-bit mode and passes command line and e820 memory info at zero page. 

So the challenge is - how do we modify booting logic to support booting OSv as 64-bit vmlinux format ELF and at the same time retain ability to boot in real mode using traditional usr.img image file. For sure we need to replace current 32-bit entry point **start32** of loader.elf with a 64-bit one - **vmlinux_entry64** - that will be called by Firecracker (which will also load loader.elf in memory at 0x200000 as ELF header demands). At the same time we also need to change memory placement of start32 to be at some fixed offset so that boot16.S knows where to jump to. 

So what exactly new vmlinux_entry64 should do? Firecracker sets up VMs to 64-bit state but OSv already provided 64-bit [start64](https://github.com/cloudius-systems/osv/blob/c8395118cb580f2395cac6c53999feb217fd2c2f/arch/x64/boot.S#L100-L119) function so one could ask - why not simply jump to it and be done with it?. Unfortunately this would not work (as I tested) because of different mamory paging and CPU setup between what Linux and OSv expects (and Firecracker sets up for Linux). So possibly vmlinux_entry64 needs to reset memory pagig and CPU the OSv way? Alteratively vmlinux_entry64 could switch back to protected and jump to start32 and let it setup VM OSv way. I tried that as well but it did not work for some reason.

---> 
Luckily the segmentation (explain - typically in long mode it is setup as *flat memory model*) is setup same way.

At the end based on many trial-and-error attempts I came to conclusion that vmlinux_entry64 should do following:
1. Extract command line and memory information from Linux boot_params structure whose address is passed in by Firecracker in RSI register and copy to another place structured same way as if OSv booted through boot16.S (please see [extract_linux_boot_params](https://github.com/cloudius-systems/osv/blob/c8395118cb580f2395cac6c53999feb217fd2c2f/arch/x64/vmlinux.cc#L41-L93) for details).
2. Reset CR0 and CR4 control registers to reset global CPU feaures OSv way (-> refer to some wiki for control registered explanation).
3. Reset CR3 register to point to OSv PML4 table mapping first 1GB of memory with 2BM medium size pages one-to-one (refer ->).
4. Finally jump to start64 to complete boot process and start OSv.
 
The code below is slightly modified version of [vmlinux_entry64 in vmlinux-boot64.S](https://github.com/cloudius-systems/osv/blob/master/arch/x64/vmlinux-boot64.S) that implemennts the steps described above.

```asm
# The address of boot_params struct is passed in RSI
# register so pass it to extract_linux_boot_params fuction
# which will extract cmdline and memory information and verify
# that loader.elf was indeed called as Linux 64-bit vmlinux ELF
mov %rsi, %rdi
call extract_linux_boot_params

# Even though we are in 64-bit long mode we need to reset
# page tables and other CPU settings the way OSv expects it
mov $BOOT_CR4, %rax
mov %rax, %cr4

lea ident_pt_l4, %rax
mov %rax, %cr3

# Enable long mode by writing to EFER register (look at https://wiki.osdev.org/Model_Specific_Registers)
# Use wrmsr instruction to write value 0x00000900 [placed in register EAX] (b1001 0000 0000, bits 8:LME (Long Mode Enable) and 11:NXE (No-Execute Enable) set)
# to register EFER indexed by ECX register value 0xc0000080
mov $0xc0000080, %ecx
mov $0x00000900, %eax
xor %edx, %edx
wrmsr

mov $BOOT_CR0, %rax
mov %rax, %cr0

# Join common 64-bit boot logic by jumping to start64 label
mov $OSV_KERNEL_BASE, %rbp
mov $0x1000, %rbx
jmp start64
```
As you can see making OSv boot on Firecracker was the most tricky part of whole exercise.

## Virtio
Unlike booting process enhancing virtio layer in OSv was not as tricky and hard to debug, but it was most labor itennsive and required a lot of research (reading the spec and Linux code as an example)

Before diving in let us first get a glimpse of VirtIO and its purpose. [VirtIO specification](http://docs.oasis-open.org/virtio/virtio/v1.0/virtio-v1.0.html) defines standard virtual (sometimes called paravirtual) devices including networking, block, scsi ones. It effectively dictates how hypervisor (host) should expose those devices as well as how guest should detect, configure and interact with them in runtime in form of a driver. The objective is to define devices that can operate in most efficient way and minimize number of costly (performance wise) exits from guest to host.

--> Most differences between PCI modern and legacy is the initialization and configuration phase. Special register for configuration.

Firecracker implements virtio mmio block and net devices. The mmio (memory-mapped IO) is one of three VirtIO transport layers (MMIO, PCI, CCW) and was modeled after PCI and differs mainly in how mmio devices are cofigured and initialized. Unfortunately to my dispair OSv only implemented PCI transport and was missing mmio implementation. On top of that to make things worse it implemented the legacy (pre 1.0) version of virtio before it was finalized in 2016. So two things had to be done - refactor OSv virtio layer to support both legacy and modern PCI devices and implement virtio mmio. 

In order to design and implement correct changes first I had to understand existing implementation of virtio layer. OSv has two orthogonal but related abstraction layers in this matter - driver and device classes. The [virtio::virtio_driver](https://github.com/cloudius-systems/osv/blob/25209d81f7b872111beb02ab9758f0d86898ec6b/drivers/virtio.hh) serves as a base class with common driver logic and is extended by [virtio::blk](https://github.com/cloudius-systems/osv/blob/25209d81f7b872111beb02ab9758f0d86898ec6b/drivers/virtio-blk.hh), [virtio::net](https://github.com/cloudius-systems/osv/blob/25209d81f7b872111beb02ab9758f0d86898ec6b/drivers/virtio-net.hh), [virtio::scsi](https://github.com/cloudius-systems/osv/blob/25209d81f7b872111beb02ab9758f0d86898ec6b/drivers/virtio-scsi.hh) and [virtio::rng](https://github.com/cloudius-systems/osv/blob/25209d81f7b872111beb02ab9758f0d86898ec6b/drivers/virtio-rng.hh) classes to provide implementations for relevant type. For better illustration please look at this ascii art:

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


....

As you can tell from the graphics above virtio_driver interacts directly with [pci::device](https://github.com/cloudius-systems/osv/blob/25209d81f7b872111beb02ab9758f0d86898ec6b/drivers/pci-device.hh) so in order to add support of MMIO devices I had to refactor it to make it transport agnostic. From all the options I took into consideration the least invasive and most flexible one involved crearing new abstraction - virtio_device - to model virtio device. To that end I ended up heavily refactoring virtio_driver class and defining following new classes:

* [virtio::virtio_device](https://github.com/cloudius-systems/osv/blob/12b39c686a18813f3ee9760732ade41be94c2aa2/drivers/virtio-device.hh) - abstract class to model interface of virtio device intended to be used by refactored [virtio::virtio_driver](https://github.com/cloudius-systems/osv/blob/12b39c686a18813f3ee9760732ade41be94c2aa2/drivers/virtio.hh)
* [virtio::virtio_pci_device](https://github.com/cloudius-systems/osv/blob/12b39c686a18813f3ee9760732ade41be94c2aa2/drivers/virtio-pci-device.hh#L65-L93) - base class with common logic for virtio PCI devices
* [virtio::virtio_legacy_pci_device](https://github.com/cloudius-systems/osv/blob/12b39c686a18813f3ee9760732ade41be94c2aa2/drivers/virtio-pci-device.hh#L95-L135) - class implementing legacy PCI device
* [virtio::virtio_modern_pci_device](https://github.com/cloudius-systems/osv/blob/12b39c686a18813f3ee9760732ade41be94c2aa2/drivers/virtio-pci-device.hh#L198-L288) - class implementing modern PCI device
* [virtio::mmio_device](https://github.com/cloudius-systems/osv/blob/12b39c686a18813f3ee9760732ade41be94c2aa2/drivers/virtio-mmio.hh) - class implementing mmio device

For better illustration of the changes and relationship between new and old classes please see ascii-art UML-like class diagram below:
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

The benefit of using composition between virtio_pci_device and pci_device ..
virtio_device class method is_modern() is used only in one place during initialization to skip step 5 & 6 for legacy.

Important: why bother implementing modern pci device? Becuase we can then test most logic handling modern virtio device as Firecracker mmio is a modern one. Also because presumabely it will be easier to support [VirtIO 1.1 spec](https://docs.oasis-open.org/virtio/virtio/v1.1/csprd01/virtio-v1.1-csprd01.html) once finalized (for good overview see [here](https://archive.fosdem.org/2018/schedule/event/virtio/attachments/slides/2167/export/events/attachments/virtio/slides/2167/fosdem_virtio1_1.pdf)).

Ascii art to show old and new class hierarchies and dependencies between driver and device including all virtio_driver subclasses.  
As you can guess virtio_driver also implements virtio device logic which we need to extract as a seperate abstraction.


Composition to link to a pci_device and delegate to it in many cases. 

Mention how virtio mmio devices are passed in command line and how OSv parses them out to probe for the devices. Also mention optimization to skip PCI enumeration by passing special flag - saves 4 ms.

## ACPI

The last and simplest part of the exercise was to fill in the gaps in OSv to make it deal with situation when ACPI (link what it is) is missing.

Firecracker does not implement ACPI which is used by OSv to implement power handling and to discover CPUs. Instead OSv had to be changed to boot without ACPI and read CPU info from MP table … 
* modify OSv to detect if ACPI present
* in relevant places (CPU detection, power off) instead of aborting if ACPI not present simply continue and provide alternative solution
* pvpanic is probed -> no problem
* needs to extract info from MP table -> couple of places in memory to try to read from
* power off -> alternative way

## Epilogue 

Tell what was most critical (boot) ad most labor intesive (virtio).

Show bootchart and talk about possible improvements:
* boot time (hard to shave off 5ms) -> possibly smaller loader.elf
* less memory (now 18MB)
* study performance -> block device faster, but network slower than with QEMU -> look if some major optimizations missing in vring due to modern<->legacy

Mention that Firecracker team is working on ARM version. And OSv already has partial support for arm. Anyone interested to make it boot.

Metion this work should hopefully make it easies to boot on NEMU ad QEMU 4.0 with direct boot. Possibly easier to implement Virtio 1.1.

Finally list of patches chronologically.
