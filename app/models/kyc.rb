class Kyc < ApplicationRecord

  belongs_to :user

  mount_uploader :front_img, ImgUploader
  mount_uploader :back_img, ImgUploader


  include AASM
  aasm do
    state :verifing, initial: true
    state :accepted
    state :rejected
  end


end
