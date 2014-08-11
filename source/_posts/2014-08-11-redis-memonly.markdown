---
layout: post
title: "Redis on OSv"
date: 2014-08-08 11:37:05 -0400
comments: true
published: false
categories: nosql
---

**By Glauber Costa and Don Marti**

We're planning to attend the 
Linux Foundation's [CloudOpen North America conference](http://events.linuxfoundation.org/events/cloudopen-north-america).  Hope to see you there, and please come to our talk, "[Beating the Virtualization Tax for NoSQL Workloads With OSv](http://lccona14.sched.org/event/4684a80dd37f200277e971133920a2d0)."

We'll be using a popular NoSQL database for our demo: Redis.  If you'd like to follow along, you're welcome to clone and build Redis on OSv.  We're big Redis fans, because it's a fast, easy-to-administer, in-memory database that works with many useful data structures.


## Redis A to Z

[Redis](http://redis.io/) is a remarkably useful piece of software.  People on the Internet talk about Redis a lot.  Here's what Google Suggest has to say about it: **Atomic, benchmark, cluster, delete, expire, failover, gem, hash, incr, Java, key, list, master/slave, node.js, objects, Python, queue, Ruby, set, ttl, Ubuntu, "vs. mongodb", Windows, XML, yum, zadd**.  ([zadd](http://redis.io/commands/ZADD) is a really cool command by the way.  A huge time-saver for maintaining "scoreboard" state for games and content-scoring applications.  Did we mention that we're Redis fans?)

Redis fills a valuable niche between memcached and a full-scale NoSQL database such as Cassandra.  Although it's fast and perfectly usable as a simple key-value store, you can also use Redis to manage more featureful data structures such as sets and queues.

It makes a great session cache, lightweight task queue, or a place to keep pre-rendered content or ephemeral data, and it's a [star at highscalability.com](http://highscalability.com/display/Search?moduleId=4876569&searchQuery=redis)

But you probably already know that.


## Building Redis on OSv

Redis works on OSv except for one feature: the
[BGSAVE](http://redis.io/commands/bgsave)
command.  A Redis background
save depends on the operating system's
[copy-on-write](http://en.wikipedia.org/wiki/Copy-on-write#Copy-on-write_in_virtual_memory_management)
functionity.  When you issue the BGSAVE
command, the parent Redis process calls
[fork](http://en.wikipedia.org/wiki/Fork_%28system_call%29),
and the parent process keeps running while the child
process saves the database state.

Copy-on-write ensures that the child process sees
a consistent set of data, while the parent gets its
own copy of any page that it modifies.

Because OSv has a single address space,
that isn't an option here. OSv support Redis
[SAVE](http://redis.io/commands/save) but not BGSAVE.


```
make image=redis-memonly
```

Now you have a `usr.img` file, which you can run locally with OSv's `run.py`.

'''


'''

## Is it fast?





If you have any questions on running Redis or any other application, please join the [osv-dev mailing list](https://groups.google.com/forum/#!forum/osv-dev).  You can get general updates by subscribing to this blog's [feed](http://osv.io/blog/atom.xml), or folllowing [@CloudiusSystems](https://twitter.com/CloudiusSystems) on Twitter.

