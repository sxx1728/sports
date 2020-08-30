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

class ChainlyConfigsController < ApplicationController
  before_action :authorize_ability

  def authorize_ability
    authorize! :manage, ChainlyConfig
  end


  def edit
    session['func'] = params[:func]
    @chainly_config = ChainlyConfig.first 
    @url = chainly_config_path(id: @chainly_config.id)
  end

  def update
    @chainly_config = ChainlyConfig.first
 
    if @chainly_config.update_attributes(permit_params)

      config_contract = Contract.build_config_contract
      ret = config_contract.transact_and_wait.update_fee_rate(
        @chainly_config.platform_fee_rate,
        0,
        @chainly_config.arbitration_fee_rate
      )

      Rails.logger.info(ret)
      if ret.mined
        @chainly_config.save!
        redirect_to edit_chainly_config_path, notice: '更新成功！'
      else
        Rails.logger.error(result)
      end
 

    else
      redirect_back(fallback_location: edit_chainly_config_path, alert: "更新失败#{@chainly_config.errors.full_messages}")
    end
  end

  protected
  def permit_params
    params.require(:chainly_config).permit(:platform_fee_rate, :promoter_fee_rate, :arbitration_fee_rate)
  end

end
