class Appeal < ApplicationRecord
  belongs_to :user
  belongs_to :contract

  serialize :images, Array
end
