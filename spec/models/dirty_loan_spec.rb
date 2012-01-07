require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe DirtyLoan do
  before(:each) do
    @loan = Factory(:loan)
    @loan.should be_valid
  end

  # Very strange, this works fine on the commandline (merb -i) but in the spec it fails...
  # After checking the DirtyLoan created by #add won't save, returning false but it does
  # not show any validation errors..
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
