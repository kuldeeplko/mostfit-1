require File.join( '.', File.dirname(__FILE__), '..', "spec_helper" )

#
# In this spec we test the various models that are observed by DataAccessObserver.
# Every time such a record is created or updated an AuditTrail record should be
# created which tracks the changes made to the record.
#
# Currently the observed models are: Branch, Center, Client and Loan
#
describe AuditTrail do 

  before(:all) do
    session_mock = mock('session')
    session_mock.stub!(:user).and_return(Factory(:user))

    DataAccessObserver.insert_session( session_mock.object_id )
  end

  context 'when observing branches' do
    before(:each) do
      Branch.all.destroy!
    end

    it 'should make an audit_trail entry on create' do
      # FactoryGirl uses save! instead of save on creation, meaning after(:create) callbacks won't get called
      # for this reason we use the Factory to build our attributes and use those to call Model.create()
      branch = Factory.build(:branch)
      branch.should be_valid
      lambda {
        Branch.create( branch.attributes )
      }.should change(AuditTrail, :count).by(1)
    end

    it 'should make an audit_trail entry when a change is saved' do
      branch = Factory(:branch, :name => 'Munnar branch')
      branch.should be_valid
      lambda {
        branch.name = 'Kerala branch'
        branch.save
      }.should change(AuditTrail, :count).by(1)
    end
  end

  context 'when observing centers' do
    before(:each) do
      Center.all.destroy!
    end

    it 'should make an audit_trail entry on create' do
      center = Factory.build(:center)
      center.should be_valid
      # Note that on center creation 2 audit_trails are created because after creation is done
      # the center is automatically saved again with to update the center_meeting_day.
      lambda {
        Center.create( center.attributes )
      }.should change(AuditTrail, :count).by(2)
    end

    it 'should make an audit_trail entry when a change is saved' do
      center = Factory(:center, :name => 'Munnar center')
      center.should be_valid
      lambda {
        center.name = 'Kerala center'
        center.save
      }.should change(AuditTrail, :count).by(1)

      trail = AuditTrail.last.changes.reduce({}){|s, x| s+=x}
      trail.should == {:name=>['Munnar center', 'Kerala center']}
    end
  end

  context 'when observing clients' do
    before(:each) do
      Client.all.destroy!
    end

    it 'should make an audit_trail entry on create' do
      client = Factory.build(:client)
      client.should be_valid
      lambda {
        client.save.should be_true
      }.should change(AuditTrail, :count).by(1)
    end

    it 'should make an audit_trail entry when a change is saved' do
      client = Factory(:client, :name => 'Ms C.L. Ient')
      client.should be_valid
      lambda {
        client.name = "Mr C.U. Stomer"
        client.save.should be_true
      }.should change(AuditTrail, :count).by(1)

      p "Client changes: #{AuditTrail.last.changes.inspect}"

      trail = AuditTrail.last.changes.reduce({}){|s, x| s+=x}
      trail.should == {:name => ["Ms C.L. Ient", "Mr C.U. Stomer"]}
    end
  end

  context 'when observing loans' do
    before(:each) do
      Loan.all.destroy!
      RepaymentStyle.all.destroy!
    end

    it 'should make an audit_trail entry on create' do
      loan = Factory.build(:loan)
      loan.should be_valid
      lambda {
        Loan.create( loan.attributes )
      }.should change(AuditTrail, :count).by(1)
    end

    it 'should record approval of loan' do
      loan = Factory(:loan)
      loan.should be_valid

      lambda {
        loan.approved_on = loan.scheduled_disbursal_date - 10
        loan.approved_by = loan.applied_by
        loan.should be_valid
        loan.save.should be_true
      }.should change(AuditTrail, :count).by(1)

      trail = AuditTrail.last.changes.reduce({}){|s, x| s+=x}
      trail[:approved_on].should == [nil, loan.scheduled_disbursal_date - 10]
      trail[:approved_by_staff_id].should == [nil, loan.applied_by_staff_id]
    end
  end
end
