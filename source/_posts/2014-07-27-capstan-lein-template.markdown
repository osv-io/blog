---
layout: post
title: "Running Clojure on OSv: easier with a new Capstan template"
date: 2014-07-27
comments: true
published: false
categories:  java clojure lein
---

Clojure developers usually do not care too much about the underline OS.
Different between Linux, Mac and even Windows is abstract away by the JVM.

When deploying Clojure code on the cloud, there used to be one alternative - Linux.
But Linux
[is not an idle](http://osv.io/blog/blog/2014/07/21/generic-os-is-dead/)
OS for cloud services.

[OSv](https://github.com/cloudius-systems/osv) is a new, open source OS design specifically for the Cloud.
Since OSv support the standard JVM, it is idle for running Clojure application on the Cloud.

Porting Clojure app to OSv was already
[pretty easy](http://osv.io/blog/blog/2014/04/22/riemann-on-osv/), but
now its even easier with a new [lein template](https://github.com/tzach/capstan-lein-plugin)
<!-- more -->

## Usage
create a new project skeleton
```
lein new capstan new-app
```

run your project on a OSv image
```
cd new-app
capstan run
```

The template take care of creating the project skeleton, including the Capstan file.
Once you did, you can use capstan directly to build a new OSv VM, deploy it on the cloud, or upload it to the public repository.

<script type="text/javascript" src="https://asciinema.org/a/11068.js"
id="asciicast-11068" async="" data-speed="2" data-autoplay="1"
ata-size="medium"></script></p>


For more info on Capstan and other OSv subjects, please join
the
[osv-dev mailing list](https://groups.google.com/forum/#!forum/osv-dev).  
You can get updates on by subscribing to the [OSv blog RSS feed](http://osv.io/blog/atom.xml) or following [@CloudiusSystems](https://twitter.com/CloudiusSystems) on Twitter.
