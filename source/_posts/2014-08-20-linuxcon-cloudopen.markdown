---
layout: post
title: "OSv in the spotlight at LinuxCon/CloudOpen 2014"
date: 2014-08-20 17:10:31 -0600
comments: true
published: true
categories: events
---

While we relax and don't have to fix anything on our slides (really, they're all done), other speakers at the Linux Foundation's [CloudOpen North America conference](http://events.linuxfoundation.org/events/cloudopen-north-america) in beautiful Chicago have some observations to make about OSv.

![Chicago River](/images/chicago-river.jpeg)
**The Linux Foundation always picks great conference locations.**

[Russell Pavlicek](http://lccona14.sched.org/speaker/rcpavlicek) from the Xen project mentioned several library OSs that run on Xen in his [talk on new Xen features](http://lccona14.sched.org/event/17fdf31e5913cc4ebd5cf1f2ec039aa0).  He called the concept "one of the biggest advances in the cloud."  Earlier library OSs have shown how much performance and simplicity gains are available, and OSv is extending the idea to ordinary POSIX and Java applications.

[Mike Day](http://lccona14.sched.org/speaker/mikeday) from IBM said, "the engineers who write OSv are really good C++ coders," and called the project "some of the finest C++ source code I've ever seen" in his [talk on cloud operating systems for servers](http://lccona14.sched.org/event/434032efc316cc7aa98d4d590abda72e).  He also had some praise for the [spinlock-free way](http://osv.io/blog/blog/2014/04/19/spinlock-free/) that OSv handles mutexes, which as regular readers of this blog will know is important to prevent the dreaded lock-holder preemption problem.

If you're at LinuxCon, excuse me, #linuxcon, please come over and say "hi" to the OSv speakers: Don Marti and Glauber Costa. Hope to see you at the event, and please come to "[Beating the Virtualization Tax for NoSQL Workloads With OSv](http://lccona14.sched.org/event/4684a80dd37f200277e971133920a2d0)" on Friday at 10:45 in the Colorado room.   Otherwise, you can get general OSv updates by subscribing to this blog's [feed](http://osv.io/blog/atom.xml), or folllowing [@CloudiusSystems](https://twitter.com/CloudiusSystems) on Twitter.

**Chicago River photo: [Urban for Wikimedia Commons](http://commons.wikimedia.org/wiki/File:Chicago_river_2004.jpg)**
