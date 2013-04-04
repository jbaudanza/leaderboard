class Address < ActiveRecord::Base
  belongs_to :identity
  attr_accessible :balance
  
  def update_balance
    value = Address.value_for_key(address)
    if value
      update_attributes(:balance => value)
    end
  end
  
  def self.value_for_key(address)
    url = "http://blockchain.info/address/#{address}?format=json"
    uri = URI(url)
    client = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = client.request(request)
  
    value = nil
    if response.is_a?(Net::HTTPSuccess)
      parsed_response = JSON.parse(response.body)
      value = parsed_response["final_balance"]
    else 
      puts "Error accessing blockchain API"
    end
  
    puts value
    value
  end
  
end