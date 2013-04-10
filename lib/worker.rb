class Worker
  @@instance = nil

  def initialize
    @ws = Faye::WebSocket::Client.new('ws://ws.blockchain.info/inv')

    @ws.onopen = lambda do |event|
      Rails.logger.info("Connected to blockchain.info WebSocket")
      @ws.send('{"op":"unconfirmed_sub"}')
      #ws.send('{"op":"addr_sub", "addr":"1ApixU1aYsHUdJ4Em64xsG6XtqTzjAXACr"}')
    end

    @ws.onerror = lambda do |event|
      Rails.logger.error("WebSocket error")
    end

    @ws.onmessage = lambda do |event|
      begin
        handle_message(event.data)
      rescue e
        Rails.logger.error(e)
      end
    end

    @ws.onclose = lambda do |event|
      Rails.logger.info(
        "Disconnected from blockchain.info WebSocket. #{event.code} #{event.reason}")
      @ws = nil
    end
  end

  def self.shared_instance
    @@worker ||= Worker.new
  end
    
  def subscribe_address(address)
    message = '{"op":"addr_sub", "addr":"' + address + '"}'
    @ws.send(message)
    Rails.logger.info("Subscribing to address #{address}")
  end

  def handle_message(json)
    message = JSON.parse(json)
    in_addresses = message['x']['inputs'].map{|input| input['prev_out']['addr']}
    out_addresses = message['x']['out'].map{|output| output['addr'] }

    identity = Identity.find_by_validation_address(out_addresses)

    # See if this transaction references a validation addresses
    if identity
      in_addresses.each do |address|
        Rails.logger.info("Adding address #{address} to identity #{identity.id}")
        identity.addresses.find_or_create_by_address!(:address => address)
      end
      identity.update_balance
    else
      # Otherwise, check if the transaction references any user wallet addresses
      addresses = Address.where(:address => in_addresses + out_addresses)
      addresses.each do |address|
        Rails.logger.info("Updating balance for #{address.address}")
        address.identity.update_balance
      end
    end
  end
end
