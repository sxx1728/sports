# == Schema Information
#
# Table name: roles
#
#  id            :bigint           not null, primary key
#  name          :string(32)
#  resource_type :string(255)
#  resource_id   :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Role < ApplicationRecord
  has_and_belongs_to_many :admins, :join_table => :admins_roles


  belongs_to :resource,
           :polymorphic => true,
           :optional => true


  validates :resource_type,
          :inclusion => { :in => Rolify.resource_types },
          :allow_nil => true

  scopify

  validates_inclusion_of :name, in: ['admin', 'operator']

  def self.role_text role
    case role
    when 'admin'
      '管理员'
    when 'operator'
      '运营人员'
    else
      '未知'
    end
  end


end
