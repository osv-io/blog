---
layout: post
title: "Researching the future of the cloud"
date: 2015-02-02 10:54:23 -0800
comments: true
published: true
---

**By Nadav Har'El**

What will the IaaS cloud of the future look like? How can we improve the
hypervisor to reduce the overhead it adds to virtual machines? How can we
improve the operating system on each VM to make it faster, smaller, and
more agile? How do we write applications that run more efficiently and
conveniently on the modern cloud? How can we run on the cloud applications
which traditionally required specialized hardware, such as supercomputers?

![Project Mikelangelo](/images/mikelangelo.png)

Cloudius Systems, together with eight leading industry and university
partners, announced this month the [Mikelangelo](http://mikelangelo-project.eu/) research project, which
sets out to answer exactly these questions. Mikelangelo is funded by the
European Union's flagship research program, ["Horizon 2020"](http://ec.europa.eu/programmes/horizon2020/).

Cloudius Systems brings to this project two significant technologies:

The first is OSv, our efficient and light-weight operating-system kernel
optimized especially for VMs in the cloud. OSv can run existing Linux
applications, but often with significantly improved performance and lower
memory and disk footprint.

Our second contribution to the cloud of the future is Seastar, a new
framework for writing complex asynchronous applications while achieving
optimal performance on modern machines. Seastar could be used to write
the building blocks of modern user-facing cloud applications, such as
HTTP servers, object caches and NoSQL databases, with staggering
performance: Our prototype implementations already showed a 4-fold
increase in server throughput compared to the commonly used alternatives,
and linear scalability of performance on machines with up to 32 cores.

The other companies which joined us in the Mikelangelo project are
an exciting bunch, and include some ground-breaking European (and global)
cloud researchers and practicioners:

&nbsp;&bull; [Huawei](http://www.mikelangelo-project.eu/consortium/huawei/)

&nbsp;&bull; [IBM](http://www.mikelangelo-project.eu/consortium/ibm/)

&nbsp;&bull; [Intel](http://www.mikelangelo-project.eu/consortium/intel/)

&nbsp;&bull; [The University of Stuttgart's supercomputing center (HLRS)](http://www.mikelangelo-project.eu/consortium/hlrs/)

&nbsp;&bull; [The University of Goettingen's computing center (GWDG)](http://www.mikelangelo-project.eu/consortium/gwdg/)

&nbsp;&bull; [Ben-Gurion University](http://www.mikelangelo-project.eu/consortium/ben-gurion-university/)

&nbsp;&bull; [XLAB](http://www.mikelangelo-project.eu/consortium/xlab/), the coordinator of the project

&nbsp;&bull; [Pipistrel](http://www.mikelangelo-project.eu/consortium/pipistrel/), a light aircraft manufacturer

Pipistrel's intended use case, of moving HPC jobs to the cloud, is
particularly interesting. Pipistrel is an innovative manufacturer of
light aircraft that holds [several cool world records](http://www.pipistrel.si/media/achievements-and-awards), and won NASA's
2011 "Green Flight Challenge" by building an all-electric airplane
achieving the equivalent of 400 miles per gallon per passenger.
The aircraft design process involves numerous heavy numerical
simulations. If a typical run requires 100 machines for two hours,
running it on the cloud means they would not need to own 100 machines,
and rather just pay for the computer time they use. Moreover, on the
cloud they could just as easily deploy 200 machines, and finish the
job in half the time, for exactly the same price!

Last week, researchers from all these partners met to kick off the
project, and also enjoyed a visit to Ljubljana which, as its name implies,
is a lovely city. The project will span 3 years, but we expect to see some
encouraging results from the project&mdash;and from the individual partners
comprising it&mdash;very soon. The future of the cloud looks very bright!

_Visit [The Mikelangelo Project's official site](http://mikelangelo-project.eu/) for updates._

**Watch this space ([feed](http://localhost:4000/blog/atom.xml)), or follow
[@CloudiusSystems](https://twitter.com/CloudiusSystems)
on Twitter, for more links to research in progress.**

