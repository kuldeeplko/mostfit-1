module Verifiable
  # prevents deletion of objects that are 'verified'
  
  def self.included(base)
    base.class_eval do
      
      before :destroy,                                     :verified_cannot_be_deleted
      property :verified_on,                               DateTime
      property :verified_by_user_id,                       Integer, :nullable => true, :index => true
      validates_with_method  :verified_by_user_id,         :method => :verified_cannot_be_deleted, :if => Proc.new{|x| x.deleted_at != nil}

      def verified_cannot_be_deleted
        return true unless verified_by_user_id
        throw :halt
      end
    end
  end
end

