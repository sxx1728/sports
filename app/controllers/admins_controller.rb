# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: admins
#
#  id                     :integer          not null, primary key
#  email                  :string(128)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(128)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(128)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(128)
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  approved               :boolean          default(FALSE), not null
#

class AdminsController < ApplicationController

  before_action :authorize_ability

  def authorize_ability
    authorize! :manage, Admin
  end

  def index
    session['func'] = params[:func]
    session['func_index'] = params[:func_index]
 
    @admins = Admin.paginate page: params[:page], per_page: 10
  end
  
  def approve
    if params[:id].to_i == current_admin.id
      redirect_back(fallback_location: admins_path, alert: '不能停用当前账号')
    else
      @admin = Admin.find(params[:id])
      @admin.update(approved: !@admin.approved)
      redirect_back(fallback_location: admins_path, notice: '操作成功!')
    end
  end

end
