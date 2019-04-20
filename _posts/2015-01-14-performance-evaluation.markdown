---
layout: post
title: "Unikernel research at the University of Utah"
date: 2015-01-14 15:54:23 -0800
comments: true
published: true
---

Ian Briggs, Matt Day, Eric Eide, Yuankai Guo, and
Peter Marheine are conducting performance research
on unikernels, and have thoughtfully posted some
preliminary work on OSv performance.

The team tested OSv for DNS and HTTP, and got some
encouraging results.

[![HTTP server comparison](/images/http-server-benchmark.png)](/images/http-server-benchmark.png)

The lighttpd web server on OSv performs consistently
well up through 5000 requests/second.  And on DNS
tests, Linux can sustain a response rate of about
19000 per second, while OSv can handle approximately 28000 requests per second, with slightly
lower latency.

The preliminary paper is
[Performance Evaluation of OSv for Server
Applications](http://www.cs.utah.edu/~peterm/prelim-osv-performance.pdf)
([local copy](/images/prelim-osv-performance.pdf)).

The researchers did run into a bug running OSv
on Xen, so we're all looking forward to helping
them track that down on the [osv-dev mailing
list](https://groups.google.com/forum/#!forum/osv-dev).
In the meantime, watch this space, or follow
[@CloudiusSystems](https://twitter.com/CloudiusSystems)
on Twitter, for more links to OS research in progress.

