# == Schema Information
#
# Table name: admins
#
#  id                     :bigint           not null, primary key
#  email                  :string(128)      default(""), not null
#  encrypted_password     :string(128)      default(""), not null
#  reset_password_token   :string(128)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(32)
#  last_sign_in_ip        :string(32)
#  confirmation_token     :string(128)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(128)
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(128)
#  locked_at              :datetime
#  approved               :boolean          default(FALSE), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  google_secret          :string(128)
#

class Admin < ApplicationRecord
  rolify
  after_create :assign_default_role
  
  acts_as_google_authenticated issuer: ENV['RENT_SERVER_HOST'], drift: 31

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable, :confirmable, :timeoutable

  def active_for_authentication?
    #remember to call the super
    #then put our own check to determine "active" state using 
    #our own "is_active" column
    super and self.approved
  end

  def assign_default_role
    if Admin.count == 1
      self.add_role(:admin) 
      self.update(approved:  true)
    else
      self.add_role(:operator) 
    end
  end


end
