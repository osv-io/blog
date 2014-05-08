---
layout: post
title: "Bridged networking with Capstan"
date: 2014-05-07 11:37:05 -0400
comments: true
published: true
categories:  capstan tools network
---

**By Don Marti**

New versions of [Capstan](https://github.com/cloudius-systems/capstan) are making it simpler to run OSv virtual machines in a production configuration, by adding more control of network options.  A useful new feature, which helps deal with the [details of bringing up networking](https://github.com/cloudius-systems/osv/wiki/Running-OSv-image-under-KVM-QEMU), is the `-n` option.

By default, Capstan starts up KVM/QEMU with user networking:

```
 -netdev user,id=un0,net=192.168.122.0/24,host=192.168.122.1
```

(That's from `ps ax | grep qemu`, which you can run
to see the qemu-system-x86_64 command that Capstan
is executing for you.)

But there are many more [networking options](http://www.linux-kvm.org/page/Networking) for QEMU/KVM.  The basic user networking, which does not require root access to start up, is good for development and simple tasks.  But for production use, where you need to get your VM on a network where it's available from other VMs or from the outside, you'll need bridged networking.  (See your Linux distribution or hypervisor documentation for the details of creating a virtual or public bridge device.)

If you invoke `capstan run` with the `-n bridge` option, you'll get QEMU running with:

```
-netdev bridge,id=hn0,br=virbr0,helper=/usr/libexec/qemu-bridge-helper
```

If you have a specific bridge device to connect to, you can use the `-b` option with the name of the bridge device.  The default is `virbr0`, but you can also set up a public bridge, usually `br0`, that's bridged to a physical network interface on the host.

# Other hypervisors

Don't feel left out if you have a different hypervisor.  Capstan also handles bridged networking on VirtualBox, with the rest of the supported hypervisors coming soon.   The fact that the syntax is the same is going to be a big time-saver for those of us who have to do testing and demos on multiple systems&mdash;no more dealing with arcane commands that are different from system to system.

For more on Capstan and networking, please join the [osv-dev mailing list on Google Groups](https://groups.google.com/forum/#!forum/osv-dev).  You can get updates by subscribing to this blog's feed, or folllowing [@CloudiusSystems](https://twitter.com/CloudiusSystems) on Twitter.

