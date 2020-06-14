class Captcha < ApplicationRecord
  
  validates_format_of   :phone,
                        :with       => /1[0-9]{10}/,
                        :message    => 'phone must be valid'


  before_create :generate_info

  def generate_info  
    self.captcha = SecureRandom.rand(100000..999999)
    self.expire_at = DateTime.current + 2.minutes
  end  

  def self.valid_phone? phone
    /1[0-9]{10}/ =~ phone
  end
  


end
