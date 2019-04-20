---
layout: post
title: "SSH tip: connecting to a private network without trusting the bastion host"
date: 2014-11-17 14:10:31 -0800
comments: true
published: true
categories: release
---

**By Nadav Har'El**

In a typical lab network configuration, one cannot just `ssh` or `scp` to the hosts behind the firewall (our company calls them after characters from Norse mythology: Loki, Muninn and friends).  Instead, you need to ssh to a bastion host, and from there connect to the internal systems. 

![ssh user](/images/ssh-user.jpeg)<br>*an ssh user connecting using a bastion host*

One can automate these two steps, with a command like

```
    ssh -t bastion.example.com ssh loki.lab.example.com
```

And I guess some of you are already doing that. But this only works for ssh, not scp. One can do scp through an "ssh tunnel", but this is really ugly to set up every time and to use.

There is also a securty hole in this approach, because anyone who breaks into `bastion` (which is an external machine and thus exposed to the Internet) can then ssh from there to all the internal machines, or even hijack already-running ssh sessions.

I finally found a much better solution, much easier to use and much more secure.

<!--more-->

Just add to your `~/.ssh/config` the following incantation:

```
Host *.lab
        ProxyCommand ssh -q bastion.example.com nc `basename %h .lab` 22
```

And now, you can `ssh` or `scp` directly to `loki.lab`, or `muninn.lab` or whatever, without any hassles, as if Loki and Muninn are actual machines on your LAN.

This trick works like this: To connect to the remote host, ssh normally just connects a socket to port 22 of the remote host. When the "ProxyCommand" is set, this command is used instead. The command above will ssh to `bastion.example.com` and from there connect (using `nc`) to loki's port 22. Your own ssh will do the ssh protocol with Loki over this connection.

This solution, beyond being extremely convenient, also has an interesting security feature:  we'll no longer need to trust `bastion.example.com`. The classic "ssh from your laptop to `bastion` to `loki`" solution suffered from a problem that if someone broke into `bastion`, they could also break into `loki` - by using the private keys stored on `bastion`, or by hijacking the second leg of the ssh chain (and possibly injecting whatever commands it wanted into this session!). With this new solution, `bastion` is just acting as a stupid pipe for encypted data between my laptop and Loki - it cannot hijack the connection, and it doesn't have any private keys needed to initiate a connection to Loki on its own.

For more tips and OSv news, subscript to this blog's [feed](http://osv.io/blog/atom.xml), or folllow [@CloudiusSystems](https://twitter.com/CloudiusSystems) on Twitter. 

**Photo:** [Security Hacker](http://www.flickr.com/photos/dfectuoso17/7013054091/) by Santiago Zavala
