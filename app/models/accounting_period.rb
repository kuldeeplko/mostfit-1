# All accounting actions happen during a particular accounting period
# Only one accounting period can be in force at any time
# Any accounts in existence during an accounting period can have an opening balance other than zero assigned to them (exactly once) 
# At the end of an accounting period, "books" must be "closed" and balances brought forward to the beginning of the next accounting period as the opening balances for the new period
# Ideally, an administrator should "close" an accounting period and the system should disallow any accounting entries under the period once closed


# Are these supposed to be system wide? I saw they (optionally) belong_to an Organization but when I look
# at validation methods like #closing_done_sequentially it seems to validate against AccountingPeriod.all,
# without any mention of the related organization.
#
# This is not correct, accounting periods should be scoped over organizations
#
# Also creating a new accounting period when no others exist seems to be impossible as far as I can tell.
# The validation done in #closing_done_sequentially seems to always fail if no other records exist, even
# if we're not trying to close the period.
#

class AccountingPeriod
  include DataMapper::Resource
  
  property :id,         Serial
  property :name,       String
  property :begin_date, Date, :required => true, :default => Date.today
  property :end_date,   Date, :required => true, :default => Date.today+365
  property :closed,     Boolean, :required => true, :default => false
  property :created_at, DateTime, :required => true, :default => Time.now

  has n, :account_balances
  has n, :accounts, :through => :account_balances
  
  belongs_to :organization
  property :organization_id, Integer, :required => false

  # Let's make sure closed is never nil to avoid confusing error messages from #closing_done_sequentially
  # which may bork if closed is nil instead of false
  validates_presence_of :closed

  validates_presence_of :name

  validates_with_method :cannot_overlap
  validates_with_method :closing_done_sequentially
  validates_with_method :all_account_balances_are_verified_before_closing_accounting_period

  # This method is used to compare/sort AccountingPeriods by begin_date
  def <=>(other)
    return (end_date <=> other.begin_date) if other.respond_to?(:begin_date) && other.begin_date
    return 0
  end

  # The total duration of the period in days
  def duration
    (end_date - begin_date).to_i + 1
  end

  def is_first_period?
    begin_date == self.model.aggregate(:begin_date).min
  end

  # On save make sure the accounting_period's begin_date - end_date range does not overlap any other accounting_period.
  def cannot_overlap
    # If neither the start nor end date were set we don't have to check for overlap
    return true unless self.attribute_dirty?(:begin_date) || self.attribute_dirty?(:end_date)

    # Accounting periods can (optionally) belong to an organization. If so, we have to validate against other
    # periods in the same organization. If not we validate against all other accounting periods.
    scoped_periods = self.organization.blank? ? AccountingPeriod : self.organization.accounting_periods

    # We know that the accounting_period overlaps if either the begin or end date fall within the range
    # of any previous account (i.e. is higher than the begin_date and lower than the end_date.)
    if scoped_periods.first(:begin_date.lte => self.begin_date, :end_date.gte => self.begin_date, :id.not => self.id)
      [false, 'The begin_date of this period overlaps with another period.']
    elsif scoped_periods.first(:begin_date.lte => self.end_date, :end_date.gte => self.end_date, :id.not => self.id)
      [false, 'The end_date of this period overlaps with another period.']
    else
      true
    end
  end

#  This is the original implementation of the above validation, please remove when the above rewrite is confirmed
#  def cannot_overlap
#    @changed_attr_with_original_val = self.original_attributes.map{|k,v| {k.name => (k.is_a?(DataMapper::Property) && k.lazy? ? obj.send(k.name) : v)}}.inject({}){|s,x| s+=x}
#    return true if @changed_attr_with_original_val.keys.size == 1 and @changed_attr_with_original_val.keys.include?(:closed)
#    overlaps = AccountingPeriod.all(:end_date.lte => end_date, :end_date.gt => begin_date)
#    overlaps = AccountingPeriod.all(:begin_date.gte => begin_date, :begin_date.lt => end_date) if overlaps.empty?
#    return true if overlaps.empty?
#    return [false, "Your accounting period overlaps with other accounting periods"]
#  end

  # When we're closing an accounting_period (saving with :closed => true) we have to check that all preceding
  # accounting periods were already closed. We can never have a closed accounting period AFTER a period that's
  # still open.
  def closing_done_sequentially
    # If we haven't changed the closed status there's no need to check for conflicts
    return true unless self.attribute_dirty?(:closed)

    # Accounting periods can (optionally) belong to an organization. If so, we have to validate against other
    # periods in the same organization. If not we validate against all other accounting periods.
    scoped_periods = self.organization.blank? ? AccountingPeriod : self.organization.accounting_periods

    if self.closed
      # If we are trying to close a period and there are no previous open periods, go ahead.
      if scoped_periods.all(:closed => false, :begin_date.lt => self.begin_date).blank?
        true
      else
        [false, 'You can not close an accounting_period if there are still open periods before it']
      end
    else
      # If we are trying to open a period and there are no subsequent closed periods, go ahead.
      if scoped_periods.all(:closed => true, :begin_date.gt => self.begin_date).blank?
        true
      else
        [false, 'You can not open an accounting period if there are closed periods following it.']
      end
    end

  end

#  This is the original implementation of the above validation left for reference. Please delete when the rewrite above is confirmed.
#  def closing_done_sequentially
#    closedAP = AccountingPeriod.all(:closed => true, :order => [:begin_date.asc])
#    openAP = AccountingPeriod.all(:closed => false, :order => [:begin_date.asc])
#    return true if self.id == openAP.first.id and self.closed == true
#    return true if self.id == closedAP.last.id and self.closed == false
#    return [false, "This Cannot be closed"]
#  end

=begin
  def dates_in_order
    compare_dates = begin_date <=> end_date
    return true if compare_dates < 0
    return [false, "Begin date must precede end date"]
  end
=end

  def AccountingPeriod.get_accounting_period(for_date = Date.today)
    AccountingPeriod.first(:begin_date.lte => for_date, :end_date.gte => for_date)
  end
  
  def AccountingPeriod.get_current_accounting_period
    get_accounting_period
  end

  def get_last_accounting_period_before(date = Date.today)
    AccountingPeriod.all(:to_date.lt => date, :order_by => [:to_date]).last
  end


  def self.get_current_accounting_period!
    get_accounting_period || get_last_accounting_period_before
  end

  def AccountingPeriod.get_earliest_period; AccountingPeriod.all.sort.first; end
  def is_earliest_period?; self == AccountingPeriod.get_earliest_period; end

  def prev
    all_periods = AccountingPeriod.all.sort
    return nil if self == all_periods.first
    idx = all_periods.index(self)
    all_periods[idx - 1]
  end

  def next
    all_periods = AccountingPeriod.all.sort
    return nil if self == all_periods.last
    idx = all_periods.index(self)
    all_periods[idx + 1]
  end

  def get_previous_periods
    AccountingPeriod.get_all_previous_periods(begin_date)
  end

  # Returns the accounting periods preceding the one that was in effect for the given date
  def AccountingPeriod.get_all_previous_periods(for_date = Date.today)
    return nil unless AccountingPeriod.first_period
    return nil if for_date <= AccountingPeriod.first_period.end_date
    all_periods = AccountingPeriod.all.sort
    return all_periods if for_date > AccountingPeriod.last_period.end_date
    period_on_date = AccountingPeriod.get_accounting_period(for_date)
    idx = all_periods.index(period_on_date)
    idx ? all_periods.shift(idx) : nil
  end
  
  def AccountingPeriod.last_period
    AccountingPeriod.all.sort.last
  end

  def AccountingPeriod.first_period
    AccountingPeriod.all.sort.first
  end

  def to_s
    "Accounting period #{name} beginning #{begin_date.strftime("%d-%B-%Y")} through #{end_date.strftime("%d-%B-%Y")}"
  end

  def all_account_balances_are_verified_before_closing_accounting_period
    return true unless self.closed
    AccountBalance.all(:accounting_period => self).each do |ab|
      return [false,"#{ab.account.name} has not been verified for this period"] unless ab.verified?
    end
    return true
  end
end
