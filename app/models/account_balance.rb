class AccountBalance
  include DataMapper::Resource
  
  before :save, :convert_blank_to_nil
  property :id, Serial

  before :destroy do |account_balance|
    throw :halt if account_balance.is_verified?
  end

  property :opening_balance, Float
  property :closing_balance, Float
  property :created_at, DateTime
  property :verified_on, DateTime
  property :verified_by_user_id,            Integer, :required => false, :index => true
  property :accounting_period_id, Integer, :key => true
  property :account_id, Integer, :key => true
  belongs_to :verified_by, :child_key => [:verified_by_user_id], :model => 'User'

  validates_with_method :verified_on, :method => :properly_verified
  validates_with_method :verification_done_sequentially

  belongs_to :accounting_period
  belongs_to :account

  # Check whether this account_balance has been verified, if so we should not allow it to be destroyed
  def is_verified?
    return true if (verified_by && verified_on)
    false
  end

  # If we're setting verified_by, verified_on also has to be set. This method validates that both
  # or neither of these attributes are set. If we've set one but not the other, validation fails.
  #
  def properly_verified
    # If both verified_by and verified_on are set, we are properly verified
    return true if is_verified?

    # If neither verified_by or verified_on is set, we are not verified, this is ok too
    return true if verified_by.blank? && verified_on.blank?

    # If neither conditions above are true, we are missing either verified_by or verified_on and validation fails
    [false, "Both verification date and verifying staff member have to be chosen"]
  end

  def convert_blank_to_nil
    self.attributes.each{|k, v|
      if v.is_a?(String) and v.empty? and self.class.send(k).type==Float
        self.send("#{k}=", nil)
      end
    }
  end

  def verification_done_sequentially
    return true unless self.verified?
    previous_account_balances = AccountBalance.all(:account => account).collect{|x| x if x.accounting_period.end_date < self.accounting_period.begin_date}.delete_if{|x| x.nil?}
    previous_account_balances.each{|pab|
      return [false, "Previous account(s) not verified"] unless pab.verified?
    }
    return true
  end
end
