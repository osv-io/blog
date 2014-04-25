#!/usr/bin/bash -e

which bundle > /dev/null
which rake > /dev/null
which git > /dev/null

echo -n "On branch "
git branch | grep '^*'

bundle exec rake generate
bundle exec rake preview

