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

class KycsController < ApplicationController
  before_action :authorize_ability

  def authorize_ability
    authorize! :manage, Kyc
  end


  def index
    session['func'] = params[:func]
    session['func_index'] = params[:func_index]
    if(session['func_index'] == '1')
      @kycs = Kyc.where(state: 'verifing').order(updated_at: :desc).paginate page: params[:page], per_page: 10
    else
      @kycs = Kyc.all.order(updated_at: :desc).paginate page: params[:page], per_page: 10
    end
  end

  def accept
		kyc = Kyc.find(params[:id])
    binding.pry
		kyc.accept!
    redirect_to kycs_path, notice: '审核完成！'
	end

  def reject
		kyc = Kyc.find(params[:id])
		kyc.reject!
    redirect_to kycs_path, notice: '已驳回！'
	end



end
