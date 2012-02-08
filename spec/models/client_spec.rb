require File.join( '.', File.dirname(__FILE__), '..', "spec_helper" )

describe Client do

  before(:all) do
    Client.all.destroy!
    Loan.all.destroy!
    RepaymentStyle.all.destroy!
    Center.all.destroy!
  end

  before(:each) do
    @client = Factory(:client)
    @client.should be_valid
  end

  it "should not be valid without belonging to a center" do
    @client.center = nil
    @client.should_not be_valid
  end

  it "should not be valid without a name" do
    @client.name = nil
    @client.should_not be_valid
  end

  it "should not be valid without a reference" do
    @client.reference = nil
    @client.should_not be_valid
  end

  it "should not be valid with name shorter than 3 characters" do
    @client.name = "ok"
    @client.should_not be_valid
  end

  it "should have a joining date" do
    @client.date_joined = nil
    @client.should_not be_valid
  end

  it "should be able to 'have' loans", :focus => true do
    # Make sure we test against #count at the end, #size only looks at the @client object in memory, #count checks the actual database.
    lambda {
      loan = Factory(:approved_loan, :client => @client )
      loan.should be_valid

      loan2 = Factory(:approved_loan, :client => @client )
      loan2.should be_valid

    }.should change{ @client.loans.count }.by(2)
  end

  it "should not be deleteable if verified" do
    @client.verified_by = Factory(:user)
    @client.save
    @client.destroy.should be_false

    @client.verified_by = nil
    @client.destroy.should be_true
  end

  # There are no assertions here...
  it "should deal with death of a client" do
    @client.deceased_on = Date.today
  end

end
