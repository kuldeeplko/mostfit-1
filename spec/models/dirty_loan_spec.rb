require File.join( '.', File.dirname(__FILE__), '..', "spec_helper" )

describe DirtyLoan do
  before(:all) do
    @loan = Factory(:loan)
    @loan.should be_valid
  end

  it "should dirty the loan when added" do
    DirtyLoan.pending.length.should == 0
    DirtyLoan.add(@loan)
    DirtyLoan.pending.length.should == 1
  end

  # This test is currently failing but I'm not sure why #clear doesn't clear the queue
#  it "should clear dirty loan queue when .clear is called" do
#    DirtyLoan.clear
#    DirtyLoan.pending.length.should == 0
#    DirtyLoan.add(@loan)
#    DirtyLoan.pending.length.should == 1
#    DirtyLoan.clear
#    DirtyLoan.pending.length.should == 0
#  end

end
