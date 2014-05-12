---
layout: post
title: "Interview: OSv on 64-bit ARM systems"
date: 2014-05-12 23:54:23 -0400
comments: true
published: true
---

## Q&A with Paul Mundt,  Jani Kokkonen, and Claudio Fontana

Paul Mundt is CTO of OS & Virtualization at Huawei, while Jani and Claudio are both Virtualization Architects on Huawei's virtualization team. All are based in Munich, which is the headquarters for Huawei’s European Research Center. The company also has a team of OSv developers in Hangzhou, China, who are focused on adaptation of OSv to Huawei's x86-based enterprise servers.

**Q: ARM processors are everywhere.  What are the important differences
between the Aarch64 hardware that you're targeting with the OSv port and
the garden-variety ARM processors that we have in our phones, toasters,
and Raspberry Pis?**

Other than the relatively obvious architectural differences in going from a 32-bit to a 64-bit architecture (more general purpose registers, address space, etc), there are quite a number of fundamental changes in v8 that considerably clean up the architecture in contrast to earlier versions.

One of the more substantial changes is the new exception and privilege model, with 4 exception levels now taking the place of v7's assortment of processor modes. The new privilege levels are much more in line with conventional CPU privilege rings (eg, x86), even though for whatever reason the numbering has been inverted -- now with EL3 being the most privileged, and EL0 being the least.

Of specific relevance to the OSv port, through its heavy use of C++11/C1x atomic operations and memory model, are the improvements to the CPU's own memory and concurrency model. In contrast to x86, v7 and earlier adopt a weak memory model for better energy efficiency, but have always been terrible at sequentially consistent (SC) atomics as a result. In v8, the weak memory model has been retained, but special attention has also been paid to improving the deficiencies in SC atomics, resulting in the addition of load-acquire/store-release instruction pairs that work across the entire spectrum of general purpose and exclusive loads/stores. This places the architecture in direct alignment with the emerging standardization occurring in C++11/C1x, and has simplified much of the porting work in this area.

Beyond this (while not strictly v8-specific) there are also a new range of virtualization extensions to the interrupt controller that we can take advantage of, but unfortunately this part of the IP is not yet finalized and remains under NDA.

As our semiconductor company (HiSilicon) produces its own Aarch64 CPUs, we have also made a number of our own changes to the microarchitecture to better fit our workloads, especially in the areas of the cache and virtual memory system architecture, virtualization extensions, interconnects, and so on.



**Q: What class of applications is your team planning to run on OSv?**

We see many different potential applications for OSv within Huawei. While OSv is primarily touted as a lightweight cloud OS, the area that is more interesting for my team is its potential as a lightweight kernel for running individual applications directly on the hypervisor, as well as its ability to be used as an I/O or compute node kernel in the dataplane through virtio.

Tight coupling of the JVM to the hypervisor is also an area that we are interested in, particularly as we look to new directions in heterogeneous computing emerging through OpenJDK Sumatra, Aparapi, and the on-going work by the HSA Foundation in which we are also engaged.

Over the next year or so we also expect to see the JVM support maturing, to the point where it should also become possible to run some of the heavier weight big data stacks, but there is a long way to go first.

**Q:  When you're considering using OSv as a lightweight kernel for running applications directly on the hypervisor, are you considering using it  without a local filesystem?  (I understand OSv can boot in about 1/10th the time without ZFS.)**

ZFS is indeed quite heavyweight for our needs, and indeed, up until this stage in the porting effort we have largely been able to avoid it, but this will obviously not be the long-term case as we look to a solution we can bring to our customers.

In addition to the boot time issues you have mentioned, the ZFS adaptive replacement cache (ARC) and page cache interactivity problems with large mmap()'s is an area of concern for some of our potential users, so this is something that we are also closely monitoring, particularly as we think about other ways we might utilize OSv for other applications in the future.

That being said, at the moment we basically see a few different directions to go on the file system side (and by extension, the VFS layer) for our more immediate applications:


1) Simple in-memory file systems with substantially reduced functionality that we can use for scenarios like dataplane applications or I/O nodes where we need no persistent storage. In these cases as we don't even need to support file I/O, we will likely be carrying out some customization and optimizations in this area. This is obviously in contrast to the compute node and control plane side, which we primarily intend to run under Linux in parallel for now.

2) Adaptation for phase change and other non-volatile memories. OSv has a much lighter weight stack with no real legacy at the moment, so fits the role of testbed quite well in terms of experimenting with the best way to tie these technologies in for different deployment scenarios, particularly under a layer of virtualization. In the long run we would naturally expect the results of this work to transfer to the Linux kernel, too.

3) Global and distributed filesystems -- initially across OSv instances, and then across to Linux. This also has implications for the underlying transport mechanisms, particularly as we look to things like lightweight paravirtualized RDMA and inter-VM communication.

**Q:  Which hypervisor or hypervisors are you using?**

While Huawei is actively engaged across many different hypervisors, as my department (in which most of us have a Linux kernel development background) is quite focused on working close to the metal and on performance related issues, KVM is our primary focus.

We have previously done a fair bit of work with guest OS real-time, inter-VM communications, and I/O virtualization enhancements on ARM, so continuing with KVM also makes the most sense for us and our customers.

As one of the main focuses for my OS team is in heterogeneous computing, we also aim to leverage and contribute to much of the work surrounding accelerator, domain processor, and heterogeneous system architecture virtualization under KVM, although much of this is tied up in various European Union framework programmes (eg, FP7-ICT, H2020) at the moment. OSv will also continue to play an important role in these areas as we move forward.

**Q: Anything else that you would like to add?**

Only that now is an exciting time to be in OSv development. The OS has a lot of potential and is still very much in its infancy, which also makes it an excellent target for trying out new technical directions. I would also encourage people who are not necessarily cloud-focused to look at the broader potential for the system, as there's certainly a lot of interesting development to get involved in.



## About

![Paul Mundt](/images/Paul_Mundt.jpg)

**Paul Mundt** is the CTO of OS & Virtualization at Huawei’s European Research Center in Munich, Germany, where he manages the Euler department (including OS & Virtualization R&D, as well as new CPU development and support). Paul first joined Huawei at the beginning of 2013 as the Chief Architect of Huawei’s Server OS division, responsible for overall architecture and strategy. Prior to that, as the Linux Kernel Architect at Renesas in Tokyo, Paul was responsible for leading the Linux group within Renesas for seven years, establishing both the initial strategy and vision while taking the group from zero in-house support or upstream engagement to supporting hundreds of different CPUs across the entire MCU/MPU spectrum and becoming a consistent top-10 contributor to the Linux kernel, which carries on to this day. He has more than 15 years of Linux kernel development experience, across a diverse range of domains (HPC, embedded, enterprise, carrier grade), and has spent most of that time as the maintainer of various subsystems (primarily in the areas of core kernel infrastructure, CPU architectures, memory management, and file systems). He previously organized and chaired the Memory Management Working Group within the CE Linux Forum, where he advocated the convergence of Enterprise and Embedded technologies, resulting in the creation of Asymmetric NUMA, as well as early transparent superpage/large TLB adoption. He is a voting member of the OASIS Virtual I/O Device (VIRTIO) Technical Committee and the HSA Foundation.

![Jani Kokkonen](/images/Jani_Kokkonen.jpg)

**Jani Kokkonen** received his master’s degree in 2000 from the Technical University of Helsinki, Finland. He went to pursue research and development job in Nokia Networks. The work concentrated in research of different transport technologies on various radio access networks. This was followed by research and development activities on virtualization technologies on 3GPP radio and core network elements. Work consisted also evaluation of hardware extensions for virtualization support on various embedded multicore chips. He has been as virtualization architect in Huawei ERC Euler Department since September 2011. The work in Huawei has concentrated on research and development on QEMU/KVM on ARM and Intel platforms varying from CPU to network technologies, with his most recent effort focusing on ARM64 memory management where he is responsible for the MMU backend in the Aarch64 OSv port, as well as leading the OSv team. He is a member of the OASIS Virtual I/O Device (VIRTIO) Technical Committee and the Multicore Association.

![Claudio Fontana](/images/Claudio_Fontana.jpg)

**Claudio Fontana** received his Laurea in Computer Science in 2005 at the University of Trento, Italy, discussing a thesis on frameworks for the evaluation of taxonomy matching algorithms. He went on to pursue a software engineering opportunity in Zurich, where he worked on medium-scale (100s hosts) distributed systems. This was followed by a software engineering position in Amsterdam, working on messaging, routing, firewalls and billing systems. He has been with Huawei since December 2011. He is currently working in the virtualization area (Linux/KVM/QEMU). He is part of the early enablement effort for the ARM 64bit architecture (ARMv8 AArch64), and has been a maintainer and contributor of Free and Open Source projects, lately involving mostly QEMU binary translation (as QEMU Aarch64 TCG maintainer) and the OSv Operating System (as Aarch64 maintainer). He also spent some time as a member of Linaro's Virtualization team, where he focused on early Aarch64 enablement.

## For more information

To keep up with the progress of OSv on ARM (and x86_64 too), join the [osv-dev mailing list](https://groups.google.com/forum/#!forum/osv-dev) or follow [@CloudiusSystems](https://twitter.com/CloudiusSystems) on Twitter.

