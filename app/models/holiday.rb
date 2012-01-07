class Holiday
  include DataMapper::Resource
  property :id, Serial

  property :name, String, :length => 50, :required => true
  property :date, Date, :required => true, :unique => true
  # Make sure we set required => true because Enum does allow blank values for an enum in DM 1.1
  property :shift_meeting, Enum[:before, :after], :required => true
  property :new_date, Date
  property :deleted_at, ParanoidDateTime

  has n, :holidays_fors

  def holiday_calendars
    holidays_fors.holiday_calendars
  end
end
