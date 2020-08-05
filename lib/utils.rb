module Utils
  def same_address? one, another

    one = one[2..] if one[0..1] == '0x'
    one = one.downcase
    another = another[2..] if another[0..1] == '0x'
    another = another.downcase
    one == another
  end
end
