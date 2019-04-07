---
layout: post
title: "Making OSv Run on Firecracker"
date: 2019-04-05 06:00:00 -0800
comments: true
published: true
---

**By: Waldek Kozaczuk**

**Serverless computing, a.k.a. Function-as-a-Service**

The traditional approach to implementing applications on the cloud is the IaaS (Infrastructure-as-a-Service) approach. In a IaaS cloud, application authors rent virtual machines and install their own software to run their application. However, when an application needs, for example, a database, the application writer often does not have the necessary expertise to choose the database, install it, configure and tweak it, and dynamically change the number of VMs running this database. This is where the "PaaS" (Platform-as-a-Service) cloud steps in: The PaaS cloud does not give application writers virtual machines, but rather a new platform with various services. One of these services can be a database service: The application makes database requests - could be one each second or a million each second - and does not have to care or worry whether one machine, or 1000 machines, are actually needed to provide this service. The cloud provider charges the application owner for these requests, and the amount of work they actually do.

But it is not enough that the PaaS cloud provides building blocks such as databases, queue services, object stores, and so on. An application also needs glue code combining all these building blocks into the operation which the application needs to do. So even on PaaS, application writers start virtual machines to run this glue code. Yes, again VMs and all the problems associated with them (installation, scaling, etc.). But recently, there is a trend towards a **serverless** PaaS cloud, where the application developer does **not** need to rent VMs. Instead, the cloud provides Function-as-a-Service (FaaS). FaaS implementations (such as Amazon Lambda, Google Cloud Functions or Microsoft Azure Functions), run short functions which the application author writes in high-level languages like Javascript or Java, in response to certain events. These functions in turn use the various PaaS services (such as database requests) to perform their job. The application author is freed from worrying how or where these functions are run - it is up to cloud implementation to ensure that whether one or a million of these functions need to run per second, they will get the necessary resources to do so.

## Implementation, and why OSv is a winner

How could function-as-a-service be implemented by the cloud provider?



## Epilogue
We believe that the difficulties of running code on VMs will drive more and more application developers to look for alternatives for running their code, alternatives such as Function-as-a-Service (FaaS). We already explored this and related directions in the past in [this paper from 2013](http://nadav.harel.org.il/homepage/papers/paas-2013.pdf).

We showed in this post that it makes sense to implement FaaS on top of VMs, and that OSv is a better fit for running those VMs than either Linux or other unikernels. That is because OSv has the unique combination of allowing very fast boot and instantaneous shutdowns, at the same time as being able to run the complex runtime environments we wish to support (such as Node.js and Java).

An OSv-based implementation of FaaS will support "cloud bursting" - an unexpected, sudden, increase of load on a single application, thanks to our ability to boot many new OSv VMs very quickly. Cloud bursting is one of the important use cases being considered by the MIKELANGELO project, a European H2020 research project which the authors of this post contribute to, and which is based on OSv as we previously announced.
