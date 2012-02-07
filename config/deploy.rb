# This file contains the configuration for `vlad` our deploy tool.

# Good info on vlad:
# http://blog.js.hu/2011/02/18/make-deployments-even-more-robust/
# http://effectif.com/articles/deploying-merb-with-vlad
# http://beginrescueend.com/integration/passenger
# http://hitsquad.rubyforge.org/vlad/doco/getting_started_txt.html
# http://hitsquad.rubyforge.org/vlad/doco/variables_txt.html

# RVM and vlad can bite (see js.hu post), but I have tried to fix this
# by having puppet to setup /etc/bash.bashrc on our ubuntu app servers.

# Vlad needs 'ssh key forwarding' to work in order to use git:
#  * run `ssh-agent` with the github identity added (`ssh-add`)
#  * set `ForwardAgent yes` for one or all hosts `~/.ssh/config`
#  * set `AllowAgentForwarding yes` on the servers (automated by puppet)
#  * ensure no `ssh-agent` processes are automatically run on servers
#  * use the same logins and keypairs will simply your setup

# TROUBLE SHOOTING
# ================
#
# Usually the error message is clear and visible on the stdout.
# A few common errors that are a bit harder to crack are explain below:

# This hints that ssh key forwarding is not setup properly
#   Host key verification failed.
#   Initialized empty Git repository in [...]


set :domain,      "detroit.emfiniti.com"
set :repository,  "git@git.mostfit.in:mostfit.git"
set :git_branch,  "update"
set :revision,    "origin/#{git_branch}"
set :deploy_to,   "/var/www/mostfit/#{git_branch}"


# refactor into:
# task :demo do
#   set :domain,    "detroit.emfiniti.com"
#   set :deploy_to, "/var/www/mostfit/update"
# end

# task :staging do
#   set :domain,    "staging.emfiniti.com"
#   set :deploy_to, "/var/www/mostfit/staging"
# end

require 'bundler/vlad'  # adds vlad:bundle:install

#Rake.clear_tasks("vlad:stop", "vlad:start", "vlad:update")

namespace :vlad do

  remote_task :bundle do
    cmds = []

    # loads RVM, which initializes environment and paths
    cmds << "source /usr/local/rvm/scripts/rvm"

    # automatically trust the gemset in the .rvmrc file
    cmds << "rvm rvmrc trust #{release_path}"

    # ya know, get to where we need to go
    # ex. /var/www/my_app/releases/12345
    cmds << "cd #{release_path}"

    # Explicitly source the rvmrc
    cmds << "\. ./.rvmrc"

    # run bundle install with explicit path and without test dependencies
    cmds << "bundle install --without test"

    # actually run all of the commands via ssh on the server
    run cmds.join(" && ")
  end

  task :update do
    Rake::Task['vlad:bundle'].invoke
  end


  desc 'Trust rvmrc file'
  task :trust_rvmrc do
    run "rvm rvmrc trust #{current_release}"
  end

  #after "deploy:update_code", "rvm:trust_rvmrc"

  def stop
    run "merb -m #{deploy_to}/current -K all"
  end

  def start
    run "merb -m #{deploy_to}/current -e production -c 2"
  end

  remote_task :start, :roles => :app do
    stop
    start
  end

  remote_task :stop, :roles => :app do
    stop
  end

  # remote_task :update do
  #   Rake::Task["vlad:start"].invoke
  # end

  # desc "Symlinks the configuration files"
  # remote_task :symlink_config, :roles => :web do
  #   %w(database.yml).each do |file|
  #     run "ln -s #{shared_path}/config/#{file} #{current_path}/config/#{file}"
  #   end
  # end

  # desc "Full deployment cycle: Update, migrate, restart, cleanup"
  # remote_task :deploy, :roles => :app do
  #   Rake::Task['vlad:update'].invoke
  #   Rake::Task['vlad:symlink_config'].invoke
  #   Rake::Task['vlad:migrate'].invoke
  #   Rake::Task['vlad:start_app'].invoke
  #   Rake::Task['vlad:cleanup'].invoke
  # end
end
