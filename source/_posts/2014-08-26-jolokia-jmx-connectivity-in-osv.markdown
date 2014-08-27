---
layout: post
title: "Jolokia JMX connectivity in OSv"
date: 2014-08-26 16:11:20 +0200
comments: true
published: false
categories: 
---
**By Calle Wilund**

OSv is a great way to run Java applications in the cloud, and it recently became just a little bit better. As you are probably aware, OSv exposes quite a bit of information and manageability options through its [RESTful API](https://github.com/cloudius-systems/osv/wiki/The-RESTful-API), accessible through the built-in http server for this purpose. More or less from its inception, this API has exposed various aspects of the JVM and the [Java Management Beans](http://docs.oracle.com/javase/7/docs/technotes/guides/jmx/) provided. 

Recently we improved on this a bit by including the [Jolokia](http://www.jolokia.org/) JMX-via-json-REST connector, providing full read/write access to the entire set of Java manageability attributes and operations. Now you no longer need to set up and secure separate JMX-over-rmi connectivity with your Java application to fully manage it. 

The Jolokia API is available via the OSv REST server at `http[s]://<OSv host>:<port>/jolokia`. You can explore this and other API:s via the [Swagger UI](https://github.com/cloudius-systems/osv/wiki/The-RESTful-API#using-the-swagger-ui).
For a better understanding of the full [Jolokia syntax](http://www.jolokia.org/reference/html/protocol.html), I suggest reading through the [reference manual](http://www.jolokia.org/reference/html/index.html), but in its simplest form, querying a Java Management Bean value from an OSv instance can be done like this:

```
> curl http://<ip>:<port>/jolokia/read/java.lang:type=Memory/HeapMemoryUsage
```
With the result in something like:
```javascript
{	
	"timestamp"	:1409065190,
	"status"	:200,
	"request"	: {
			"mbean"		:"java.lang:type=Memory",
			"attribute"	:"HeapMemoryUsage",
			"type"		:"read"
			},
	"value"		: {
			"max"		:1839202304,
			"committed"	:1839202304,
			"init"		:1918894080,
			"used"		:192117128
			}
}
```

Jolokia provides a full syntax for packaging JMX bean information inside json objects, including the ability to batch requests, and also provides client connector libraries for [Java](http://www.jolokia.org/client/java.html), [Perl](http://www.jolokia.org/client/perl.html) and [Javascript](http://www.jolokia.org/client/javascript.html) to access them easily from (web) applications. 

##Important note about REST requests and browser security:
Most browsers today enforce that resources such as REST queries may only be made to the same domain as the requesting web page. When you want to allow [cross-domain requests](http://www.w3.org/TR/cors/) you need to either turn of this security feature in your browser (for Google chrome you can run it with `--disable-web-security`, however if you use Firefox I do not know of any way to do it), or enable CORS in OSv.

To do the latter, you need to provide a httpserver configuration section in your [cloud init](https://github.com/cloudius-systems/osv/wiki/Cloud-init) settings. To simply allow all domains to make requests to the OSv APIs, add this to your configuration:

```yaml
httpserver:
    access-allow: '*'
```
And make this reachable through your cloud-init server. (Or use the ec2 simulator script provided with OSv)

## A small demo
A small demo Javascript application showing how to easily plot various JVM graphs from a running OSv instance can be found at [https://github.com/elcallio/jolokia-demo](https://github.com/elcallio/jolokia-demo) (which in turn is a modified fork of the [Jolokia demo](https://github.com/nurkiewicz/token-bucket) created by Tomasz Nurkiewicz.

To test the demo, simply clone the repository and edit the <a name="osvhost">`src/js/osvhost.js`</a> to match the ip and port where your OSv instance is reachable at. (Don't forget to make sure that your OSv image includes the HTTP server).



Since I am runnning OSv compiled from source, I simply go to my OSv source tree and type:

```
> make image=httpserver,mgmt
```
*...<chug, chug, chug>*
And when it is done:
```
> ./scripts/run.py --api
```

This will build and start an almost empty image, containing only the HTTP server, [cloud init support](https://github.com/cloudius-systems/osv/wiki/Cloud-init) and the Java-based shell (not a very interesting appliance, I admit, but you can pick any image you prefer). Running like this, the REST API is available from `http://localhost:8000`, so this is what I enter into [`src/js/osvhost.js`](#osvhost).

Then load the `jolokia-demo/src/index.html` in your favourite browser, and you should be greeted by this:

![screenshot](/images/jolokia-demo.png)

As you can see, the demo provides the start of a small management console for Java with just a few lines of Javascript code, most of which actually deal with setting up the charts. Requesting and polling the actual data on the other hand is almost ridiculously easy.  

Having Jolokia integrated in the OSv manageability layer means that not only can you access all the JMX attributes parallel with the rest of the exposed OSv aspects, not having to modify Java appliances, and last but not least that you only need to deal with [securing a single service point](https://github.com/cloudius-systems/osv/wiki/The-RESTful-API#configuring-ssl). 

This is just one small aspect of all the new and exciting manageability features that are in or coming to OSv. Over the next few months we hope to bring you additional aspects that will further enhance your deployment experience. Stay tuned. 

