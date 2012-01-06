INSTALLING
==========

This document describes how to quickly install Mostfit (the branch that you are looking at).

Both `rvm` and `bundler` are employed to do so.

This is not a copy-paste script for a clean install of Ubuntu -- I warned you!



##  Let's get it on...

I heard that I was doing it wrong, so here my second attempt.  This seems to work nicely.

    rvm install 1.9.3-head  # we develop on 1.9.3 for gem load speed-ups
    rvm gemset create mostfit_gems
    rvm use 1.9.3-head@mostfit_gems
    rvm rubygems 1.8.12  # most current at time of writing

    git clone https://github.com/Mostfit/mostfit.git
    cd mostfit
    # git co $BRANCH_NAME  # in case the branch is other then master

    gem update rake  # get the latest
    gem install bundler --pre  # --pre (=1.1) gives huge speedups

    bundle install  # go call some family, or read hackernews!

    cp config/example.database.yml config/database.yml
    $EDITOR config/database.yml  # with me `echo $EDITOR` returns "vi"

    bundle exec merb -i  # for the console
    bundle exec merb     # for the webapp
