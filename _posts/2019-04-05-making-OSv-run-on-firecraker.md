---
layout: post
title: "Making OSv Run on Firecracker"
date: 2019-04-05 06:00:00 -0800
comments: true
published: true
---

**By: Waldek Kozaczuk**

## Firecracker

[Firecracker](https://firecracker-microvm.github.io/) is a new light KVM-based hypervisor written in Rust and announced during last AWS re:Invent in 2018. Unlike QEMU Firecracker is specialized to host Linux guests only and is able to boot micro VMs in ~ 125 ms. Firecracker itself can only run on Linux on bare-metal machines with Intel 64-bit CPUs or i3.metal or other [Nitro-based](http://www.brendangregg.com/blog/2017-11-29/aws-ec2-virtualization-2017.html) EC2 instances.

Firecracker implements a device model with the following I/O devices:
- paravirtual VirtIO block and network devices over MMIO transport
- serial console
- partial keyboard controller
- PICs (Programmable Interrupt Controllers)
- IOAPIC (Advanced Programmable Interrupt Controller)
- PIT (Programmable Interval Timer)
- KVM clock

Firecracker also exposes REST API over UNIX domain socket and can be confined to improve security through so called *jailer*. For more details look at [the design doc](https://github.com/firecracker-microvm/firecracker/blob/master/docs/design.md) and [the specification](https://github.com/firecracker-microvm/firecracker/blob/master/SPECIFICATION.md).

If you want to hear more about what it took to enhance OSv to make it **boot in 5ms** on Firecracker, please read remaining part of this article. In the next paragraph I will describe the implementation strategy I arrived at. In the following three paragraphs I will focus on what I had to change in relevant areas - booting process, VirtIO and ACPI. Finally in the epilogue I will describe the outcome of this exercise and possible improvements we can make and benefit from in future.

If you want to try OSv on Firecracker before reading this article follow [this wiki](https://github.com/cloudius-systems/osv/wiki/Running-OSv-on-Firecracker).

## Implementation Strategy

OSv implements VirtIO drivers and is very well supported on QEMU/KVM. Given Firecracker is based on [KVM](https://www.kernel.org/doc/ols/2007/ols2007v1-pages-225-230.pdf) and exposes VirtIO devices, at first it seemed OSv might boot and run on it out of the box with some small modifications. As first experiments and more research showed, the task in reality was not as trivial. The initial attempts to boot OSv on Firecracker caused KVM exit and OSv did not even print its first boot message.

For starters I had to identify which OSv artifact to use as an argument to Firecracker **/boot-source** API call. It could not be plain **usr.img** or its derivative used with QEMU as Firecracker expects 64-bit ELF (Executable and Linking Format) vmlinux kernel. The closest to it in OSv-land is **loader.elf** (enclosed inside of usr.img) - 64-bit ELF file with 32-bit entry point **start32**. Finally given it is not possible to connect to OSv running on Firecracker with gdb (like it is possible with QEMU), I could not use this technique to figure out where stuff breaks.

It became clear to me I should first focus on making OSv boot on Firecracker without block and network devices. Luckily OSv can be built with Ram-FS where application code is placed in **bootfs** part of loader.elf. 

Then I should enhance VirtIO layer to make it support block and network devices with MMIO transport. Initially these changes seemed very reasonable to implement but they turned way more involved in the end. 

Finally I had to tweak some parts of OSv to make it work without [ACPI](https://wiki.osdev.org/ACPI) (Advanced Configuration and Power Interface) if unavailable.

Next three paragraphs describe each step of this plan in detail.

## Booting

In order to make OSv boot on Firecracker first I had to understand how current OSv booting process works.

Originally OSv had been designed to boot in 16-bit mode (aka **real mode**) when it expects hypervisor to load MBR (Master Boot Record), which is first 512 bytes of OSv image, at address 0x7c00 and execute it by jumping to that address. A this point OSv bootloader ([code](https://github.com/cloudius-systems/osv/blob/master/arch/x64/boot16.S) in these 512 bytes) loads command line found in next 63.5 KB of the image using [interrupt 0x13](https://wiki.osdev.org/ATA_in_x86_RealMode_(BIOS)#LBA_in_Extended_Mode). Then it loads remaining part of the image which is **lzloader.elf** (loader.elf + *fastlz* decompression logic) at address 0x100000 in 32KB chunks using the interrupt 0x13 and switching back and forth between real and protected mode. Next it reads the size of available RAM using [the 0x15 interrupt](http://www.uruk.org/orig-grub/mem64mb.html) and jumps to [the code in the beginning of 1st MB that de-compresses](https://github.com/cloudius-systems/osv/blob/c8395118cb580f2395cac6c53999feb217fd2c2f/fastlz/lzloader.cc#L30-L79) *lzloader.elf* in 1MB chunks starting from the tail and going backwards. Eventually after *loader.elf* is placed in memory at the address 0x200000 (2nd MB), logic in `boot16.S` switches to **protected mode** and jumps to **start32** to prepare to switch to **long mode** (64-bit). Please note that *start32* is a 32-bit entry point of otherwise 64-bit loader.elf. For more details please read [this Wiki](https://github.com/cloudius-systems/osv/wiki/OSv-early-boot-(MBR)).

Firecracker on other hand expects image to be a vmlinux 64-bit ELF file and loads its LOAD segments into RAM at addresses specified by ELF program headers. Firecracker also sets VM to long mode (aka 64-bit mode), state of relevant registers and paging tables to map virtual memory to physical one as expected by Linux. Finally it passes memory information and boot command line in the *boot_params* structure and jumps to vmlinux entry of *startup_64* to let Linux kernel continue its [booting process](https://www.kernel.org/doc/Documentation/x86/boot.txt).

So the challenge is: how do we modify booting logic to support booting OSv as 64-bit vmlinux format ELF and at the same time retain ability to boot in real mode using traditional *usr.img* image file? For sure we need to replace current 32-bit entry point **start32** of loader.elf with a 64-bit one - **vmlinux_entry64** - that will be called by Firecracker (which will also load loader.elf in memory at *0x200000* as ELF header demands). At the same time we also need to change memory placement of *start32* to be at some fixed offset so that boot16.S knows where to jump to. 

So what exactly new *vmlinux_entry64* should do? Firecracker sets up VMs to 64-bit state but OSv already provided 64-bit [start64](https://github.com/cloudius-systems/osv/blob/c8395118cb580f2395cac6c53999feb217fd2c2f/arch/x64/boot.S#L100-L119) function so one could ask - why not simply jump to it and be done with it?. Unfortunately this would not work (as I tested) because of slightly different memory paging tables and CPU setup between what Linux and OSv expects (and Firecracker sets up for Linux). So possibly *vmlinux_entry64* needs to reset paging tables and CPU the OSv way? Alternatively *vmlinux_entry64* could switch back to protected mode and jump to *start32* and let it setup VM OSv way. I tried that as well but it did not work for some reason either.

Luckily we do not need to worry about the segmentation which is setup by Firecracker to *flat memory model* which is typical in long mode and what OSv expects.

At the end based on many trial-and-error attempts I came to conclusion that *vmlinux_entry64* should do following:
1. Extract command line and memory information from Linux *boot_params* structure whose address is passed in by Firecracker in RSI register and copy to another place structured same way as if OSv booted through boot16.S (please see [extract_linux_boot_params](https://github.com/cloudius-systems/osv/blob/c8395118cb580f2395cac6c53999feb217fd2c2f/arch/x64/vmlinux.cc#L41-L93) for details).
2. Reset CR0 and CR4 [control registers](https://wiki.osdev.org/CPU_Registers_x86-64#Control_Registers) to reset global CPU features OSv way.
3. Reset CR3 register to point to OSv PML4 table mapping first 1GB of memory with 2BM medium size pages one-to-one (for more information about memory paging please read [this article](http://www.renyujie.net/articles/article_ca_x86_5.php)).
4. Finally jump to *start64* to complete boot process and start OSv.
 
The code below is slightly modified version of [vmlinux_entry64 in vmlinux-boot64.S](https://github.com/cloudius-systems/osv/blob/master/arch/x64/vmlinux-boot64.S) that implements the steps described above in GAS (GNU Assembler) language.

<pre class='prettyprint lang-gas'>
# Call extract_linux_boot_params with the address of
# boot_params struct passed in RSI register to 
# extract cmdline and memory information
mov %rsi, %rdi
call extract_linux_boot_params

# Reset paging tables and other CPU settings the way 
# OSv expects it
mov $BOOT_CR4, %rax
mov %rax, %cr4

lea ident_pt_l4, %rax
mov %rax, %cr3

# Enable long mode by writing to EFER register by setting
# LME (Long Mode Enable) and NXE (No-Execute Enable) bits
mov $0xc0000080, %ecx
mov $0x00000900, %eax
xor %edx, %edx
wrmsr

mov $BOOT_CR0, %rax
mov %rax, %cr0

# Continue 64-bit boot logic by jumping to start64 label
mov $OSV_KERNEL_BASE, %rbp
mov $0x1000, %rbx
jmp start64
</pre>
<br>
As you can see making OSv boot on Firecracker was the most tricky part of whole exercise.

## Virtio
Unlike booting process, enhancing virtio layer in OSv was not as tricky and hard to debug, but it was the most labor intensive and required a lot of research that included reading the spec and Linux code for comparison.

Before diving in, let us first get a glimpse of VirtIO and its purpose. [VirtIO specification](http://docs.oasis-open.org/virtio/virtio/v1.0/virtio-v1.0.html) defines standard virtual (sometimes called paravirtual) devices including network, block, scsi, etc ones. It effectively dictates how hypervisor (host) should expose those devices as well as how guest should detect, configure and interact with them in runtime in form of a driver. The objective is to define devices that can operate in most efficient way and minimize number of costly performance-wise exits from guest to host.

Firecracker implements virtio MMIO block and net devices. The MMIO (Memory-Mapped IO) is one of three VirtIO transport layers (MMIO, PCI, CCW) and was modeled after PCI and differs mainly in how MMIO devices are configured and initialized. Unfortunately to my despair OSv only implemented PCI transport and was missing mmio implementation. On top of that to make things worse it implemented the legacy (pre 1.0) version of virtio before it was finalized in 2016. So two things had to be done - refactor OSv virtio layer to support both legacy and modern PCI devices and implement virtio mmio. 

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
<br>
As you can tell from the graphics above, *virtio_driver* interacts directly with [pci::device](https://github.com/cloudius-systems/osv/blob/25209d81f7b872111beb02ab9758f0d86898ec6b/drivers/pci-device.hh) so in order to add support of MMIO devices I had to refactor it to make it transport agnostic. From all the options I took into consideration, the least invasive and most flexible one involved creating new abstraction to model virtio device. To that end I ended up heavily refactoring *virtio_driver* class and defining following new virtual device classes:

* [virtio::virtio_device](https://github.com/cloudius-systems/osv/blob/12b39c686a18813f3ee9760732ade41be94c2aa2/drivers/virtio-device.hh) - abstract class to model interface of virtio device intended to be used by refactored [virtio::virtio_driver](https://github.com/cloudius-systems/osv/blob/12b39c686a18813f3ee9760732ade41be94c2aa2/drivers/virtio.hh)
* [virtio::virtio_pci_device](https://github.com/cloudius-systems/osv/blob/12b39c686a18813f3ee9760732ade41be94c2aa2/drivers/virtio-pci-device.hh#L65-L93) - base class extending *virtio_device* and implementing common virtio PCI logic that delegates to *pci_device*
* [virtio::virtio_legacy_pci_device](https://github.com/cloudius-systems/osv/blob/12b39c686a18813f3ee9760732ade41be94c2aa2/drivers/virtio-pci-device.hh#L95-L135) - class extending *virtio_pci_device* and implementing legacy PCI device
* [virtio::virtio_modern_pci_device](https://github.com/cloudius-systems/osv/blob/12b39c686a18813f3ee9760732ade41be94c2aa2/drivers/virtio-pci-device.hh#L198-L288) - class extending *virtio_pci_device* implementing modern PCI device; most differences between modern and legacy PCI devices lie in the initialization and configuration phase with special configuration register
* [virtio::mmio_device](https://github.com/cloudius-systems/osv/blob/12b39c686a18813f3ee9760732ade41be94c2aa2/drivers/virtio-mmio.hh) - class extending *virtio_device* and implementing mmio device

The method **is_modern()** declared in **virtio_device** class and overridden in its subclasses is used in few places in **virtio_driver** and its subclasses to mostly drive slightly different initialization logic of legacy and modern virtio devices.

For better illustration of the changes and relationship between new and old classes please see the ascii-art UML-like class diagram below:
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
<br>
To recap most of the coding went into major refactoring of *virtio_driver* class to make it transport agnostic and delegate to *virtio_device*, extracting out PCI logic from *virtio_driver* into **virtio_pci_device** and **virtio_legacy_pci_device** and finally implementing new **virtio_modern_pci_device** and **virtio::mmio_device** classes. Thanks to this approach changes to the subclasses of *virtio_driver* (*virtio::net*, *virtio::block*, etc) were pretty minimal and one of the critical classes - [virtio::vring](https://github.com/cloudius-systems/osv/blob/12b39c686a18813f3ee9760732ade41be94c2aa2/drivers/virtio-vring.hh) - stayed pretty much intact.

Big motivation for implementing modern virtio PCI device (as opposed to implementing legacy one only) was to have a way to exercise and test modern virtio device with QEMU. That way I could have extra confidence that most heavy refactoring in *virtio_driver* was correct even before testing it with Firecracker which exposes modern MMIO device. Also there is great chance it will make easier enhancing virtio layer to support new [VirtIO 1.1 spec](https://docs.oasis-open.org/virtio/virtio/v1.1/csprd01/virtio-v1.1-csprd01.html) once finalized (for good overview see [here](https://archive.fosdem.org/2018/schedule/event/virtio/attachments/slides/2167/export/events/attachments/virtio/slides/2167/fosdem_virtio1_1.pdf)).

Lastly given that MMIO devices cannot be detected in similar fashion as PCI ones and instead are passed by Firecracker as part of command line in format Linux kernel expects, I also had to enhance OSv command line parsing logic [to extract relevant configuration bits](https://github.com/cloudius-systems/osv/blob/12b39c686a18813f3ee9760732ade41be94c2aa2/drivers/virtio-mmio.cc#L140-L214). On top of that I added boot parameter to skip PCI enumeration and that way save extra 4-5 ms of boot time.

## ACPI

The last and simplest part of the exercise was to fill in the gaps in OSv to make it deal with situation when [ACPI](http://www.acpi.info/) is unavailable.

Firecracker does not implement ACPI which is used by OSv to implement power handling and to discover CPUs. Instead OSv had to be changed to boot without ACPI and [read CPU info from MP table](https://github.com/cloudius-systems/osv/commit/47ae2b65e0428336a841d07d9add01359f523377). For more information about MP table read [here](https://wiki.osdev.org/Symmetric_Multiprocessing#Finding_information_using_MP_Table) or [there](http://www.osdever.net/tutorials/view/multiprocessing-support-for-hobby-oses-explained).
All in all I had to enhance OSv in following ways:
* modify ACPI related logic to detect if it is present
* modify relevant places (CPU detection, power off) that rely on ACPI to continue and use alternative mechanism if ACPI not present instead of aborting
* modify pvpanic probing logic to skip if ACPI not available

## Epilogue 

With all changes implemented as described above OSv can boot on Firecracker.

```
OSv v0.53.0-6-gc8395118
2019-04-17T22:28:29.467736397 [anonymous-instance:WARN:vmm/src/lib.rs:1080] Guest-boot-time =   9556 us 9 ms,  10161 CPU us 10 CPU ms
	disk read (real mode): 0.00ms, (+0.00ms)
	uncompress lzloader.elf: 0.00ms, (+0.00ms)
	TLS initialization: 1.13ms, (+1.13ms)
	.init functions: 2.08ms, (+0.94ms)
	SMP launched: 3.43ms, (+1.35ms)
	VFS initialized: 4.12ms, (+0.69ms)
	Network initialized: 4.45ms, (+0.33ms)
	pvpanic done: 5.07ms, (+0.62ms)
	drivers probe: 5.11ms, (+0.03ms)
	drivers loaded: 5.46ms, (+0.35ms)
	ROFS mounted: 5.62ms, (+0.17ms)
	Total time: 5.62ms, (+0.00ms)
Hello from C code
```
<br>
The console log with bootchart information above from an example run of OSv with Read-Only-FS on Firecracker, shows it took slightly less than 6 ms to boot. As you can notice OSv spent no time loading its image in real mode and decompressing it which is expected because OSv gets booted as ELF and these two phases completely bypassed. 

Even though 5 ms is already very low number, one can see that possibly TLS initialization and 'SMP lauched' phases need to be looked at to see if we can optimize it further. 
Other areas of interest to improve are memory utilization - OSv needs minimum of 18MB to run on Firecracker and network performance which [suffers a little comparing to QEMU/KVM](https://github.com/firecracker-microvm/firecracker/issues/1034#issue-424659555) which might need to be optimized on Firecracker itself. 

On other hand it is worth noting that block device seems to work much faster - for example mounting ZFS filesystem is at least 5 times faster on Firecracker - on average 60ms on firecracker vs 260 ms on QEMU. 

Looking toward future, Firecracker team is working on ARM support and given OSv already [unofficially supports this platform](https://github.com/cloudius-systems/osv/wiki/AArch64) and used to boot on XEN/ARM at some point, it might not be that difficult to make OSV boot on future Firecracker ARM version.

Finally this work might make it easier to boot OSv on [NEMU](https://github.com/intel/nemu) and QEMU 4.0 in [Linux direct kernel mode](https://patchwork.kernel.org/patch/10741013/). It might also make it easier to implement support of new Virtio 1.1 spec.
