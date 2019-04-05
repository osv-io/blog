---
layout: post
title: "Project Mikelangelo update"
date: 2016-03-08 06:00:00 -0800
comments: true
published: true
---

**By Nadav Har’El**

A year ago, we reported (see [Researching the Future of the Cloud](http://osv.io/blog/blog/2015/02/02/mikelangelo/)) that ScyllaDB and eight other industrial and academic partners started the [MIKELANGELO](https://www.mikelangelo-project.eu/) research project. MIKELANGELO is a three-year research project sponsored by the European Commission's [Horizon 2020](http://ec.europa.eu/programmes/horizon2020/) program. The goal of MIKELANGELO is to make the cloud more useful for a wider range of applications, and in particular make it easier and faster to run high-performance computing (HPC) and I/O-intensive applications in the cloud.

![company logos](http://www.scylladb.com/img/project-mikelangelo-logos.png)

Last week, representatives of all MIKELANGELO partners (see company logos above, and group photo below) met with the Horizon 2020 reviewers in Brussels to present the progress of the project during the last year. The reviewers were pleased with the project’s progress, and especially pointed out its technical innovations.

![project participants group photo](http://www.scylladb.com/img/project-mikelangelo-people.jpeg)

Represented by Benoît Canet and yours truly, ScyllaDB presented [Seastar](http://www.seastar-project.org/), our new C++ framework for efficient yet complex server applications. We demonstrated the sort of amazing performance improvements which Seastar can bring, with ScyllaDB - our implementation of the familiar NoSQL database [Apache Cassandra](http://cassandra.apache.org) with the Seastar framework. In the specific use case we demonstrated, an equal mixture of reads and writes, ScyllaDB was 7 times faster (!) than Cassandra. And we didn’t even pick ScyllaDB’s best benchmark to demonstrate  (we’d seen even better speedups in several other use cases). Seastar-based middleware applications such as ScyllaDB hold the promise of making it significantly easier and cheaper to deploy large-scale Web or Mobile applications in the cloud.

Another innovation that ScyllaDB brought to the MIKELANGELO project is [OSv](http://osv.io/), our Linux-compatible kernel specially designed and optimized for running on cloud VMs. Several partners demonstrated running their applications on OSv. One of the cool use cases was aerodynamic simulations done by [XLAB](http://www.xlab.si/) and Pipistrel. [Pipistrel](http://www.pipistrel.si/) is a designer and manufacturer of innovative and award-winning light aircraft (like the one in the picture below), and running their CFD simulations on the cloud, using OSv VMs and various automation tools developed by XLAB, will significantly simplify their simulation workflow and make it easier for them to experiment with new aircraft designs.

![Pipistrel aircraft photo](http://www.scylladb.com/img/aircraft.jpeg)

Other partners presented their own exciting developments: Huawei implemented RDMA virtualization for KVM, which allows an application spread across multiple VMs on multiple hosts to communicate using RDMA (remote direct-memory-access) hardware in the host. In a network-intensive benchmark, virtualized RDMA improved performance 5-fold. IBM presented improvements to their earlier [ELVIS](http://www.harel.org.il/nadav/homepage/papers/11760-atc13-harel.pdf) research, which allow varying the number of cores dedicated to servicing I/O, and achieve incredible amounts of I/O bandwidth in VMs. Ben-Gurion University security researchers implemented a scary “cache side-channel attack” where one VM can steal secret keys from another VM sharing the same host. Obviously their next research step will be stopping such attacks! Intel developed a telemetry framework called “snap” to collect and to analyse all sorts of measurements by all the different cloud components - VM operating systems, hypervisors, and individual applications. HLRS and GWDG, the super-computer centers of the universities of Stuttgart and Göttingen, respectively, built the clouds on which the other partners’ developments will be run, and brought in use cases of their own.

Like ScyllaDB, all partners in the MIKELANGELO project believe in openness, so all technologies mentioned above have already been released as open-source. We’re looking forward to the next year of the MIKELANGELO project, when all these exciting technologies will continue to improve separately, as well as be integrated together to form the better, faster, and more secure cloud of the future.

**For more updates, follow the [ScyllaDB blog](http://www.scylladb.com/blog/).**

