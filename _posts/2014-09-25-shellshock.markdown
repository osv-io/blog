---
layout: post
title: Shellshock
date: 2014-09-25 14:54:23 -0800
comments: true
published: true
---

**By Tzach Livyatan**

A new bash bug is 'bigger than Heartbleed' and puts millions of websites.
In short, Shellshock can take advantage of any server which call Bash.
You can find a good insight into Shellshock [on Michal Zalewski's blog](http://lcamtuf.blogspot.co.il/2014/09/quick-notes-about-bash-bug-its-impact.html).

A Bash patch is already available, but there is a bigger question:
Why do you want  Bash on a production server in the first place?
By its nature Bash is a dangerous beast, wouldn't it be better to keep him on the cage and off your system?

What did you say? 

"I need my Bash for troubleshooting?"

Do you now?

<!-- more -->

I assume your production server already writes logs and send traps to to a remote machine.
If not, you probably do not have many production servers.
What if in addition you had a secure remote REST API which allows you to probe files, get traces and any other information element you need?
Do you still need Bash?
And if you don't, than wouldn't it be better not to have it on the first place?

Don Marti [writes](http://osv.io/blog/blog/2014/09/25/security-is-a-journey-not-a-destination/) that the need for fast, reliable VM builds is the important lesson from this bug, but I disagree. Why not just remove the shell from the server?

OSv takes a different approach from other OSs on the subject.
Recognizing that most cloud servers only run one application, it is designed to run one and only one process.
Every interaction with OSv is done via a set of REST APIs, over SSL.
You can find the [current list of supported endpoints](http://osv.io/api/swagger-ui/dist/index.html) on the OSv site.
Since `fork` is inherently not allowed, there is not way for a Shellshock-like bug to exist.
Sure, bugs in OSv may still lead to code injection via the API, but the surface of attack is much smaller, and dangerous APIs can be easily disabled.
OSv still supports a CLI, but its run outside the OS, and administrators can use the secure API to access it, just like everybody else.

**More info**

For general questions on OSv, please join the [osv-dev mailing list](https://groups.google.com/forum/#!forum/osv-dev).  You can get general updates by subscribing to this blog's [feed](http://osv.io/blog/atom.xml), or folllowing [@CloudiusSystems](https://twitter.com/CloudiusSystems) on Twitter.

