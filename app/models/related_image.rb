class RelatedImage < ActiveRecord::Base

  belongs_to :image
  belongs_to :restaurant
  belongs_to :user
  belongs_to :topic
  belongs_to :food_item
  belongs_to :message
  belongs_to :product
  belongs_to :topic_event

  named_scope :recent, :order => 'created_at DESC'
  named_scope :by_group, lambda { |group| {:conditions => {:group => group}} }
  named_scope :old_first, :order => 'created_at ASC'
  named_scope :sectioned, :conditions => {:group => 'section'}

  GROUPS = [:section]
end
