---
layout: post
title: "Riemann - a Clojure application on OSv"
date: 2014-04-22 12:00:00 -0400
comments: true
published: true
categories:  capstan tools clojure examples
---

**By Tzach Livyatan**

Clojure applications run on the JVM, so they're usually simple to run on OSv.  We have [hello world in Clojure](https://github.com/tzach/capstan-example-clojure) running, but this time I wanted to port a real, non-toy, Clojure application. I chose [Riemann](http://riemann.io), a widely-used application for aggregating system events (and more).

I used [Capstan](http://osv.io/capstan/), a tool for building and running applications on OSv.  Jump to the end [result](https://github.com/tzach/riemann), or follow the steps I took:

<!-- more -->


Following the Capstan guideline, I added a [Capstanfile](https://github.com/tzach/riemann/blob/master/Capstanfile) to the project.  Here are the parts of Capstanfile you need to know about:

  * Set the base image. In this case I chose a base image with Java (open-jdk)
```
    base: cloudius/osv-openjdk
```

  * Build the jar file, taking advantage of the `lein uberjar` command, which packages the application with all dependencies into one jar file.

```
    build: lein uberjar
```
  * Copy the build artifacts to the base image, producing a new image:
```
files:
  /riemann.jar: ./target/riemann-0.2.5-SNAPSHOT-standalone.jar
  /riemann.config: ./riemann.config
```
  
I also copy the config file, which Riemann will look for.

  * The run command for the VM is executed when the VM starts.
```
cmdline: /java.so -jar /riemann.jar
```

That's it. Done with the Capstanfile.


**Let's test it!**
```
>capstan run
WARN [2014-04-13 14:11:22,029] Thread-9 - riemann.core - instrumentation service caught
java.io.IOException: Cannot run program "hostname": error=0, vfork failed
	at java.lang.ProcessBuilder.start(ProcessBuilder.java:1041)
	at java.lang.Runtime.exec(Runtime.java:617)
	at clojure.java.shell$sh.doInvoke(shell.clj:116)
	at clojure.lang.RestFn.invoke(RestFn.java:408)
```
No luck.  It turns out that Riemann is using 
```
(sh "hostname")
```

which uses vfork to run a child process. On any OS its not very efficient to fork just to get the hostname, and on current OSv it simply won't work. To bypass the problem, I replace this call with:

```
(.getHostName (java.net.InetAddress/getLocalHost))
```
which uses a Java `getHostName`.


**Let's try again**
```sh
>capstan run
```
This time it works, but how do I test it and connect to it? 

**Let's use Capstan port forwarding**
```sh
capstan run -f 5555:5555 -f 5556:5556
``` 
This will  forward host ports 5555 and 5556 to the corresponding ports on the OSv VM.

**Success :)**

Now we can switch to another terminal and run:
```sh
riemann-health
``` 
to generate traffic for Riemann
and 
```sh
riemann-dash
```
to launch a Riemann web GUI.  Here is how it looks:

!["Riemann GUI](/images/riemann_on_osv.png) <i>riemann-dash</i>

Now we're ready to do further stress testing.  If you do find any problem, or have any question, you're invited to join the [osv-dev list](https://groups.google.com/forum/#!forum/osv-dev) and ask, or post an issue to the [GitHub repository](https://github.com/tzach/riemann).

&mdash; [Tzach Livyatan](https://twitter.com/TzachL)

