---
layout: post
title: "Containers, containers, containers! More options for the cloud"
date: 2014-12-02 14:10:31 -0800
comments: true
published: true
categories: release
---

**By [Dor Laor](https://twitter.com/DorLaor/)**

Everybody who uses containers has probably heard about [Rocket](https://coreos.com/blog/rocket) by know. What does this <strike>fork</strike> re-implementation mean to the Docker community? Let’s dive in.

The Docker technology has disrupted the cloud and datacenter field for the past year. The speed of penetration was amazing and unmatched in the industry. I can’t think of a similar case for such fast-paced adoption of the concept. Neither AWS, OpenStack, nor virtualization were adopted that fast. What made it that attractive for our community to adopt?

Container technology was there for a lot of years. Even before containers, there has always been similar functionality, like Unix’s `chroot`. However, Docker really changed the game with straightforward simplicity and usability. Docker contributed the following:

 1.  A basic one-liner command line: `docker run`. It masked out all of the LXC complexities and even downloaded the image if needed.

 2. Straightforward image structure: It’s as simple as a directory.

 3. A public image repository, [Docker Hub](https://hub.docker.com/), where you can stash your images for future download, and employ an application-market concept.

Docker had become the hottest thing in tech, sometimes way too hot for reality (otherwise, why would one deploy Docker in a VM, incurring two tiers of management pain?). Beyond Google and AWS, even mighty Microsoft wanted a piece of the pie. We couldn’t believe our eyes, what an amazing meritocracy (no sarcasm). All the vendors of the world unite around one simple format.

![](/images/meritocracy.png)

Yesterday CoreOS released a fork-like bomb in the form of Rocket. The reason 
is the very thing that makes Docker attractive, its simplicity, is also a disadvantage since it’s too complex to harness for security, SLA and diverse workloads.  Apparently CoreOS didn’t manage to get the Docker team to change the mainline code for it.  I guess it’s more than a NIH thing (Not Invented Here) but some limitation of its structure.

![](/images/fight-time.png)

This container diversity was expected although it saddens me to see it become an ugly fight:

![Twitter thread](/images/docker-thread.png)


We believe that CoreOS has the upper hand when it comes to technology. Managing containers is straightforward, but these folks have the vehicle for deploying them. In addition they wrote cool distributed tools such as `etcd` and `fleet`. So while Docker controls the hub and the format, CoreOS leverages it to gain actual users (PR aside...)

There is nothing to fear about Docker momentum, but it has finally met a reality factor and such competition is positive for innovation and speed as well. With all the fuss around Docker, lots of good features like LXC SLA, and buildpacks (the way Heroku and Cloud Foundry handle them) were dropped in the race for Docker compatibility. It was a nice surprise to see that great minds think alike, and just as Rocket uses [several phases](https://github.com/coreos/rocket) in container creation, we do the same for OSv. We create an image by spinning up an empty VM (on any given hypervisor) that formats our ZFS filesystem and afterwards listens on ‘nc’ (netcat) to receive a stream of files from the host.

One of the best things about OSv is that we enjoy the best of all worlds. On one hand, we are a library OS, as small as a single container, usually just a kernel, a runtime and an app. An OSv VM can weigh only 20MB, smaller than most containers. On the other hand, we leverage all of the hypervisor features, including live migration, multiple guest kernels on the same host, resource hotplug, isolation, SLA and more.

Let the battle continue as we collect the best of breed features and embrace them as we’ve done with [Capstan](http://osv.io/capstan/), with our [cloud-init integration](http://osv.io/blog/blog/2014/08/28/wiki-watch-cloud-init/), with our [RESTful APIs](http://osv.io/manageability/) and more.
 
*For the latest cloud and OSv news, subscript to this blog's [feed](http://osv.io/blog/atom.xml), or follow [@CloudiusSystems](https://twitter.com/CloudiusSystems) on Twitter.*
