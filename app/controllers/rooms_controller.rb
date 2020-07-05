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

class RoomsController < ApplicationController
  before_action :authorize_ability

  def authorize_ability
    authorize! :manage, Room
  end


  def index
    session['func'] = params[:func]
    client = Ethereum::HttpClient.new(ENV["GAME_IPC_URL"])
    main_contract = build_main_contract(client)
    count = main_contract.call.get_total_room()
    room_ids, room_addresses = main_contract.call.get_room_list(0, count)

    @rooms = (0..room_ids.size-1).map{|i|

      room_contract = build_room_contract(client, "0x" + room_addresses[i])
      detail = room_contract.call.get_room_info()

      price_contract = build_coin_contract(client, "0x" + detail[0])
      price_name = price_contract.call.symbol()
      join_contract = build_coin_contract(client, "0x" + detail[1])
      join_name = join_contract.call.symbol()


      decimals = Coin.where(name: join_name).first.decimals
 
      room = Room.new
      room.id = room_ids[i]
      room.price_addr = price_name
      room.join_coin_addr = join_name
      room.player_number = detail[2]
      room.begin_at = Time.at(detail[3]).to_datetime
      room.time_level = detail[4]/60
      room.invent_level = detail[5]/(10 ** decimals)
      room.cur_round = detail[6]
      room.next_round_at = Time.at(detail[9]).to_datetime
      room.interval_minute = detail[11]/60
      room
    }.sort_by{|r| r.id}


  end

  def new
    session['func'] = params[:func]
    @room = Room.new
    @url = rooms_path
  end

 
  def create
    room = Room.new(permit_params)

    client = Ethereum::HttpClient.new(ENV["GAME_IPC_URL"])
    contract = build_main_contract(client)

    coin_contract = build_coin_contract(client, room.join_coin_addr)
    decimals = coin_contract.call.decimals()
 
    result = contract.transact_and_wait.creat_room(room.price_addr,
                                         room.join_coin_addr,
                                         room.time_level * 60,
                                         room.invent_level * (10 ** decimals),
                                         room.player_number,
                                         room.winer_number,
                                         room.interval_minute * 60,
                                         room.rate,
                                         100)

    if result.mined?
      redirect_to rooms_path, notice: '创建成功！'
    else
      redirect_back(fallback_location: new_room_path, alert: "创建失败: #{room.errors.full_messages}")
    end
  end

  def destroy

    client = Ethereum::HttpClient.new(ENV["GAME_IPC_URL"])
    main_contract = build_main_contract(client)
  
    result = main_contract.transact_and_wait.del_room(params[:id].to_i)

    if result.mined?
      redirect_to rooms_path, notice: '删除成功！'
    else
      redirect_back(fallback_location: rooms_path, alert: "删除失败: #{room.errors.full_messages}")
    end
  end

  protected
  def permit_params
    params.require(:room).permit(:id, :price_addr, :join_coin_addr, :time_level, :invent_level, :player_number, :winer_number, :rate,  :interval_minute)
  end

  def build_room_contract(client, address)
    abi = File.read(Rails.root.join(ENV["GAME_ABI_DETAIL"]).to_s)
    contract = Ethereum::Contract.create(client: client, name: "gameDetailInfo", address: address, abi: abi)
    contract

  end
 

  def build_main_contract(client)
    abi = File.read(Rails.root.join(ENV["GAME_ABI_MAIN"]).to_s)
    contract = Ethereum::Contract.create(client: client, name: "priceGame", address: ENV["GAME_MAIN_CONTRACT_ADDRESS"], abi: abi)
    key = Eth::Key.new(priv:ENV["GAME_CONTRACT_ADMIN_KEY"])
    contract.key = key

    contract
  end

  def build_coin_contract(client, address)
    abi = File.read(Rails.root.join(ENV["GAME_ABI_TOKEN"]).to_s)
    contract = Ethereum::Contract.create(client: client, name: "token", address: address, abi: abi)
    contract

  end
 


end
