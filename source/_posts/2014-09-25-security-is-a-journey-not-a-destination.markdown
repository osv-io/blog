---
layout: post
title: "Waking up late, after bash Fixing Night"
date: 2014-09-25 12:54:23 -0800
comments: true
published: true
---

**By Don Marti**

Yesterday we found out about [a remotely exploitable hole in bash](https://lwn.net/Articles/613032/) from our favorite Linux news sites.  For some of us, our schedules on the night of September 24th were disrupted, and not in a good way.

It's true that my own Internet-facing code, while not perfect, isn't vulnerable.  But for one older web-based application I have to deal with, it's faster to install a new version of Bash than to trace through the code to make sure it isn't doing something bad, somewhere.

Clearly this particular bug isn't a problem on OSv, because OSv doesn't run Bash.  The whole point of Bash is to `fork()` and `exec()` other processes, and OSv doesn't do all that.  Everything runs in one process, with no shell available or needed.

As [Tzach Livyatan points out](http://osv.io/blog/blog/2014/09/25/shellshock/), managing OSv doesn't require a shell either.  There's one REST API for everything, from VM basics such as CPU and memory usage, up to [JMX data from the application](http://osv.io/blog/blog/2014/08/26/jolokia-jmx-connectivity-in-osv/).

But it looks like Tzach is missing the main point.

<!-- more -->

The problem isn't so much that someone discovered a bug in Bash.  The problem is _what happened to the evening of September 24, 2014_?  A software bug should be something that you fix, test, check in the fix, and go home, not a full [night on duty](http://www.tor.com/stories/2009/12/overtime).

I'm starting to think that what's more important than any design advantages of OSv is the flow that it enables.   The size and, more important, simplicity of an OSv VM means that regenerating one is a matter of, let me time it... 9 seconds.  An OSv VM is a build artifact that I can crank out of my regular build system.

It would be full of security hubris to say that OSv will never have to issue a security fix.  Yes, there are many fewer lines of code, and yes, the C++ experts on the development team will point to shorter, clearer programming contstructs in which fewer old-school bugs can hide.  But every software project has to issue a fix sometimes.

The question is how long it takes to get current and put the bug behind you.

**Repeatable flow, from commit to deploy**

At [JavaOne next week](https://oracleus.activeevents.com/2014/connect/sessionDetail.ww?SESSION_ID=4120), Glauber Costa and I will be speaking about <q>OSv: The Operating System Designed for Java and the Cloud</q>.  Glauber summed it up: <q>OSv is a library OS. Therefore, you can think of using it as being a way to boot a JVM directly into the cloud. Forget OS management: it’s your application and the end of the story.</q>

The [complexity of maintaining conventional OS environments](https://www.gartner.com/doc/2831925/make-sdlc-agile-using-cloud) looks like just a time-suck for developers, not a big problem.  But simplicity matters on a Big Security Day.

**More info**

For general questions on OSv, please join the [osv-dev mailing list](https://groups.google.com/forum/#!forum/osv-dev).  You can get general updates by subscribing to this blog's [feed](http://osv.io/blog/atom.xml), or folllowing [@CloudiusSystems](https://twitter.com/CloudiusSystems) on Twitter.

