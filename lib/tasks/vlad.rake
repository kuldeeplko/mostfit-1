begin

  $TESTING = true # workaround a conflict between DataMapper and Vlad
  require "vlad"

  # In case passenger is not ubiquous then set :app to nil here, and set them
  # in `config/deploy_#{ENV['to']}.rb`.
  Vlad.load(:app => :passenger, :scm => :git)

rescue LoadError => e
  $stderr << "Error loading vlad: #{e}"
end
