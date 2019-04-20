---
layout: post
title: "OSv paper coming to USENIX in June"
date: 2014-05-19 11:54:23 -0400
comments: true
published: true
---

**By Don Marti**

We're going to the USENIX Annual Technical Conference
in Philadelphia!

<a href="https://www.usenix.org/conference/fcw14"><img src="https://www.usenix.org/sites/default/files/fcw14_banner_450x93.png" border="0" alt="2014 Federated Conferences Week"></a> 

[Our paper, "OSv—Optimizing the Operating System for Virtual Machines" ](https://www.usenix.org/conference/atc14/technical-sessions/presentation/kivity) has been accepted by one of our favorite IT events.  We appreciate all the excellent comments and questions from our peer reviewers.

This year, ATC will be part of a Federated Conferences Week that includes HotCloud, HotStorage, two days of sysadmin training, and more, so there should be something for everyone.

The paper will be available under Open Access terms starting on the date of the event, but we all hope you can come see us live and in person.

Here's the abstract:

<blockquote>
<p>Virtual machines in the cloud typically run existing general-purpose operating systems such as Linux. We notice that the cloud’s hypervisor already provides some features, such as isolation and hardware abstraction, which are duplicated by traditional operating systems, and that this duplication comes at a cost.</p>

<p>We present the design and implementation of OSv, a new guest operating system designed specifically for running a single application on a virtual machine in the cloud. It addresses the duplication issues by using a low-overhead library-OS-like design. It runs existing applications written for Linux, as well as new applications written for OSv . We demonstrate that OSv is able to efficiently run a variety of existing applications. We demonstrate its sub-second boot time, small OS image and how it makes more memory available to the application. For unmodified network-intensive applications, we demonstrate up to 25% increase in throughput and 47% decrease in latency. By using non-POSIX network APIs, we can further improve performance and demonstrate a 290% increase in Memcached throughput.</p>
</blockquote>

For more event updates, please follow [@CloudiusSystems on Twitter](https://twitter.com/CloudiusSystems).

