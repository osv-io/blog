---
layout: post
title: "Running Clojure on OSv: easier with a new Capstan template"
date: 2014-07-27
comments: true
published: false
categories:  java clojure lein
---

Clojure developers usually do not care too much about the underlying OS.
The low-level differences between Linux, Mac OS, and even Microsoft Windows are abstracted away by the JVM.

When deploying Clojure code on the cloud, there used to be one default choice - Linux.
But Linux
[is not an ideal OS](http://osv.io/blog/blog/2014/07/21/generic-os-is-dead/)
for pure cloud services.

[OSv](https://github.com/cloudius-systems/osv) is a new, open source OS, designed specifically for the cloud.  Since OSv supports the standard JVM, it is ideal for running Clojure applications on the cloud.  And the same configuration applies to building VMs for any cloud: public clouds such as Amazon's and Google's, private clouds based on VMware or KVM, or public and private OpenStack.

Porting a Clojure application to OSv was already
[pretty easy](http://osv.io/blog/blog/2014/04/22/riemann-on-osv/), but
now it's even easier.  This blog post describes a new [lein template](https://github.com/tzach/capstan-lein-plugin) for OSv.
<!-- more -->

## Usage

Capstan works together with the [Leinigen](http://leiningen.org/) build tool.

First, create a new project skeleton.
```
lein new capstan new-app
```

Now, you can run [Capstan](https://github.com/cloudius-systems/capstan) to 
run your project on an a OSv VM.

```
cd new-app
capstan run
```

The template takes care of creating the project skeleton, including the Capstanfile.  When this is done, you can use Capstan directly to build a new OSv VM, deploy it on the cloud, or upload it to the public repository.

<script type="text/javascript" src="https://asciinema.org/a/11068.js"
id="asciicast-11068" async="" data-speed="2" data-autoplay="1"
ata-size="medium"></script></p>


For more info on Capstan and other OSv subjects, please join
the
[osv-dev mailing list](https://groups.google.com/forum/#!forum/osv-dev).  
You can get updates on by subscribing to the [OSv blog RSS feed](http://osv.io/blog/atom.xml) or following [@CloudiusSystems](https://twitter.com/CloudiusSystems) on Twitter.
