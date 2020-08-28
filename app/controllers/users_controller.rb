# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: admins
#
#  id                     :integer          not null, primary key
#  email                  :string(128)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null #  reset_password_token   :string(128)
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
#  unconfirmed_email      :string(255) #  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(128)
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  approved               :boolean          default(FALSE), not null
#

class UsersController < ApplicationController
  before_action :authorize_ability

  def authorize_ability
    authorize! :manage, User
  end


  def index
    session['func'] = params[:func]
    session['func_index'] = params[:func_index]
    @users = Promoter::User.all.paginate page: params[:page], per_page: 10
  end

  def gen_code
		user = Promoter::User.find(params[:id])
    code = 10000 + rand(90000)
    while PromoterUser.exist?(code: code) do
      code = 10000 + rand(90000)
    end

    user.promoter_user.build(code: code, enabled: true).save!
    redirect_to users_path, notice: '生成成功！'
	end

  def enable_code
		user = Promoter::User.find(params[:id])
    user.promoter_code.update!(enabled: true)
    redirect_to users_path, notice: '使能成功！'
	end

  def disable_code
		user = Promoter::User.find(params[:id])
    user.promoter_code.update!(enabled: false)
    redirect_to users_path, notice: '关闭成功！'
	end

  def gen_code
		user = Promoter::User.find(params[:id])
    code = 100000 + rand(900000)
    while PromoterCode.exists?(code: code) do
      code = 100000 + rand(900000)
    end

    user.build_promoter_code(code: code, enabled: true).save!
    redirect_to users_path, notice: '生成成功！'
	end





end
