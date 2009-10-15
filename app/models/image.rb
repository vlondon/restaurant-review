class Image < ActiveRecord::Base

  belongs_to :user
  has_many :related_images, :dependent => :destroy

  has_attachment  :size => 0.megabyte..5.megabytes,
                  :content_type => :image,
                  :path_prefix => 'public/uploaded_images',
                  :storage => :file_system,
                  :thumbnails => {
                      :very_small => 'x40',
                      :small => '60x60',
                      :large => 'x200',
                      :very_large => 'x400',
                  }
  validates_as_attachment

  def author?(p_user)
    p_user && p_user.id == self.user.id
  end
  
end