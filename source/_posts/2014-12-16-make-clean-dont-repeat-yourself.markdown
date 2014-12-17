---
layout: post
title: "Image building tip: make clean without repeating yourself"
date: 2014-12-16 21:10:31 -0800
comments: true
published: true
categories: release
---

**By Don Marti**

What do we have to do in `make clean`?  Delete all the files that can be regenerated that we don't need to keep around.

What's listed in `.gitignore`?  All the files that can be regenerated that we don't need to keep around.

Hey, wait a minute. It's not a good idea to repeat yourself, especially for me, since I have to "start a project" often for demo code.  So here's a way to keep track of all those extre files in one place, with a few lines in Makefile and one handy git command.

<!--more-->

Here's the new `clean` target:

```
# Remove anything listed in the .gitignore file.
# Remove empty directories because they cannot be versioned.
clean :
        find . -path ./.git -prune -o -print0 | \
        git check-ignore -z --stdin | xargs -0 rm -f
        find . -depth -mindepth 1 -type d -print0 | \
        xargs -0 rmdir --ignore-fail-on-non-empty
```

In this case, we're just running a `find` on everything except the `.git` directory, and using the [git check-ignore](http://git-scm.com/docs/git-check-ignore) command to see if they're ignorable by git.  If the answer is yes, then they're fine to remove&mdash;so no more keeping track of them in two places.

The second `find` is just to get rid of empty directories, which Git won't track anyway.  And the `-print0`, `-z`, and `-0` options in both lines are to use null characters between filenames, just to prevent weirdness if you end up with a file with a space in its name.

(To hook your regular Makefile up to build complete VMs, just use [Capstan](http://osv.io/capstan/). Get a complete VM, ready to run on any cloud, in only 7.5 to 9 seconds.)


What, is that it?
-----------------

Fine, have a bonus tip.  If you're a fan of [What colour is it](http://whatcolourisit.scn9a.org/), the site that changes background color to match the current time, here's how to do the same thing on a GNOME desktop:

```
gsettings set org.gnome.desktop.background primary-color "#$(date +%H%M%S)"
```

(Those of you on something other than Linux+GNOME, developer desktop tips for your setup are welcome.)

*For more tips and OSv news, subscribe to this blog's [feed](http://osv.io/blog/atom.xml), or folllow [@CloudiusSystems](https://twitter.com/CloudiusSystems) on Twitter.* 

