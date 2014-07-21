---
layout: post
title: "If Java Application Servers Are Dead, So is the Operating System (in the cloud)"
date: 2014-07-21
comments: true
published: false
categories:  java AS
---

**By Tzach Livyatan**
This post is a response to the excellent presentation [**"Java Application Servers Are Dead!"**](http://www.slideshare.net/ewolff/java-application-servers-are-dead) by [Eberhard Wolff](https://twitter.com/ewolff).
Go read his slides and come back here.


back already?
Assuming you agree with Eberhard’s  claims,  let me demonstrate how
most of his points on Java Application Servers can be applied to a
generic OS.
<!-- more -->

First let me scope the discussion.
An operating system can run on your mobile, desktop, back office, or as a VM on the cloud.
For this post, I’m referring specifically to the last use case, which can be public or private.
Cloud deployments are the important case to concentrate on, as new Java application servers are mostly deployed on VMs these days.

![turtles all the way down](/images/turtles-all-the-way-down.png)
From http://religion.ua.edu/blog/2012/09/turtles-all-the-way-down/

Eberhard present different properties of the Java Application Server, and for each, demonstrates why it is no longer relevant. 
I will follow his footsteps, applying the same methodology to generic
OS, for two of the properties: Container for multiple application and Deployment.

## Container for multiple application
Both the Java application server and the OS are supposed to isolate applications from each others. Both do a good job at it, and OS isolation is definitely somewhat stronger.  However, it is still not good enough for multitenancy, [even with containers](http://osv.io/blog/blog/2014/06/19/containers-hypervisors-part-2/).
This is why we have hypervisors, and this is why most deployment in the clouds include one application per VM.
 
## Deployment
I agree with Eberhard’s claim that Java deployments (JAR, WAR, EAR) are problematic.
Linux-style packaging, using RPM or deb packages, is not a full solution either.

In a cloud environment, there is no reason to start with a blank OS, and spend 15 minutes downloading and installing the application. It makes more sense to use a pre-installed server image (AMI, in AWS terms) with the application already installed. Indeed, using a ready-made AMI is a common practice.

Containers are another successful attempt to fix this problem, but running containers on a virtual machine brings an extra layer of complexity. More on that [here](http://osv.io/blog/blog/2014/06/19/containers-hypervisors-part-1/). Obviously, there is still a requirement to install urgent patches on both AMI and containers.

To summarize, both the  Java application server and the generic OS were created to provide a set of services which is no longer required.

## With Java AS and generic OS dead, what's next?
** Micro Services **

*"an approach to developing a single application as a suite of small
 services, each running in its own process and communicating with
 lightweight mechanisms, often an HTTP resource API"*
[Martin Fowler](http://martinfowler.com/articles/microservices.html)
!["From micro services](/images/PreferFunctionalStaffOrganization.png)
From Martin Fowler http://martinfowler.com/articles/microservices.html

Each micro service can can have its own end to end stack, from the OS up to the application.
As explained above, an idle scenario will be to deploy the micro service logic directly on a Hypervisor, cutting two middle layers: the application server and the generic OS.

At this point you might doubt my sanity.
Run my application on EC2 with no OS to support it? Not quite. 

As you recall from the “AS are dead” presentation, the application server has become an application library, dedicated to supporting a single application. With the Library OS concept, the the same process is apply to the OS, making it a library of the application.

For every micro service, one can use a tool like
[Capstan](http://osv.io/capstan) to cook a new VM, pre integrating the
application, JVM and the OS - to a ready to be deployed VM. Just take
it and deploy it on your favorite cloud provider.

Take Capstan for a [spin](http://osv.io/run-locally/)


For more info on Capstan and other OSv subjects, please join
the
[osv-dev mailing list](https://groups.google.com/forum/#!forum/osv-dev).  
You can get updates on by subscribing to the [OSv blog RSS feed](http://osv.io/blog/atom.xml) or following [@CloudiusSystems](https://twitter.com/CloudiusSystems) on Twitter.
