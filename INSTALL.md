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

    # 1. Install Mostfit's dependencies
    # This should work on any recent version of Ubuntu, for other
    # distributions try to install the equivalent packages.
    # NOTE: We install both MySQL and Sqlite, feel free to pick.

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


    # 3. Install Ruby using RVM
    # We develop on 1.9.3-head for gem load speed-ups. Pretty straight forward.
    # Errors here usually will hint a missing dependency.

    rvm install 1.9.3-head
    rvm gemset create mostfit_gems
    rvm use 1.9.3-head@mostfit_gems
    rvm rubygems 1.8.12  # most current at time of writing
    gem install ruby-debug19 -- --with-ruby-include= \
      $rvm_path/src/ruby-1.9.3-head/  # should point to source just installed


    # 3. Setup MySQL
    # Here we setup: db=mostfit_dev, user=mostfit, password=secret
    # You will be asked for the password of MySQL's root user.

    mysql -u root -p -e " \
      CREATE DATABASE IF NOT EXISTS 'mostfit_dev'; \
      GRANT ALL ON mostfit_dev.* TO 'mostfit'@'localhost' IDENTIFIED BY 'secret'; \
      FLUSH PRIVILEGES;"


    # 4. Install Mostfit (soo easy!)

    git clone https://github.com/Mostfit/mostfit.git
    cd mostfit
    # git co $BRANCH_NAME  # in case the branch is other then master

    gem install bundler --pre  # --pre (=1.1) gives huge speedups
    bundle install  # installs all application-level dependencies

    # set database credentials
    cp config/example.database.yml config/database.yml
    $EDITOR config/database.yml  # with me `echo $EDITOR` returns "vi"


    # 5. And take it out for a spin...

    bundle exec merb -i  # for the console
    bundle exec merb     # for the webapp



