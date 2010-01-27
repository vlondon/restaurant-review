class FormAttribute < ActiveRecord::Base

  UNLIMITED_RECORDS = 0
  SINGLE_RECORD = 1
  LIMITED_RECORDS = 2

  serialize :fields
  belongs_to :topic

  named_scope :by_topic, lambda { |topic_id| {:conditions => {:topic_id => topic_id}}}

  def allows_more_entry?(user)
    case record_insert_type
      when UNLIMITED_RECORDS
        return true
      when LIMITED_RECORDS
        return true
      when SINGLE_RECORD
        total_records = user.restaurants.count
        if total_records > 0
          return false
        else
          return true
        end
    end
  end
end