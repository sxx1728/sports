class Image < ApplicationRecord
  belongs_to :user
  mount_uploader :file, ImgUploader
end
