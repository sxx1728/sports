class Reply < ApplicationRecord
  belongs_to :contract
  belongs_to :user
  serialize :images, Array
end
