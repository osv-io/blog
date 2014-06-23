---
layout: post
title: "Hypervisors are dead, long live the hypervisor (part 3)"
date: 2014-06-23 12:00:00 -0800
comments: true
published: true
---

**By Dor Laor and Avi Kivity**

# The new school: functionality, isolation and simplicity 

(This is part 3 of a 3-part series. [Part 1](http://osv.io/blog/blog/2014/06/19/containers-hypervisors-part-1/), [Part 2](http://osv.io/blog/blog/2014/06/19/containers-hypervisors-part-2/))

Containers make administration simple, and VMs give you portability, isolation, and administration advantages. The concept of putting [containers inside VMs](http://www.slideshare.net/jpetazzo/linux-containers-lxc-docker-and-security) gives you the isolation you need, but there are now two layers of configuration and overhead instead of one.

What if there were one technology that could give us the simplicity and reduced overhead of containers and the security, tools, and hardware support of hypervisors? That’s where OSv comes in.  OSv, the “Operating System Designed for the Cloud.” takes an approach different from either containerization or virtualizing an existing bare-metal OS.  OSv is a single address space OS, designed to run as a guest only, with one application per VM.

## Best of both worlds? 

Glauber Costa, in a speech at Linuxcon called ["The failure of Operating Systems, and how we can fix it"](https://events.linuxfoundation.org/images/stories/pdf/lceu2012_costa.odp), pointed out that the existence of hypervisors is evidence that Operating Systems alone cannot meet some of the demands of real workloads. Through OSv, we have the opportunity to work together with the hypervisor to create a superior solution to what can be done with the OS alone: combining the resource efficiency of containers with the processor-aided advantages of hardware virtualization.

In the eight years since the release of Intel VMX, the silicon has kept getting better and better at moving the costs of virtualization into hardware. Enterprise customers have been demanding lower virtualization overhead for as long as hypervisors have been a thing, and the best minds of the CPU industry are working on it. With nested page tables and other features coming “for free” on the processor, virtualization overhead is being squeezed closer and closer to parity with bare metal.

![typical cloud stack with duplication](/images/duplication.png)

**Typical cloud stacks have duplicate functionality at the hypervisor, guest OS, and application levels.**

While many players are trying to carve out a simple OS containerization system at the guest OS level, they are ignoring the stable, simple, secure, hardware-supported interface we already have: the hypervisor-guest interface.  There’s nothing that says we have to use this well-tested, industry-standard interface just to run a large, complete OS designed for bare metal. (In fact, research projects such as “Erlang on Xen” and MirageOS have explored using the hypervisor to run something less than a full OS for quite a while.)

## OSv is designed to perform

OSv transparently loads an application into its kernel space. There is no userspace whatsoever. It removes the need for user to kernel context switches. In addition, the kernel trusts the application, since it relies on the underlying hypervisor for isolation from other applications in other VMs. Thus it opens up a way for the application to use any kernel API – from taking scheduling decisions to zero copy operations on data, and even unlock the brute force of the hardware page tables for the benefit of the application or its framework.

To date (June 2014), OSv provides 4x better performance for Memcache, a 40% gain with Apache Tomcat, and a 20% gain with Cassandra and SPECjbb. These results are based on our alpha versions, and are likely to improve as we complete the optimizations remaining on our roadmap.

![OSv example workloads](/images/workloads.png)

**OSv runs many key cloud workloads with low overhead and high performance.**

OSv's image is your app and our kernel. Sometimes it means an image size of 10MB! That's a 100-400x better than the traditional OS and resembles a container's footprint. The OSv boot time is under a second, which is also closer to container startup time.


##OSv management: some questions for devops

How many configuration files does your OS have? **OSv has zero.**

How many times have you had to perform string manipulation on UNIX-like config files? **OSv is built for automation and uses a RESTful API instead.**

How hard is it to upgrade your OS, and how can you revert it? **OS is stateless.**

With an hypervisor below, you get the features such as live migration, perfect SLA, superior security for free while you get to enjoy from OSv’s added value.

## Capstan – or what we have learned from Docker

We do love Docker with regard to development. The neat public image repository and the dead-simple-single execution won our hearts. We wanted to have the same for VMs, so we created the [Capstan](http://osv.io/capstan/) project. Capstan has a public image repository, and by executing 'capstan run cloudius/osv-cassandra' a virtual machine image will be either downloaded to your laptop (Mac OS X, Microsoft Windows, or Linux) or be executed on your cloud of choice. Capstan also allows you to build images including an app and a base OSv image. It takes about three seconds. On Capstan's roadmap, we plan to support the Docker file format, run Java apps directly without a config file, and form a simple PaaS for developers to load their favorite app directly to a running VM.

## Pick a cloud, any cloud 

The business case for cloud computing has never been better for the customer. While Amazon continues to upgrade the available instances and offer faster VMs at lower prices, Google is coming on strong as well. Microsoft, HP, IBM, and others are all competing for cloud business.  The cloud VM is the new generic PC.  Because we can create standard VMs that will run on anyone’s cloud, or on a private or hybrid cloud, we can develop with the confidence that we’ll be able to deploy to whatever infrastructure makes business sense--or move, or split deployment.

Lastly, we like to point out we are not against containers. Container technology is awesome when used for the right scenario. As there are cases for public transportation versus private cars, the same applies to devops. Both containers and OSv excel, in different domains. Here is a simple flow chart that can guide you with your choices:

[![Guest OS selection flowchart](/images/flowchart.png)](/images/flowchart.png)

Using OSv on ubiquitous, secure, full-featured hypervisors is the way to keep performance up, costs down, and options open. We had to completely reinvent the guest OS to do it&mdash;but now that we have it, OSv is available to build on. Please join the [osv-dev mailing list](https://groups.google.com/forum/#!forum/osv-dev) for technical info, or follow [@CloudiusSystems on Twitter](https://twitter.com/CloudiusSystems) for the latest news.

( [Part 1](http://osv.io/blog/blog/2014/06/19/containers-hypervisors-part-1/), [Part 2](http://osv.io/blog/blog/2014/06/19/containers-hypervisors-part-2/)
)

