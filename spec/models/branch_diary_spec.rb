require File.join( '.', File.dirname(__FILE__), '..', "spec_helper" )

describe BranchDiary do

  before(:each) do
    Branch.all.destroy!
    BranchDiary.all.destroy!
    @branch_diary = Factory(:branch_diary)
    @branch_diary.should be_valid
  end
  
  it "should not be valid without a manager who opens the branch" do
    @branch_diary.manager = nil
    @branch_diary.should_not be_valid
  end

  it "should belong to a particular branch" do
    @branch_diary.branch = nil
    @branch_diary.should_not be_valid
    @branch_diary.branch = Branch.first
    @branch_diary.should be_valid
  end

  it "should not be valid without a branch" do
    @branch_diary.branch = nil
    @branch_diary.should_not be_valid
  end

  it "should not be valid without today's date" do
    @branch_diary.diary_date = nil
    @branch_diary.should_not be_valid
  end

  it "should have a unique date with respect to a branch" do
    @branch_diary.update :diary_date => Date.new(2000, 12, 20)
    @branch_diary.should be_valid

    branch_diary2 = Factory.build(:branch_diary, :diary_date => Date.new(2000, 12, 20), :branch => @branch_diary.branch )
    branch_diary2.should_not be_valid
  end

  it "should not be valid without the opening time of branch" do
    @branch_diary.opening_time_hours = nil
    @branch_diary.opening_time_minutes = nil
    @branch_diary.should_not be_valid
  end

  it "should be valid without the closing time of branch" do
    @branch_diary.closing_time_hours = nil
    @branch_diary.closing_time_minutes = nil
    @branch_diary.should be_valid
  end

  it "should not be valid without a person holding the branch key" do
    @branch_diary.branch_key = nil
    @branch_diary.should_not be_valid
  end

end
