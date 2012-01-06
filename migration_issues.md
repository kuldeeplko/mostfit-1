Migration Issues
================

This document aims to describe any remaining issues regarding the migration to ruby 1.9, merb 1.1.3 and datamapper 1.1


association#lazy? is deprecated
-------------------------------

Used in app/models/data_access_observer.rb

    def self.get_object_state(obj, type)
      #load lazy attributes forcefully here
      @ributes = original_attributes = obj.original_attributes.map{|k,v| {k.name => (k.lazy? ? obj.send(k.name) : v)}}.inject({}){|s,x| s+=x}
      @action = type
    end

This results in:

    undefined method 'lazy?' for #<DataMapper::Associations::ManyToMany::Relationship:0xa21069c>


object.to_yaml was failing in app/models/mfi.rb
-----------------------------------------------

The custom #save method in mfi.rb used to read:

    File.open(File.join(Merb.root, "config", "mfi.yml"), "w"){|f|
      f.puts self.to_yaml
    }

But in Ruby 1.9.2 self.to_attributes was failing with the syntax error "wrong argument type Symbol (expected String)", I replaced this with

    File.open(File.join(Merb.root, "config", "mfi.yml"), "w"){|f|
      f.puts self.attributes.to_yaml
    }


next in controllers
-------------------

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

app/models/date_parser.rb:

    cols = properties.to_a.find_all{ |x| x.type == Date }.map{ |x| x = x.name }

changed to:

    cols = properties.to_a.find_all{ |x| x.class == Date }.map{ |x| x = x.name }


validation failures
-------------------

This one isn't strictly about the migration but a validation that was working before started failing but no errors.full_messages was returned (only nil.)
Traced the problem to #verified_cannot_be_deleted_if_not_deleted in Loan. It used to read:

    verified_cannot_be_deleted if self.deleted_at != nil

Meaning that if deleted_at was nil, the method returned nil and so failed the validation for no reason and without a message. Replaced with:

    if self.deleted_at != nil
      verified_cannot_be_deleted
    else
      true
    end
