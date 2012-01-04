class AccountType
  attr_accessor :debit, :credit, :balance, :opening_balance, :balance_debit, :balance_credit, :opening_balance_debit, :opening_balance_credit
  include DataMapper::Resource
  
  property :id,   Serial
  property :name, String, :index => true 
  property :code, String, :index => true  
  
  has n, :accounts
  validates_presence_of :name
  validates_presence_of :code
  validates_length_of :name,   :minimum => 3
  validates_length_of :code,   :minimum => 3
  validates_uniqueness_of :code
end
