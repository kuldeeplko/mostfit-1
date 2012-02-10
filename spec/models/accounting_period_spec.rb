require File.join( '.', File.dirname(__FILE__), '..', "spec_helper" )

#
# Most of these tests are currently meaningless because the validations for
# AccountingPeriod are borked, meaning new accounting_periods are never valid.
# The problem is described in the model on #closing_done_sequentially
#
describe AccountingPeriod do

  before(:each) do
    AccountingPeriod.all.destroy!
    @accounting_period = Factory.build(:accounting_period)
  end

  it "should be valid with default attributes" do
    @accounting_period.should be_valid
  end

  it "should have a name" do
    @accounting_period.name = nil
    @accounting_period.should_not be_valid
  end

  it "should have a begin date" do
    @accounting_period.begin_date = nil
    @accounting_period.should_not be_valid
  end

  it "should have an end date" do
    @accounting_period.end_date = nil
    @accounting_period.should_not be_valid
  end

  context "when previous periods exist" do
    # We'll create 4 periods to test with, the first two closed, the last two open
    # We use these to test that opening and closing periods should only be allowed sequentially.
    before(:each) do
      AccountingPeriod.all.destroy!
      @period1 = Factory(:accounting_period, :closed => true,  :begin_date => Date.today - 40, :end_date => Date.today - 31)
      @period1.should be_valid
      @period2 = Factory(:accounting_period, :closed => true,  :begin_date => Date.today - 30, :end_date => Date.today - 21)
      @period2.should be_valid
      @period3 = Factory(:accounting_period, :closed => false, :begin_date => Date.today - 20, :end_date => Date.today - 11)
      @period3.should be_valid
      @period4 = Factory(:accounting_period, :closed => false, :begin_date => Date.today - 10, :end_date => Date.today)
      @period4.should be_valid
    end

    it 'should not allow the start_date to overlap with any other period' do
      @period2.begin_date = Date.today - 35
      @period2.should_not be_valid
      @period2.errors.full_messages.should include('The begin_date of this period overlaps with another period.')

      @period2.begin_date = Date.today - 30
      @period2.should be_valid
    end

    it 'should not allow the end_date to overlap with any other period' do
      @period3.end_date = Date.today - 5
      @period3.should_not be_valid
      @period3.errors.full_messages.should include('The end_date of this period overlaps with another period.')

      @period3.end_date = Date.today - 11
      @period3.should be_valid
    end

    it 'should not allow a period to be opened if any subsequent periods are closed' do
      @period1.closed = false
      @period1.should_not be_valid
      @period1.errors.full_messages.should include('You can not open an accounting period if there are closed periods following it.')
    end

    it 'should allow a period to be opened if all subsequent periods are open too' do
      @period2.closed = false
      @period2.should be_valid
    end

    it 'should not allow a period to close if any previous periods are still open' do
      @period4.closed = true
      @period4.should_not be_valid
      @period4.errors.full_messages.should include('You can not close an accounting_period if there are still open periods before it')
    end

    it 'should allow a period to close if all preceding periods are closed' do
      @period3.closed = true
      @period3.should be_valid
    end

  end

end
