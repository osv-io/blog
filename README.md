OSv/blog
====

This project holds the source for [blog.osv.io](blog.osv.io)


blog.osv.io is base on [Octopress](octopress.org) and deployed on Github [Project pages](http://octopress.org/docs/deploying/github/)


This means: 
* blog source are on branch **source**
* blog generated HTML/CSS are under branch **gh-pages**

### Update the blog

1. `git clone https://github.com/osv-io/blog.git`
2. `cd blog`
3. `git checkout source`
4. `rake setup_github_pages`
     Repository url: https://github.com/osv-io/blog.git
5. do the changes, additions (see below)
6. `rake generate`   # Generates posts and pages into the public directory
7. `rake preview`    # Watches, and mounts a webserver at http://localhost:4000
8. `rake deploy`     # upload the generated site to branch **gh-pages**


In a case you have *"Updates were rejected because the tip of your
current branch is behind" on the deploy"* error on deploy, you can
bypass it with the following steps before you generate the site (step
6 above):

1. `cd _deploy`
2. `git pull origin gh-pages`
3. `cd ..`

### How to add a new post / update a post?
http://octopress.org/docs/blogging/
