OSv/blog
====

This project holds the source for [osv.io/blog](http://osv.io/blog)

This blog is based on [Jekyll](https://jekyllrb.com/docs/posts/) and deployed on Github [Project pages](https://pages.github.com/).

This means: 
* blog source are on branch **source**
* blog generated HTML/CSS are under branch **gh-pages**

**Do not commit to the gh-pages branch. It is re-generated automatically on each deploy.**


### Checking out the blog for the first time

Check out the `source` branch and update dependencies.

```
git checkout source
bundle install
```

You only need to do this once.


### Update the blog

1. `git clone https://github.com/osv-io/blog.git`
2. `cd blog`
3. `git checkout source`
4. `rake setup_github_pages`
     Repository url: https://github.com/osv-io/blog.git or your clone
5. do the changes, additions (see below)
6. `rake generate`       # Generates posts and pages into the _site directory
7. `rake preview`        # Watches, and mounts a webserver at http://localhost:4000/blog
8. `rake deploy_private` # Upload the generated site to branch **gh-pages** of your clone
9. `rake deploy`         # Upload the generated site to branch **gh-pages**

### Update the blog source
The above process only update the **gh-pages** branch.
Once publishing done, remember to commit your source update to the
source branch!

*Without this, your changes will be lost when someone else update the blog.*

### Suggest updates without publishing

1. Fork the blog 
2. Execute steps 1-7 above
3. Send a [GitHub Pull Request](https://help.github.com/articles/using-pull-requests) to the **source** branch.

### How to add a new post / update a post?
https://jekyllrb.com/docs/step-by-step/08-blogging/


