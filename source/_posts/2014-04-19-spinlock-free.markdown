---
layout: post
title: "Spinlock-free OS design for virtualization"
date: 2014-04-19 12:00:00 -0400
comments: true
published: true
---
Designing an OS to run specifically as a cloud guest doesn’t just mean stripping out features. There are some other important problems with running virtualized that a conventional guest OS doesn’t address.  In this post we'll cover one of them.

## Little spinlocks, big problem

In any situation where code running on multiple CPUs might read or write the  same data, typical SMP operating systems use spinlocks. One CPU acquires the lock using an atomic test-and-set operation, and other CPUs that need the data must execute a busy-loop until they can acquire the lock themselves. Can I have the data? No. Can I have the data? No. Can I have the data? No. When an OS runs on bare hardware, a spinlock might just waste a little electricity. OS developers often use other more sophisticated locking techniques where they can, and try to reserve spinlocks for short-term locking of critical items.

![OSv hacking at Apachecon 2014](/images/apachecon.jpg) <i>Getting some high-performance web applications running on OSv at ApacheCON 2014</i>

The problem comes in when you add virtualization. A physical CPU that holds a spinlock is actually working. The other CPUs in the system, “spinning” away waiting for the lock, are at least waiting for something that’s actually in progress. On a well-designed OS, the lock holder will be done quickly. When the OS is running under virtualization, though, it’s another story. The hypervisor might pause a virtual CPU at times when the guest OS can’t predict. As [Thomas Friebel and Sebastian Biemueller described]( http://www.betriebssysteme.org/Aktivitaeten/Treffen/2008-Garching/Programm/docs/Abstract_Friebel.pdf ) (PDF) in “How to Deal with Lock Holder Preemption”,

> Lock holder preemption describes the situation when a VCPU is preempted inside the guest kernel while holding a spinlock. As this lock stays acquired during the preemption any other VCPUs of the same guest trying to acquire this lock will have to wait until the VCPU is executed again and releases the lock. Lock holder preemption is possible if two or more VCPUs run on a single CPU concurrently. And the more VCPUs of a guest are running in parallel the more VCPUs have to wait if trying to acquire a preempted lock. And as spinlocks imply active waiting the CPU time of waiting VCPUs is simply wasted.

If the hypervisor pauses a virtual CPU while that VCPU holds a spinlock, you get into the bad situation where other virtual CPUs on your guest are just spinning, and it’s possible that no useful work is getting done in that guest--just electricity wasting. Friebel and Biemueller describe a solution to the problem involving a hypercall to complain about the wait. But the OSv solution to the problem is to remove spinlocks from the guest OS entirely.

## Why going spinlock-free matters

As a first step, OSv does almost all of its kernel-level work in threads. Threads, which are allowed to sleep, can use lock-based algorithms. They use mutexes, not spinlocks, to protect shared data. The [mutex implementation itself](https://github.com/cloudius-systems/osv/blob/master/include/lockfree/mutex.hh), however, has to use a lock-free algorithm. OSv’s [mutex implementation](https://github.com/cloudius-systems/osv/blob/master/include/lockfree/mutex.hh) is based on a lock-free design by Gidenstam & Papatriantafilou, covered in [LFTHREADS: A lock-free thread library.](http://domino.mpi-inf.mpg.de/internet/reports.nsf/c125634c000710d0c12560400034f45a/77c097efde9fa63fc125736800444203/$FILE/MPI-I-2007-1-003.pdf) (PDF).

One other place that can’t run as a thread, because it has to handle the low-level switching among threads, is the scheduler. The scheduler uses per-cpu run queues, so that almost all scheduling operations do not require coordination among CPUs, and lock-free algorithms when a thread must be moved from one CPU to another.



Lock-free design is just one example of the kind of thing that we mean when talking about how OSv is “designed for the cloud”.  Because we can’t assume that a CPU is always running or available to run, the low-level design of the OS needs to be cloud-aware to prevent performance degradation and resource waste.

We’ve been posting benchmarks that show sizeable performance increases running memcached and other programs. If you’re curious about whether OSv can make your application faster, please try it out from the [OSv home page](http://osv.io/) or join the [osv-dev mailing list](https://groups.google.com/forum/#!forum/osv-dev).

