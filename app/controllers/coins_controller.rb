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

class CoinsController < ApplicationController
  before_action :authorize_ability

  def authorize_ability
    authorize! :manage, Coin
  end


  def index
    session['func'] = params[:func]
    @coins = Coin.all
  end

  def new
    session['func'] = params[:func]
    @coin = Coin.new
    @url = coins_path
  end

 
  def create
    @coin = Coin.new(permit_params)

    contract = build_coin_contract(@coin.addr)

    begin
      name = contract.call.symbol()
      decimals = contract.call.decimals()
    rescue
      redirect_back(fallback_location: new_coin_path, alert: "无效币种: #{@coin.addr}")
      return
    end
    
    @coin.name = name
    @coin.decimals = decimals

    if @coin.save
      redirect_to coins_path, notice: '创建成功！'
    else
      redirect_back(fallback_location: new_coin_path, alert: "创建失败: #{@coin.errors.full_messages}")
    end
  end

  def destroy

    coin = Coin.find(params[:id])
    coin.destroy
    redirect_to coins_path

  end

  protected
  def permit_params
    params.require(:coin).permit(:addr)
  end

  def build_coin_contract(address)
    client = Ethereum::HttpClient.new(ENV["GAME_IPC_URL"])
    abi = File.read(Rails.root.join(ENV["GAME_ABI_TOKEN"]).to_s)
    contract = Ethereum::Contract.create(client: client, name: "token", address: address, abi: abi)
    contract

  end
 

end
