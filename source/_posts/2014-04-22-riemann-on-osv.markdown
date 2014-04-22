---
layout: post
title: "Riemann - a Clojure application on OSv"
date: 2014-04-22 12:00:00 -0400
comments: true
published: false
categories:  capstan tools clojure examples
---

We already have a [hello world](https://github.com/tzach/capstan-example-clojure) application running on OSv.
This time I wanted to port a real, non toy, clojure application. I
choose **Riemann**.
[Riemann](http://riemann.io) is a widely used application for
aggregating events (and more).

To port Riemann to OSv, I used [Capstan](http://osv.io/capstan/), a tool for building and running applications on OSv.
Jump to the end [result](https://github.com/tzach/riemann), or follow
the steps I took:

<!-- more -->


Following Capstan guide lines, I added a [Capstanfile](https://github.com/tzach/riemann/blob/master/Capstanfile) to
the project.
Here is the parts of Capstanfile you need to know about:

  * Set the base image. In this case I choose a base image with Java (open-jdk)
```
    base: cloudius/osv-openjdk
```

  * Build the Jar, taking advantage of lein uberjar.
```
    build: lein uberjar
```

The end result will be one fat Jar, including both Clojure and Riemann

  * Copy the build artifacts to the base image, producing a new image:
```
files:
  /riemann.jar: ./target/riemann-0.2.5-SNAPSHOT-standalone.jar
  /riemann.config: ./riemann.config
```
  
I also copy the config file, Riemann will look for it.

  * Run command for the VM
```
cmdline: /java.so -jar /riemann.jar
```

Done with the Capstanfile


**Lets test!**
```
>capstan run
WARN [2014-04-13 14:11:22,029] Thread-9 - riemann.core - instrumentation service caught
java.io.IOException: Cannot run program "hostname": error=0, vfork failed
	at java.lang.ProcessBuilder.start(ProcessBuilder.java:1041)
	at java.lang.Runtime.exec(Runtime.java:617)
	at clojure.java.shell$sh.doInvoke(shell.clj:116)
	at clojure.lang.RestFn.invoke(RestFn.java:408)
```
No luck.
Turn out, Riemann is using 
```
(sh "hostname")
```
which use vfork. On any OS its not very efficient to use fork to get
the host name - on current OSv it will simply wont work. To bypass, I replace this call with 
```
(.getHostName (java.net.InetAddress/getLocalHost))
```
which use exiting JVM property.


**Lets try again**
```sh
>capstan run
```
Seems to work, but how do I test it and connect to it? 

**Lets try again**, this time with Capstan *port forwarding*
```sh
capstan run -f 5555:5555 -f 5556:5556
``` 
This will  forward host port 5555 to OSv VM port 5555, and the same
goes for 5556.

**Success :)**

Now we can run (on different terminals)
```sh
riemann-health
``` 
to generate traffic toward Riemann
and 
```sh
riemann-dash
```
to launch a Riemann web base GUI for better visibility.
Here is how it look like:
!["Riemann GUI](/images/riemann_on_osv.png) <i>riemann-dash</i>


Please note I haven't yet soak/stress/any-non-trivial tested it beyond the above.
If you do find any problem, or have any question, do ask.
