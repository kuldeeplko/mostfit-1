#
# In order to use the Spork test server run the following command before you start testing:
#
#   spork rspec
#
# and wait for the spork server to say `Spork is ready and listening on [port]!`
#
# Now you can run your tests more quickly by adding `--drb` to your tests:
#
#   spec --drb spec/models/*.rb
#
# You can still run your tests normally as well.
#

require 'rubygems'
require 'spork'
require './lib/fix_spork_rspec1.rb'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

# Loading more in this block will cause your tests to run faster. However,
# if you change any configuration or code from libraries loaded here, you'll
# need to restart spork for it take effect.
Spork.prefork do
  begin
    # Just in case the bundle was locked
    # This shouldn't happen in a dev environment but lets be safe
    require File.expand_path('../.bundle/environment', __FILE__)
  rescue LoadError
    require 'bundler'
    Bundler.setup
  end

  require "spec" # Satisfies Autotest and anyone else not using the Rake tasks
  require "merb-core"

  require "erb"
  require File.join(File.dirname(__FILE__), 'spec_helper_html.rb')

  # this loads all plugins required in your init file so don't add them
  # here again, Merb will do it for you
  Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')

  # Make sure the factories are available but not until the environment has been started
  require Merb.root / 'spec/factories'

  # We'll prepare the database once before all specs. We expect our specs to clean up after themselves.
  if Merb.orm == :datamapper
    puts "Updating the database schema. This could take a minute..."
    DataMapper.auto_migrate!
    (repository.adapter.select("show tables") - ["payments", "journals", "postings"]).each do |t|
      # This probably has been done for 'performance' reasons.
      # But we simply do not know...  Piyush?
      repository.adapter.execute("alter table #{t} ENGINE=MYISAM")
    end
  end

  # Setup RSpec configuration
  Spec::Runner.configure do |config|
    # config.include(Merb::Test::ViewHelper)
    config.include(Merb::Test::RouteHelper)
    config.include(Merb::Test::ControllerHelper)
    config.include(Spec::Matchers)

    config.before(:all) do
      mfi = Mfi.first
      mfi.accounting_enabled = false
      mfi.dirty_queue_enabled = false
      mfi.in_operation_since = Date.new(2000, 01, 01)
      mfi.save
    end
  end
end

Spork.each_run do
  FactoryGirl.reload
end



# What is this I don't even
class MockLog
  def info(data)
  end

  def error(data)
  end
end
