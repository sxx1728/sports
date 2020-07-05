module GoogleAuthenticator

  def generate_secret_key
    Base32.encode( (0...10).map{(SecureRandom.random_number(255)).chr}.join )
  end

  def qrcode_url(label, user, key)
    "otpauth://totp/#{label}?secret=#{key}&issuer=#{label}"
  end

  def verify?(secret_key, key)
    return false if secret_key.blank? or key.blank?
    valid_keys(secret_key).include?(key.to_i)
  end

  def valid_keys(secret_key)
    keys = []
    duration = 30
    now = Time.now.to_i / duration
    key = Base32.decode(secret_key)
    sha = OpenSSL::Digest::Digest.new('sha1')

    (-1..1).each do |x|
      bytes = [ now + x ].pack('>q').reverse
      hmac = OpenSSL::HMAC.digest(sha, key.to_s, bytes)
      offset = nil
      offset = hmac[-1].ord & 0x0F
      hash = hmac[offset...offset + 4]
      code = hash.reverse.unpack('L')[0]
      code &= 0x7FFFFFFF
      code %= 1000000
      keys << code
    end

    keys
  end

end

