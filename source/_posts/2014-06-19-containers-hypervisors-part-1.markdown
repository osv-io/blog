---
layout: post
title: "Hypervisors are dead, long live the hypervisor (part 1)"
date: 2014-06-19 12:00:00 -0800
comments: true
published: false
---

**By Dor Laor and Avi Kivity**

The hypervisor is the basic building block of cloud computing; hypervisors drive the software-defined data center revolution, and two-thirds of all new servers are virtualized today. Hypervisors for commodity hardware have been the key enabler for the software revolution we have been experiencing. 
 
However, for the past 8 years a parallel technology has been growing, namely, containers. Recently containers have been getting a fairly large amount of traction with the development of the Docker project. When run on bare metal, containers perform better than hypervisors and have a lower footprint. 

There is a lot in common with the goals of these technologies. These three blog entries will try to provide an answer to the question

**Will containers kill the hypervisor?**

The series will provide in-depth explanations about the underlying technology and the pros and cons of each solution.

## Intro: ancient hypervisor lore

What is virtualization anyway?

![Virtualization diagram](/images/virtualization.png)

A hypervisor is a software component (potentially assisted by hardware) that allows us to run multiple operating systems on the same physical machine. The overlay OS is called the guest OS or simply, a Virtual Machine (VM). The guest OS may not even be aware it is running on virtual hardware. 

The interface between the guest and the host is the hardware specification. It covers the CPU itself and any other hardware devices, from BIOS to NICs, SCSI adapters, GPUs and memory. 

![IBM System/360](/images/IBM360-67AtUmichWithMikeAlexander.jpg)

**IBM, together with MIT and the University of Michigan, pioneered hypervisor technology on System/360 and System/370 mainframes, beginning in the 1960s.**

IBM was the first company to produce hypervisors. The IBM System/360, model 1967, was the first to [ship with virtual memory hardware supporting virtualization](http://www.beagle-ears.com/lars/engineer/comphist/ibm360.htm#gener). The next system in the series, System/370, was the “private cloud” of its day. Administrators could set up virtual machines for running different OS versions, and even public-cloud-like “time sharing” by multiple customers.

## Virtualization for x86

Virtualization didn’t make it to commodity systems until the [release of VMware Workstation in 1999](http://www.vmware.com/company/news/mediaresource/milestones). In the early 2000s, hypervisors were based on pure software and were mostly useful for development and testing.  VMware initially used a technique called dynamic translation to intercept privileged operations by the guest operating system. When the guest accessed “hardware”, VMWare rewrote the instructions on the fly, to protect itself from the guest and isolate guests from each other. 

![VMware logo](/images/vmware-logo.png)

Later on, the open source Xen hypervisor project coined the term paravirtualization (PV). PV guests, which have to be specially modified to run on a PV host, do not execute privileged instructions themselves but ask the hypervisor to do it on their behalf.

![Xen logo](/images/xen-logo.png)

Eventually, Intel, AMD and ARM implemented support for virtualization extensions. A special host mode allows running guest code on the bare CPU, getting near 100% of bare metal throughput for CPU-intensive workloads. In parallel, the memory management and the IO path received attention as well with technologies such as nested paging (virtual memory), virtual interrupt controllers, single-root I/O virtualization (SRIOV) and other optimizations.

## Hardware support for hypervisors

Hypervisor enablement continues to be a priority for hardware manufacturers. [Glauber Costa wrote](https://plus.google.com/+OsvIo/posts/fgzsepcScTa), “the silicon keeps getting better and better at taking complexity away from software and hiding somewhere else.”

[According to a paper from Red Hat Software](http://www.redhat.com/rhecm/rest-rhecm/jcr/repository/collaboration/jcr:system/jcr:versionStorage/5e7884ed7f00000102c317385572f1b1/1/jcr:frozenNode/rh:pdfFile.pdf),

> Both Intel and AMD continue to add new features to hardware to improve performance for virtualization. In so doing, they offload more features from the hypervisor into “the silicon” to provide improved performance and a more robust platform....These features allow virtual machines to achieve the same I/O performance as bare metal systems.
Old-school hypervisors

Hypervisors are one of the main pillars of the IT market (try making your way through downtown San Francisco during VMworld) and solve an important piece of the problem. Today the hypervisor layer is commoditized, users can choose any hypervisor they wish when they deploy Open Stack or similar solutions.

Hypervisors are a mature technology with a rich set of tools and features ranging from live migration, cpu hotplug, software defined networking and other new coined terms that describe the virtualization of the data center.

However, in order to virtualize your workload, one must deploy a full fledged guest operating system onto every VM instance. This new layer is a burden in terms of management and in terms of performance overhead. We’ll look at one of the other approaches to compartmentalization next time: containers.

**This is part 1 of a 3-part series.** Please subscribe to our [feed](/atom.xml) or follow [@CloudiusSystems](https://twitter.com/CloudiusSystems) to get a notification when part 2 is available.

Photo credit, IBM 360: [Dave Mills for Wikimedia Commons](http://commons.wikimedia.org/wiki/File:IBM360-67AtUmichWithMikeAlexander.jpg)

