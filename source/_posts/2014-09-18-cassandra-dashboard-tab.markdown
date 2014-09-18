---
layout: post
title: "New Dashboard tab give insight to Cassandra virtual appliance"
date: 2014-09-18 15:00:00 +0200
comments: true
published: false
categories: cassandra dashboard
---

**By Tzach Livyatan**

We are constantly looking for ways to improve OSv Virtual Appliances experience.
Latest improvement is an integrate dashboard, presenting a combination of:

* OS related metric (CPU, threads, ...) 
* Profiling related metrics (trace points)
* JVM related metrics (heap, GC,...)
* Cassandra related metrics (latency, tasks, cluster status)

![tab](/images/cassandra-tab.png)

<!-- more -->
The dashboard is yet another example for using
[REST API](osv.io/api/swagger-ui/dist/index.html) to monitor and
control OSv and
OSv virtual appliances. These REST APIs are open for the
user directly. In particular, Capstan tab take advantage of the newly added
[Jolokia](/jolokia-jmx-connectivity-in-osv)
connector, exposing JMX information over REST.


There are other great tools out there for JVM monitoring and profiling, like [VisualVM](http://visualvm.java.net/).
OSv dashboard is unique by unifying the end to end Virtual Appliances functionality:
From the application to the JVM, down to the OS and HW status.

In particular, trace point allows a deep dive in to the system execution, providing similar functionality to DTrace.

We are planing to provide similar application level tabs to other OSv Virtual Appliances.
Want to build a tab for your favorite application on OSv? 
Clone the [osv-gui](https://github.com/cloudius-systems/osv-gui) and start submitting pull requests!

keep up with the latest OSv news from this blog's [feed](http://osv.io/blog/atom.xml), or following [@CloudiusSystems](https://twitter.com/CloudiusSystems) on Twitter.
