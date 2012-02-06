# This file contains the configuration for `vlad` our deploy tool.

# Good info on vlad:
# http://blog.js.hu/2011/02/18/make-deployments-even-more-robust/
# http://effectif.com/articles/deploying-merb-with-vlad
# http://beginrescueend.com/integration/passenger
# http://hitsquad.rubyforge.org/vlad/doco/getting_started_txt.html
# http://hitsquad.rubyforge.org/vlad/doco/variables_txt.html

# RVM and vlad can bite (see js.hu post), but i've probably fixed this
# by having puppet to setup /etc/bash.bashrc on our ubuntu app servers.

# TROUBLE SHOOTING
# ================
#
# Usually the error message is clear and visible on the stdout.
# A few common errors that are a bit harder to crack are explain below:

# This hints that ssh key forwarding is not setup properly
#   Host key verification failed.
#   Initialized empty Git repository in [...]


# set :user,        "mostfit"
set :domain,      "detroit.emfiniti.com"
set :deploy_to,   "/var/www/mostfit/update"
set :repository,  "git@git.mostfit.in:mostfit.git"
set :revision,    "origin/update"


# refactor into:
# task :demo do
#   set :domain,    "detroit.emfiniti.com"
#   set :deploy_to, "/var/www/mostfit/update"
# end

# task :staging do
#   set :domain,    "staging.emfiniti.com"
#   set :deploy_to, "/var/www/mostfit/staging"
# end

namespace :vlad do
  desc "Symlinks the configuration files"
  remote_task :symlink_config, :roles => :web do
    %w(database.yml).each do |file|
      run "ln -s #{shared_path}/config/#{file} #{current_path}/config/#{file}"
    end
  end

  desc "Full deployment cycle: Update, migrate, restart, cleanup"
  remote_task :deploy, :roles => :app do
    Rake::Task['vlad:update'].invoke
    Rake::Task['vlad:symlink_config'].invoke
    Rake::Task['vlad:migrate'].invoke
    Rake::Task['vlad:start_app'].invoke
    Rake::Task['vlad:cleanup'].invoke
  end
end
