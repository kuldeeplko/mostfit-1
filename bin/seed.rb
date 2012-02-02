#!/usr/bin/env ruby

#
# This seed file is intended to facilitate (browser) testing of the application
#
# Running this file will first clear the database and then replace it with 'seed'
# data. This data should provide a basic database that will let you test any and
# all features of the application.
#
# The environment loaded will default to `development` or MERB_ENV
#

#
# Copied over the initialization stuff from Rakefile, eventually this should become
# a rake task but right now rake is not fully functional on the update branch.
#

begin
  # Just in case the bundle was locked
  # This shouldn't happen in a dev environment but lets be safe
  require '.bundle/environment'
rescue LoadError
  require 'rubygems'
  require 'bundler'
  Bundler.setup
end

init_env = ENV['MERB_ENV'] || 'development'

puts "\n!!WARNING!! Running this fill WILL destroy your existing #{init_env} database."
print "Are you sure you want to procede? [Yn]: "
$stdout.flush
c = gets
if ['y', 'Y', "\n"].include? c[0]
  puts "Proceding...\n\nThis creates an admin priviledged user with login 'admin' and password 'secret'.\n\n"
else
  puts "Aborting...\n"
  exit
end

require 'rdoc/task'

require 'merb-core'
require 'merb-core/tasks/merb'

# Load the basic runtime dependencies; this will include
# any plugins and therefore plugin rake tasks.
Merb.load_dependencies(:environment => init_env)
Merb.start_environment(:environment => init_env, :adapter => 'runner')


#
# Load the registered factories as a basis for our seeds
#
require './spec/factories'

#
# Clear out all existing records
#
puts
puts "*******************************************"
puts "**                                       **"
puts "**   Loading test-data for development   **"
puts "**           from db/seed.rb             **"
puts "**                                       **"
puts "**   Merb.env: #{Merb.env.ljust(21)}     **"
puts "**                                       **"
puts "*******************************************"
puts
puts "Creating a pristine database schema..."
# [
#   Account,
#   AccountType,
#   Area,
#   Branch,
#   Center,
#   Client,
#   ClientType,
#   CreditAccountRule,
#   Currency,
#   DebitAccountRule,
#   DirtyLoan,
#   Domain,
#   Fee,
#   Funder,
#   FundingLine,
#   InsuranceCompany,
#   JournalType,
#   Loan,
#   LoanHistory,
#   LoanProduct,
#   LoanPurpose,
#   Organization,
#   Portfolio,
#   Region,
#   RepaymentStyle,
#   RuleBook,
#   StaffMember,
#   User,
# ].each do |model|
#   puts ".. #{model.name} records"
#   model.destroy!
# end
puts

DataMapper.auto_migrate!

#
# Organizations and associated
#
puts "Creating an Organization"
organization = Factory( :organization, name: 'Mostfit', org_guid: UUID.generate )
puts ".. Mostfit"

puts

#
# AccountTypes
#
puts "Creating the basic AccountTypes"
account_types = %w[Assets Liabilities Income Expenditure].map do |account_type|
  puts ".. #{account_type}"
  Factory( :account_type, name: account_type, code: account_type )
end

puts

#
# Set up an admin user to test with
#
user = Factory.build(:user, login: 'admin', role: 'admin')
user.save

#
# Set up the regions and everything that falls below them
#
# Note the region factory will automatically generate a manager for each region. We'll assign
# the region's manager to each area, the area's manager to the branch and the branch's manager
# to the center to avoid creating dozens of managers.
#
# Note also that we use Factory.build to set up the objects and then call save on them manually.
# This is because FactoryGirl ignores callbacks like after_save normally. This can mess up important
# data generation when creating a 'real' working environment. For instance Centers would not
# generate CenterMeetingDays if not saved this way.
#
puts "Creating some Regions"
1.times do
  region = Factory.build(:region)
  region.save


  puts ".. add some Areas for #{region.name}"
  2.times do
    # We'll assign the region's manager to each area to avoid creating dozens of managers
    area = Factory.build(:area, region: region, manager: region.manager )
    area.save

    puts ".. .. add some branches for area #{area.name}"
    2.times do
      branch = Factory.build(:branch, area: area, manager: area.manager, organization: organization )
      branch.save
      puts ".. .. .. Branch: #{branch.name}"

      puts ".. .. .. .. add the four basic account types for branch #{branch.name}"
      account_types.each do |account_type|
        puts ".. .. .. .. .. #{account_type.name}"
        account = Factory.build(:account, name: account_type.name, account_type: account_type, branch: branch)
        account.save
      end

      puts ".. .. .. .. add some centers for branch #{branch.name}"
      2.times do
        center = Factory.build(:center, branch: branch, manager: branch.manager)
        center.save

        puts ".. .. .. .. .. add some clients_groups for center #{center.name}"
        2.times do
          client_group = Factory.build(:client_group, center: center, created_by_staff: center.manager)
          client_group.save

          client_type = Factory.build(:client_type, type: 'Standard client')
          client_type.save

          puts ".. .. .. .. .. .. add some clients for group #{client_group.name}"
          3.times do
            client = Factory.build(:client, client_group: client_group, client_type: client_type, center: client_group.center, organization: client_group.center.branch.organization, created_by_staff: client_group.center.manager, created_by: user, verified_by: user)
            client.save
            puts ".. .. .. .. .. .. .. #{client.name}"
          end

        end
      end
      puts ".. .. .. .. add some journal_types for branch #{branch.name}"
      journal_types = [
        Factory.build(:journal_type),
        Factory.build(:journal_type),
        Factory.build(:journal_type)
      ]
      journal_types.each { |journal_type| journal_type.save ; puts ".. .. .. .. .. #{journal_type.name}" }


      puts ".. .. .. .. add some fees for branch #{branch.name}"
      fees = [
        Factory.build(:fee, name: 'Welfare Fund', percentage: 0.025),
        Factory.build(:fee, name: 'Loan Processing Fee', percentage: 0.01),
        Factory.build(:fee, name: 'Insurance Fee', percentage: 0.01)
      ]
      fees.each { |fee| fee.save ; puts ".. .. .. .. .. #{fee.name}" }

      puts ".. .. .. .. add some rule_books for branch #{branch.name}"
      rule_books = [
        Factory.build(:rule_book, name: 'Loan disbursement', branch: branch, journal_type: journal_types[0], created_by: user, updated_by: user ),
        Factory.build(:rule_book, name: 'Interest received', branch: branch, journal_type: journal_types[1], created_by: user, updated_by: user ),
        Factory.build(:rule_book, name: 'Risk fund received', branch: branch, journal_type: journal_types[1], created_by: user, updated_by: user, fee: fees.first)
      ]
      rule_books.each { |rule_book| rule_book.save ; puts ".. .. .. .. .. #{rule_book.name}" }

      puts ".. .. .. .. add some account rules"
      account_rules = [
        Factory.build(:credit_account_rule, rule_book: rule_books[0], credit_account: branch.accounts[0], percentage: 100 ),
        Factory.build(:debit_account_rule, rule_book: rule_books[0], debit_account: branch.accounts[2], percentage: 100 ),
        Factory.build(:credit_account_rule, rule_book: rule_books[1], credit_account: branch.accounts[2], percentage: 100 ),
        Factory.build(:debit_account_rule, rule_book: rule_books[1], debit_account: branch.accounts[0], percentage: 100 ),
        Factory.build(:credit_account_rule, rule_book: rule_books[2], credit_account: branch.accounts[2], percentage: 100 ),
        Factory.build(:debit_account_rule, rule_book: rule_books[2], debit_account: branch.accounts[0], percentage: 100 ),
      ]
      account_rules.each { |account_rule| account_rule.save ; puts ".. .. .. .. .. #{account_rule.rule_book.name} (#{account_rule.class.name})" }

      puts
    end
  end
  puts
end

puts










