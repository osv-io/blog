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

If you want to hear more about what it took to enhance OSv to make it **boot in 5ms** on Firecracker, please read remaining part of this article. In the next paragraph I will describe the implementation strategy I arrived at. In the following three paragraphs I will focus on what I had to change in relevant areas - .... Finally I will describe epology

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

In order ... we have to understand how current OSv process works.

OSv has been originally designed to boot in 16-bit mode (aka real mode) and expects hypervisor to load MBR (Master Boot Record) which is first 512 bytes of OSv image at address 0x7c00 and execute it by jumping to that address. A this point OSv bootloader (code in these 512 bytes) loads command line found in next 63.5 KB of image using interrupt 13. Then it loads remaining part of the image which is lzloader.elf (loader.elf and decompression logic) at address 0x100000 in 32KB chunks using interrupt 13 and switching back and forth between real and protected mode. Then it reads size of available RAM using e820 other interrupt. Eventually jumps to the code in the beginning of 1st MB that decompresses lzloader.elf in 1MB chunks starting from the tail and going backwards. Eventually it switches to protected mode and jumps to start32 which will take care of preparing to switch to long mode (64-bit).

[Describe firecracker Linux]
Firecracker on other hand expects image to be a vmlinux 64-bit ELF file and loads it in RAM at address specified by ELF header field ???. Firecracker also sets VM state which means all relevant registers to 64-bit mode per what Linux expects (function ??? from readelf) including paging. [What is paging and why important?] As you can see firecracker bypasses both 16- and 32-bit mode and passes command line and e820 memory info at zero page. 

In high level and naively simply bypass 16 and 32 stage and jump to OSv start64. The problem is that would not work because of different paging and CPU setup. It just happens that segmentation is the same and also does not matter in long mode (1:1).

->> talk about Firecracker loading loader.elf at 0x200000. 
 
So somehow we need to make OSv also look like vmlinux and read passed in cmdline and memory information and continue in 64 bit more, but also set CPU settings including paging to the way OSv expects. One way would be to switch back to protected and jump to OSv start32 and let it set machine OSv way. Another is to tweak only necessary control registers - c0, cr3 and cr4

Steps:
Make loader.elf start address be 64 bit code (now is 32 bit) -> support 2 entry points
Reset paging the OSv way -> cr4, cr3 (root table) and cr0 registers are critical (control registers that control and change general behavior of CPU)
* cr0 - 31-st bit enables paging 
* cr3 - sets address of hierarchical paging directory
* cr4 - controls protected mode settings including enabling PAE
* reference https://github.com/cloudius-systems/osv/blob/master/arch/x64/vmlinux-boot64.S - vmlinux_entry64

```asm
vmlinux_entry64:
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

Bolek
In order boot Linux kernel firecracker loads the vmlinux 64-bit ELF file, inspects its headers and based on one of the parameters (maybe name it?) copies ELF content (segments or sections?) into memory at 0x200000 address. In order to make 

## Virtio
Brief introduction to VirtIO

Firecracker implements mmio flavor of virtio which was modeled after PCI in behavior but different configuration. OSv was missing mmio implementation but what was worse it implemented legacy version (pre 1.0) of virtio. So two things had to be done - refactor OSv virtio layer to support both legacy and modern PCI devices and implement virtio mmio:
* Virtio device interface class
* Virtio pci modern and legacy device class
* Delegate to normal pci device
* Virtio mmio device class

Most differences between PCI modern and legacy is the initialization and configuration phase. Special register for configuration.

OSv has two orthogonal but related layers of abstraction in this matter - driver and device interface class. The virtio_driver is a generalization and virtio::blk, virtio::net,  are specializations for each type of virtio driver. Unfortunately virtio_driver implementation tied it to a pci::device class so in order to now support mmio device we had to refactor it. There were two options - somehow use multiple inheritance to ??? or introduce virtio_device class to represent transport layer and make virtio_driver to talk to it. First option would have big ripple efffect and nasty ...

OR: we have two problems - virtio_driver is tied to pci::device and virtio_driver implements legacy interface vs modern per virtio spec. 

virtio_device class method is_modern() is used only in one place during initialization to skip step 5 & 6 for legacy.

Important: why bother implementing modern pci device? Becuase we can then test most logic handling modern virtio device as Firecracker mmio is a modern one. Also because presumabely it will be easier to support [VirtIO 1.1 spec](https://docs.oasis-open.org/virtio/virtio/v1.1/csprd01/virtio-v1.1-csprd01.html) once finalized (for good overview see [here](https://archive.fosdem.org/2018/schedule/event/virtio/attachments/slides/2167/export/events/attachments/virtio/slides/2167/fosdem_virtio1_1.pdf)).

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

Tell what was most critical (boot) ad most labor intesive (virtio).

Mention that Firecracker team is working on ARM version. And OSv already has partial support for arm. Anyone interested to make it boot.
