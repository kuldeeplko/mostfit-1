Naming issues
=============

This document lists issues encountered with the current naming scheme. Inconsistencies, vagueness and general impropriety.

Models and Libraries
--------------------

We're mixing up a lot of models and libraries in app/models, moving the non-datamapper models to lib would be a good idea.


Incosistencies in naming methods
--------------------------------

Some inconsistently named methods in models/modules:

*   app/models/reports/branch.rb
        #client_count
        #active_client_count
        #dormant_client_count
        #borrower_clients_count   <= plural used here

Users, Funderd, StaffMembers and Managers 
-----------------------------------------

This is pretty fundamental and very confusing. Users are general user accounts used to authorize access. StaffMembers are members of a center, branch, which may or may not have a User account associated with them. StaffMembers can also be (but are not necessarily) Managers of a center or organization. Funders, like StaffMembers may or may not also have a User account associated with them.

While this in itself does make sense the naming used can be confusing when mixed with the next point, inconsistently named associations. (e.g. applied_by, created_by, received_by does not make clear whether we're dealing with Staff or User or ManagerialStaff.)


Consistent id columns
---------------------

We're not being terribly consistent with association naming when we use non-standard indexes, specifically when associating staff members a managers or `updated_by` type associations. If we want to make clear the difference between changes made by managers, staff-members or users the association should reflect this as well as the id column naming. (e.g either `created_by_user` and `created_by_user_id` OR `created_by` and `created_by_id`, not a combination.)

Considering we often use many of these methods on models I recommend we go with the "full" naming, (e.g. `created_by_user`, `validated_by_staff_member`) to avoid confusion as to what model we're referring to. Also recommend we stick to 'standard' association naming and using `:child_key` options as little as possible.

* examples:
        AuditItem             belongs_to :assigned_to, :model => StaffMember
        AccountBalance        belongs_to :verified_by, :child_key => [:verified_by_user_id], :model => 'User'
        Accrual               belongs_to :created_by, :child_key => [:created_by_user_id]
        ApplicableFee         belongs_to :waived_off_by, 'StaffMember', :child_key => [:waived_off_by_id]
        AssetRegister         belongs_to :manager, :child_key => [:manager_staff_id],  :model => 'StaffMember'
        AssetRegister         belongs_to :branch, :child_key => [:branch_id],         :model => 'Branch'

Of course this would be a huge pita to fix.


Dates
-----

There are also many cases of models being approved, disbursed, deleted, etc. on certain dates. Let's set up a consistent naming scheme for these attributes. The Loan model for example has these date attributes:

*   `scheduled_disbursal_date`
*   `scheduled_first_payment_date`
*   `applied_on`
*   `approved_on`
*   `rejected_on`
*   `disbursal_date`
*   `written_off_on`
*   `suggested_written_off_on`
*   `write_off_rejected_on`
*   `validated_on`
*   `preclosed_on`

As you can see the naming varies between `_on` and `_date`. I would recommend sticking with `_on` for dates and `_at` for times both because it's the de-facto standard and because most existing attributes already comply.


Hand-made associations
----------------------

There are several places where we have 'polymorphic' associations, for example in AuditItem:

    property :audited_model, String
    property :audited_id, Integer

    def object
      Kernel.const_get(audited_model).get(audited_id)
    end

or in ApplicableFee:

    property :applicable_id,   Integer, :index => true, :nullable => false
    property :applicable_type, Enum.send('[]', *FeeApplicableTypes), :index => true, :nullable => false

    def parent
      Kernel.const_get(self.applicable_type).get(self.applicable_id)
    end

As there is no standard for polymorphic associations in DM, we should at least set some rules to name these associations consistently. Or we could look at dm-is-remixable which seems to fill a similar role.

Other models with similar associations:

*   AuditTrail
*   Comment
*   Document


Constants
---------

We have a large number of constants in `config/constants.rb` ripe for renaming. I don't think we need examples here as they are quite obvious, but Types and Methods (used only in the Bookmark model) for starters.


AccountTypes
------------

A corollary of the Constants issue, we have our account_types defined both as a user configurable model (`AccountType`) and some constants set in `config/constants.rb`. The constants do nothing more than hold a string representation of themselves (e.g. ASSETS = 'assets'). Even worse the account model holds this method:

    def get_account_type
      ACCOUNT_TYPES[self.account_type_id]
    end

Which only works as long as the account_type_ids match the ACCOUNT_TYPES in order and the first AccountType has id 1. What it returns is (at best) the exact same name as the associated AccountType, but otherwise just nil.


Outdated views
--------------

Not strictly a naming issue but we've got a bunch of cruft littering our views, namely:

    app/views/dashboard/old_today.html.haml
    app/views/browse/_totalinfo_old.html.haml
    app/views/browse/index.html.old
    app/views/browse/index_old.html.haml

Setting defaults
----------------

Again, not strictly a naming issue but this kind of thing:

    begin
      if ClientType.count==0
        ClientType.create(:type => "Standard client")
      end
    rescue
    end

found at the end of `client_type.rb` is a pretty obvious no-no. IF we want to initialize some data at startup at least collect it all in one file and run that at boot time or something. Distributing defaults through the app like this makes behavior very hard to predict.



DataAccessObserver's observed models
------------------------------------

** This may be deprecated and not necessary to look at **

In DAO's `observe` statement we declare the following:

    observe *(DataMapper::Model.descendants.to_a - [AuditTrail, Cacher, BranchCache, CenterCache] + [Branch, Center, ClientGroup, Client, Loan, Payment, Fee]).uniq # strange bug where observer drops some of the descnedants.

Since this is misbehaving somewhat, perhaps we should consider just listing all the models to be observed instead of cleverly taking Model's descendants? Less chance of logging something undesirable and easier to read too..

