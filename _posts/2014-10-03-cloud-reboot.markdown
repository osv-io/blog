---
layout: post
title: "A cloud wake-up call"
date: 2014-10-03 16:54:23 -0800
comments: true
published: true
---

**By Dor Laor**


If you use AWS or Rackspace, there is a good chance that you got affected by [cloud-reboot](https://gigaom.com/2014/09/24/yikes-big-amazon-web-services-reboot-on-the-way/). Ten percent of AWS machines were forced to reboot during the weekend period due to a simple bug that created a security vulnerability. The reboot could have been prevented/mitigated through the use of sophisticated but handy tools. Such tools have existed for years but few people use them.

Let’s take a closer look at the particular problem and proceed toward a call for action for usage of additional, fantastic low-level features that are hardly being used by IaaS/PaaS vendors.

The cloud-reboot trigger is a tiny off-by-12kb xen hypervisor bug. A simple Model Specific Register check had a wrong limit as you can observe in the 
[fix](http://xenbits.xen.org/xsa/xsa108.patch) for the [security vulnerability](http://xenbits.xen.org/xsa/advisory-108.html): 

```
-    case MSR_IA32_APICBASE_MSR ... MSR_IA32_APICBASE_MSR + 0x3ff:
+    case MSR_IA32_APICBASE_MSR ... MSR_IA32_APICBASE_MSR + 0xff:
```

The vulnerability allows an attacker to either crash the hypervisor or retrieve data about other tenants. It’s really a long shot since the memory probably belongs to Xen addresses but in theory one can get lucky and read someone else’s passwords/keys.
 
Kudos to Amazon and Rackspace for being on the safe side. The fix is a huge hassle and pain for such a small chance of being successfully targeted. Kudos for Xen (and the other hypervisor vendors) for developing mature hypervisors that these events are that rare.

Now how could an IaaS vendor mitigate the problem without a reboot?

Option #1 - Dynamic Code Patching
---------------------------------

Dynamic code patch technology for running-code has been available for years. Initially it was [KSplice](http://en.wikipedia.org/wiki/Ksplice), and
that was recently followed by [KPatch](https://github.com/dynup/kpatch). Lean cloud providers [reported KSplice deployment for Xen 4 years ago!](https://twitter.com/extramsp/status/18715823586)

![Cloud provider announces Ksplice support, on Twitter](/images/extramsp.png)

XSA-108, the cloud-reboot bug, could have been the perfect candidate for this.
Hold your horses; Ksplice probably hadn’t been integrated to Xen and Ksplice is only applicable to dom-0. However, didn’t they see it coming? Now 10% of the Internet needs a reboot because no one picked it up. Let’s see whether a quick developer group will come to the rescue.  Ouch. 

Option #2 - Live migration
--------------------------

Look ma, no hands...live migrate the VMs from an old hypervisor version to a patched hypervisor without service interruption. 

At Red Hat, I managed the KVM and Xen development teams. We were heavily invested in live migration development. A great deal of thought was given to cross-release migration, resulting in the ability to migrate a VM running on KVM version x to version x+y.  Sometimes even the opposite direction was allowed. We maintained a huge matrix of migration options which included the preservation of the virtual-hardware version. This means that a KVM hypervisor can represent a variety of virtual-hardware versions (combo of cpu+devices) and keep the ABI (Application Binary Interface) compatible across KVM releases and live migration events.

Live migration was constantly optimized to reduce the effect on the running-workloads as well as to minimize downtime to few msecs. Smart compression, hot-page-transfer prioritization, and even more adventurous post-copy migration were deployed. 

To my surprise, several years and millions of hypervisors later, most cloud providers do not implement live migration. That’s rather unfortunate for a couple of reasons: 

 * **Live migration allows maintenance mode.** The host can be taken down while the VMs are being migrated to a different host

 * **Dynamic load balancing** It’s possible to over-provision resources such as cpu, network, memory, etc in order to increase virtual server density. In case of load, live migrate VMs balance the host resources. Over-provisioning can reduce the cloud-bills dramatically; for a theoretical example, check the cost of a [t2-micro](http://aws.amazon.com/ec2/instance-types/) instance.

A leading cloud provider does use live migration, mainly because it uses shared storage for the VMs and the migration is just about the VM RAM. Other IaaS vendors use local storage but the 'excuse' does not hold since for long it is possible to live migration local storage too . Sophisticated scenarios are supported; for example, a VM template image can reside on shared storage. There is no need to copy the image to the local disk when the VM is provisioned. Instead, the VM starts execution locally while its disk is remote. On the fly the disk requests are served from the network while a background task transfers the entire disk to the local hypervisor. In a similar way, live migration of a VM with local storage can takes place.

Even open source projects such as Openstack and CloudFoundry do not support live migration. After all the time and effort invested in capturing the state of the virtual machine hardware state, it’s pretty sad that the feature isn’t enabled in practice and only data center solutions like vCenter and RHEV support it. Just to finalize this rant, please allow me to enclose the type of data a live migration captures:

 * Complete configuration of the virtual hardware setup
 * State of all CPU registers (General purpose, FPU, SIMD, MSRs,..)
 * State of the interrupt controllers
 * State of the disk drive (Registers, in-flight IO, interrupts)
 * State of the network cards (Registers, in-flight IO, interrupts)
 * State of all other devices - keyboard, mouse, USB, GPU, etc

Modern hypervisors manage to deal with the above complexity and send GBs of data underneath the guest execution. In turn, the cloud management software needs only to find a target host and evacuate the source host (in the case of hardware/software maintenance or a bit more sophisticated for load balancing needs). This is a fair deal, now please, go implement it.


## \<wake up call continues\>


Since I started with two important OS features that aren’t implemented (dynamic patching and live migration), let me add to the list the following:

 * **Hot (un) plug of memory and cpu** This is a pure scale-up scenario. You start a small VM and if there is a need, add virtual CPUs and/or memory to the mix. Most OS’s and hypervisors support it.  Imagine you run a c3.8xlarge during the day, and at night you unplug resources to form a c3.large VM which costs 1/16 as much.

Imagine you’re running a JVM application that needs an immediate garbage collection (GC). Today, the application will experience a Stop-The-World phase which will translate into downtime that can go up to several seconds (a function of heap size).  Instead, such a VM can ask to hot plug additional RAM and CPUs 1 second before it really needs to pause. The JVM may use even a silly copy garbage collector to copy the live objects from the original RAM block to newer hotplugged-RAM blocks and unplug the old block entirely (using the extra vCPUs to accelerate the action).

 * **Trusted boot/computing** Trusted Computing is a technology to keep the integrity of an operating system, which is based on a secure chip such as “TPM (Trusted Platform Module)” and/or Intel’s TXT technology: Trusted Execution Technology provides a hardware based root of trust to ensure that a platform boots with a known good configuration of firmware, BIOS, virtual machine monitor, and operating system, forming a fully signed and secure stack.  

 * **Fast VM provision time** [OSv](http://osv.io/) boots in under 1 second! However it takes significantly more time to provision a VM.  If the hypervisor and the OS can boot that fast, I see no reason for the hypervisor management code to be slower.

## \</wake up call continues\>


Enough rants for one day, now let’s get back to [#OSv](https://twitter.com/search?q=%23osv) and make it shine some more.

*For more info on OSv, please follow [@CloudiusSystems](https://twitter.com/CloudiusSystems) on Twitter.* 
