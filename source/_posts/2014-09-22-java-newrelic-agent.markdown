---
layout: post
title: "Adding a NewRelic agent to your OSv appliance"
date: 2014-09-24 15:22:22 -0800
comments: true
published: true
categories:  capstan tomcat newrelic
---

**By Tzach Livyatan**

[New Relic](http://newrelic.com/) is a popular real-time monitoring
service for Web and mobile applications.

In the following post I will describe how to add a New Relic
monitoring agent to your OSv virtual appliance, using [Tomcat](http://tomcat.apache.org/) as an
example.

<!-- more -->

As first step, go to the [New Relic web site](http://newrelic.com/) and log in  or open an account.  Following the instructions on the site, you should be prompted to download two files:

* newrelic.yml 
* newrelic.jar

newrelic.yml should already have the your license key in it.
If you downloaded the file
[directly](http://download.newrelic.com/newrelic/java-agent/newrelic-agent/3.10.0/newrelic.yml),
you should make sure to edit the license line.
Make sure to update your application name in the same file. This name
will be used in the New Relic GUI.


There are two ways to build an OSv appliance:

1. Using an OSv build from source
1. Using [Capstan](https://github.com/cloudius-systems/capstan)

The first requires cloning OSv source code with Git, as described
[here](https://github.com/cloudius-systems/osv-apps/tree/master/java-newrelic).
The second assumes you are familiar with [Capstan](https://github.com/cloudius-systems/capstan) and is described below.

### Using Capstan to add a NewRelic Agent

* Create a new project directory

```
mkdir my-tomcat-with-newrelic
cd my-tomcat-with-newrelic
```
* Copy newrelic.jar and newrelic.yml to this location
* Create a new [Capstanfile](https://github.com/cloudius-systems/capstan/blob/master/Documentation/Capstanfile.md) with the following contents:

```
base: cloudius/osv-tomcat

cmdline: >
  /java.so
  -javaagent:/tools/newrelic.jar
  -cp /usr/tomcat/bin/bootstrap.jar:/usr/tomcat/bin/tomcat-juli.jar
  -Djava.util.logging.config.file=/usr/tomcat/conf/logging.properties
  -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager
  -Dcatalina.base=/usr/tomcat
  -Dcatalina.home=/usr/tomcat
  -Djava.io.tmpdir=/usr/tomcat/temp
  org.apache.catalina.startup.Bootstrap
  start

files:
  /tools/newrelic.jar: newrelic.jar
  /tools/newrelic.yml: newrelic.yml
```

The base OSv image is `tomcat`, the cmdline include both Tomcat and
  New Relic options, and the files are the two New Relic files: the JAR and the configuration file.

* build the image

```
capstan build
```
You are done! you now have a ready VM with Tomcat and a New Relic agent.
To run the image locally:

```
capstan run -n bridge
```
* Go to the New Relic web app, monitor your application, and give yourself a
  pat on the shoulder :)
  
You can keep up with the latest OSv news from this blog's [feed](http://osv.io/blog/atom.xml), or by following [@CloudiusSystems](https://twitter.com/CloudiusSystems) on Twitter.  Questions always welcome on the [osv-dev](https://groups.google.com/forum/#!forum/osv-dev) mailing list.

