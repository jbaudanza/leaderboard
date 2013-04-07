class Worker
  @@worker = nil

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
      handle_message(event.data)
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

    addresses = message['x']['out'].collect{ |output| output['addr'] }
    identity = Identity.find_by_validation_address(addresses)

    if identity
      message['x']['inputs'].each do |input|
        address = input['prev_out']['addr']
        Rails.logger.info("Adding address #{address} to identity #{identity.id}")
        identity.addresses.find_or_create_by_address!(:address => address)
      end
      identity.update_balance
    end
  end
end
