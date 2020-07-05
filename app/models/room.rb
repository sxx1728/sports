# == Schema Information
#
# Table name: rooms
#
#  id             :bigint           not null, primary key
#  no             :integer          default(0), not null
#  price_addr     :string(512)      default(""), not null
#  join_coin_addr :string(512)      default(""), not null
#  time_level     :integer          default(0), not null
#  player_number  :integer          default(0), not null
#  win_number     :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Room < ApplicationRecord



end
