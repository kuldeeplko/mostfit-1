class ApiAccess
  include DataMapper::Resource
  
  property :id, Serial
  property :origin, String, :required => true
  property :description, String, :required => true

  belongs_to :branch

  validates_uniqueness_of   :origin
end
