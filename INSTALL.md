INSTALLING
==========

This document describes how to quickly install Mostfit (the branch that
you are looking at).  Both `rvm` and `bundler` are employed to do so.

We mostly use Ubuntu, so this guid sort of assumes that.  It should be
trivial to adjust this to work for other distributions.  You can install
Mostfit in an infinite number of configurations, we have simply setteled
with this approach as it fits our needs.

This is not a copy-paste script for a clean install of Ubuntu -- at
least I warned you :)



##  Let's get it on...

    # 1. Install Mostfit's system dependencies

    # This should work on any recent version of Ubuntu, for other
    # distributions try to install the equivalent packages.

    sudo apt-get install \
        build-essential git libreadline6-dev ncurses5-dev libssl-dev \
        mysql-server-5.1 mysql-client-5.1 libmysqlclient-dev \
        libsqlite3 libsqlite3-dev


    # 2. Install RVM (Ruby Version Manager)

    # We love RVM because:
    #   - it allows us to run different versions of Ruby side-by-side
    #   - nicely keep and switch 'gemsets' (sets of Ruby libraries)
    #   - helps installing exotic Ruby (for fun-and-profit)
    # For production use read: http://beginrescueend.com/rvm/install
    # Also read this if you encounter any problems with RVM.
    # The follwoing will install RVM for the user who runs it...
    # NOTE:  We assume the user uses the 'bash' shell.

    bash -s stable < <(curl -s \
      https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)
    echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"' \
      >> ~/.bash_profile
    source .bash_profile  # reload shell
    # now test it installed correctly (should output: "rvm is a function"):
    type rvm | head -1


    # 3. Install Ruby and essential tools using RVM

    # We develop on 1.9.3-head for gem load speed-ups. Pretty straight forward.
    # Errors here usually will hint a missing dependency.

    rvm install 1.9.3-head
    rvm gemset create mostfit_gems
    rvm use 1.9.3-head@mostfit_gems
    rvm rubygems 1.8.15  # most current at time of writing
    gem install bundler -v 1.0
    # Or install v1.1.rc with `gem install bundler --pre` for speedups.

    # This gets debugging to work well on recent versions of Ruby.
    # From: http://blog.wyeworks.com/2011/11/1/ruby-1-9-3-and-ruby-debug
    (cd /tmp; \
      BASE_URL="http://rubyforge.org/frs/download.php"; \
      INCLUDE="--with-ruby-include=$rvm_path/src/ruby-1.9.3-head"; \
      wget $BASE_URL/75414/linecache19-0.5.13.gem; \
      wget $BASE_URL/75415/ruby-debug-base19-0.11.26.gem; \
      gem install linecache19-0.5.13.gem --no-ri --no-rdoc -- $INCLUDE; \
      gem install ruby-debug-base19-0.11.26.gem --no-ri --no-rdoc -- $INCLUDE; )


    # 4. Setup MySQL

    # Here we setup: db=mostfit_dev, user=mostfit, password=secret
    # You will be asked for the password of MySQL's root user.

    mysql -u root -p -e " \
      CREATE DATABASE IF NOT EXISTS 'mostfit_dev'; \
      GRANT ALL ON mostfit_dev.* TO 'mostfit'@'localhost' IDENTIFIED BY 'secret'; \
      FLUSH PRIVILEGES;"


    # 5. Download and install Mostfit (soo easy!)

    git clone https://github.com/Mostfit/mostfit.git
    cd mostfit
    # When installing a git branch other then master do `git co $BRANCH_NAME`
    bundle install  # installs application dependencies

    # Set database credentials:
    cp config/example.database.yml config/database.yml
    $EDITOR config/database.yml  # with me `echo $EDITOR` returns "vi"


    # 6. And take it out for a spin...

    bundle exec merb -i  # for the console
    bundle exec merb     # for the webapp



