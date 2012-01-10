Migration Issues
================

This document aims to describe any remaining issues regarding the migration to ruby 1.9, merb 1.1.3 and datamapper 1.1


Open Issues
===========

`current_validation_context` is deprecated
------------------------------------------

A private method from DataMapper is used in `app/models/payment.rb`, here:

    def received_by_active_staff_member?
      return true if self.send(:current_validation_context) == :reallocate
      ...
    end

This is part of the DM private api and while it still exists somewhere, this call now fails with an NoMethodError.

conflicting property names
--------------------------

The dirty property on Reports is now a reserved name in datamapper.

    property :dirty, Boolean

Should be renamed..

validation failures
-------------------

This one isn't strictly about the migration but a validation that was working before started failing but no `errors.full_messages` was returned (only nil.)
Traced the problem to `#verified_cannot_be_deleted_if_not_deleted` in Loan. It used to read:

    verified_cannot_be_deleted if self.deleted_at != nil

Meaning that if `deleted_at` was nil, the method returned nil and so failed the validation for no reason and without a message. Replaced with:

    if self.deleted_at != nil
      verified_cannot_be_deleted
    else
      true
    end


`deleted_at` issues
-------------------

Several models use `deleted_at` attributes for 'paranoid' deletion. However in client_spec.rb we have the test:

    it "should not be deleteable if verified" do
      @client.verified_by = @user
      @client.save
      @client.destroy.should be_false
    end

`Client#destroy` does not take the required validation (`verified_cannot_be_deleted`) into account, nor does it seem to use deleted_at in any way.
This means the test fails since `#destroy` is never prevented.
Perhaps it would be wise to override the `destroy` method on these models? Or should we just rewrite the test to test against setting `deleted_at` followed by `save`?

It seems like this one should have been failing under the old datamapper already but it didn't for some reason.


Fixed Issues
============

`Enum` properties in DM 1.1 now allow blank!
--------------------------------------------




`association#lazy?` issues
--------------------------

Used in `app/models/data_access_observer.rb`

    def self.get_object_state(obj, type)
      #load lazy attributes forcefully here
      @ributes = original_attributes = obj.original_attributes.map{|k,v| {k.name => (k.lazy? ? obj.send(k.name) : v)}}.inject({}){|s,x| s+=x}
      @action = type
    end

This results in:

    undefined method 'lazy?' for #<DataMapper::Associations::ManyToMany::Relationship:0xa21069c>

After some more digging, perhaps `lazy?` wasn't deprecated but `original_attributes` used to report only actual model attributes and not associations? I fixed this by only including actual properties, like so:

    @ributes = original_attributes = obj.original_attributes.map{|k,v| {k.name => (k.is_a?(DataMapper::Property) && k.lazy? ? obj.send(k.name) : v)}}.inject({}){|s,x| s+=x}

This precludes associations from being logged, but I believe that's also how it worked before(?)


`DataMapper::Observer` callbacks no longer alllow `return`
----------------------------------------------------------

In `app/models/model_observer.rb`, if conditions were not met we called return, as in:

    after :create do
      return false unless Mfi.first.event_model_logging_enabled
      ModelObserver.make_event_entry(self, :create)
    end

in DM 1.1 this results in a LocalJumpError getting raised. Replaced as follows:

    after :create do
      unless Mfi.first.event_model_logging_enabled
        ModelObserver.make_event_entry(self, :create)
      end
    end

I don't think the returned `false` was being used anywhere..


Counting nested arrays
----------------------

In `app/models/center.rb` we were doing this:

    return true if clients.map{|c| c.loans}.count == 0

But an array that contains an empty array ([[]]) still has a count of 1, so this always returned false.
The next line depends on the count being > 0 so this threw an error.

Replaced with:

    return true if clients.map{|c| c.loans}.flatten.count == 0

I'm not sure why this was working before, this was already existing behavior in ruby 1.8


`object.to_yaml` was failing in `app/models/mfi.rb`
---------------------------------------------------

The custom #save method in mfi.rb used to read:

    File.open(File.join(Merb.root, "config", "mfi.yml"), "w"){|f|
      f.puts self.to_yaml
    }

But in Ruby 1.9.2 `self.to_attributes` was failing with the syntax error "wrong argument type Symbol (expected String)", I replaced this with

    File.open(File.join(Merb.root, "config", "mfi.yml"), "w"){|f|
      f.puts self.attributes.to_yaml
    }


`next` in controllers
---------------------

In several controller 'next' seems to be called in an inappropriate way, e.g. app/controllers/funders.rb:

    def funding_lines
      if params[:id]
        funder = Funder.get(params[:id])
        next unless funder
      end
    end

These have been commented and replaced with

    def funding_lines
      if params[:id]
        funder = Funder.get(params[:id])
        if funder
          return("<option value=''>Select funding lines</option>"+funder.funding_lines.map{|fl| "<option value=#{fl.id}>#{fl.name}</option>"}.join)
        end
      end
    end


#class instead of #type
-----------------------

The #type method has been deprecated and #class should now be used, e.g. /app/models/client.rb:

    if v.is_a?(String) and v.empty? and self.class.send(k).type==Integer

changed to:

    if v.is_a?(String) and v.empty? and self.class.send(k).class==Integer

`app/models/date_parser.rb:`

    cols = properties.to_a.find_all{ |x| x.type == Date }.map{ |x| x = x.name }

changed to:

    cols = properties.to_a.find_all{ |x| x.class == Date }.map{ |x| x = x.name }


validation failures
-------------------

This one isn't strictly about the migration but a validation that was working before started failing but no `errors.full_messages` was returned (only nil.)
Traced the problem to `#verified_cannot_be_deleted_if_not_deleted` in Loan. It used to read:

    verified_cannot_be_deleted if self.deleted_at != nil

Meaning that if `deleted_at` was nil, the method returned nil and so failed the validation for no reason and without a message. Replaced with:

    if self.deleted_at != nil
      verified_cannot_be_deleted
    else
      true
    end


issues with `upload.rb`
-----------------------

I (cies) commented out some code on upload that prevents it from running
under DM 1.2


alligned generated files with newly gen'ed merb app
---------------------------------------------------

Doing so I (cies) found the following:

  * `config/init.rb`, is a dance with the devil
  * `config/environment/huge.rb`; wtf?

Besides that all seemed pretty much in line...

