---
layout: post
title: "Speed run: running 4 virtual appliances on your laptop in 5 seconds overall"
date: 2014-09-14 08:30:00 +0200
comments: true
published: true
categories:  capstan tools redis tomcat mysql cassandra
---

**By Dor Laor, Tzach Livyatan**

In the following demo, Dor is running 4 different OSv base virtual appliances
on his laptop:

* Redis
* Tomcat
* MySQL
* Cassandra

Each virtual appliance is a full–blown VM, each with a pre-integrated
cloud application, and each launched without terminating the others.

<!-- more -->

<script type="text/javascript" src="https://asciinema.org/a/11914.js" id="asciicast-11914" async></script>

As you can see, application startup time takes between sub-second
(Redis) to a few seconds (Cassandra) depending on the application.
The hypervisor plus OS part of the boot time is less than a second for all cases.

Want more info on Capstan and related topics?  Join the [osv-dev mailing list](https://groups.google.com/forum/#!forum/osv-dev).  You can get regular OSv updates by subscribing to this blog's feed, or folllowing [@CloudiusSystems](https://twitter.com/CloudiusSystems) on Twitter.  
