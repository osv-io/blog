---
layout: post
title: "Using Capstan with local OSv images"
date: 2014-06-06 11:54:23 -0400
comments: true
published: true
---

**By Don Marti**

If you're building OSv from source, you can use the `capstan push` command to temporarily use a local build in place of a base image from a network repository.  This is handy when you're trying your application with a patched version of OSv.   Just run `capstan push` after the OSv build to push your newly built image into your local Capstan repository.

For example, if your Capstanfile uses the `cloudius/osv-base` base image:

```
make 
capstan push cloudius/osv-base  build/release/usr.img
```

When you're ready to go back to using the image from the network, you can run

```
capstan pull cloudius/osv-base
```

to replace the image in your local repository with the image from the network repository.

For more tips and updates, please follow [@CloudiusSystems on Twitter](https://twitter.com/CloudiusSystems).

