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

    # This should work on any recent version of Ubuntu, on other
    # distributions try to install the equivalent packages.
    # NOTE: You may be asked for a MySQL (database) root user password.

    sudo apt-get install \
      build-essential git-core libreadline6-dev ncurses5-dev libssl-dev \
      mysql-server-5.1 mysql-client-5.1 libmysqlclient-dev \
      libsqlite3 libsqlite3-dev bison libyaml-dev autoconf libxml2-dev\
      libxslt1-dev


    # 2. Install RVM (the Ruby Version Manager)

    # We love RVM because it...
    #   1. allows us to run different versions of Ruby side-by-side,
    #   2. manages 'gemsets' (sets of Ruby libraries), and
    #   3. automate these two by executing `.rvmrc` per project.
    # For production use read: http://beginrescueend.com/rvm/install
    # Also read this if you encounter any problems with RVM.
    # Below we install RVM for the user who runs it.
    # NOTE: We assume that user uses the 'bash' shell.

    bash -s stable < <(curl -s \
      https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)
    echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"' \
      >> ~/.bash_profile
    source .bash_profile  # reload shell
    # Now test if it installed correctly (output should be "rvm is a function"):
    type rvm | head -1


    # 3. Install Ruby using RVM

    # We develop on Ruby version '1.9.3-head' as it loads libraries (gems) much
    # faster, so that's what we install below.  Any '1.9.x' should work fine.

    rvm install 1.9.3-head  # that's all!

    # RVM uses `.rvmrc` in the root of the application to switch to a particular
    # Ruby version and gemset when entering the project directory.
    # The gemset is by default `mostfit-$VERSION` where $VERSION is the first
    # two numbers of Mostfit's version string as specified in `./VERSION`.


    # 4. Setup MySQL (the database)

    # Create 2 databases 'mostfit_dev' and 'mostfit_test', grant all priviledges
    # to user 'mostfit' (password: 'secret') on both.
    # Later we copy these credentials into Mostfit's database configuration.
    # NOTE: You will be asked twice for the MySQL root user password.

    for db in mostfit_dev mostfit_test; do mysql -u root -p -e " \
      CREATE DATABASE IF NOT EXISTS ${db}; \
      GRANT ALL ON ${db}.* TO mostfit@'localhost' IDENTIFIED BY 'secret'; \
      FLUSH PRIVILEGES;"; done


    # 5. Download and install Mostfit (soo easy!)

    # We use 'git' (a source code management tool) to download Mostfit.  The
    # developers of Mostfit use this tool to collaborate, but it is also useful
    # to upgrade to newer versions of Mostfit while preserving modifications.
    # NOTE: `-b $BRANCH_NAME` may be omitted when installing the master branch.
    git clone https://github.com/Mostfit/mostfit.git -b $BRANCH_NAME

    # Move to the 'application root', this triggers the `.rvmrc` script:
    cd mostfit  # if RVM works you should see some output on this command

    # Download all application dependencies with:
    bundle install

    # Set database credentials (as configured in step 4):
    cp config/example.database.yml config/database.yml
    $EDITOR config/database.yml  # with me `echo $EDITOR` returns "vi"


    # 6. Now take it out for a spin...

    # Seed the database with some test data (something to look at):
    bin/seed.rb

    # Start the web-application (uses Passenger and binds to port 3000)...
    # And point a browser on the same machine to: http://0.0.0.0:3000
    # NOTE: The 1st time it is run Passenger installs all it needs from source.
    passenger start

    # Explore Mostfit's internals using the console interface by invoking:
    merb -i

    # Mostfit comes with many scripts, known as 'tasks'...
    bin/rake -T      # list all tasks
    bin/rake routes  # invokes `routes` task (lists all known routes)


