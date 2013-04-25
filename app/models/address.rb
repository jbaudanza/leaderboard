class Address < ActiveRecord::Base
  belongs_to :identity
  attr_accessible :balance, :address
  
  def update_balance
    value = Address.value_for_key(address)
    if value
      update_attributes(:balance => value)
    end
  end
  
  def self.value_for_key(address)
    url = "http://blockchain.info/q/addressbalance/#{address}"
    uri = URI(url)
    client = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = client.request(request)
  
    value = nil
    if response.is_a?(Net::HTTPSuccess)
      value = response.body
    else 
      Rails.logger.error "Error response code:#{response.code} accessing blockchain API with URL #{url}"
      nil
    end
  
    value
  end
  
end