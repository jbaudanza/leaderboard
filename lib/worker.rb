class Worker
  @@instance = nil

  def initialize
    @reconnect_timer = 1
    connect
  end

  def reconnect
    @ws.onclose = nil
    @ws.onmessage = nil
    @ws.onerror = nil
    @ws = nil

    Rails.logger.info("WebSocket: sleeping for #{@reconnect_timer} seconds")
    EM.add_timer(@reconnect_timer) do
      connect
    end

    @reconnect_timer *= 2

    if @reconnect_timer > 2.minutes
      @reconnect_timer = 1
    end
  end

  def connect
    Rails.logger.info("WebSocket: connecting")
    @ws = Faye::WebSocket::Client.new('ws://ws.blockchain.info/inv')

    @ws.onopen = lambda do |event|
      Rails.logger.info("WebSocket: connected")
      send_json(op:'unconfirmed_sub')
      @reconnect_timer = 1
    end

    @ws.onerror = lambda do |event|
      Rails.logger.error("WebSocket: error")
      reconnect
    end

    @ws.onmessage = lambda do |event|
      begin
        handle_message(event.data)
      rescue Exception=>e
        Rails.logger.error(e)
      end
    end

    @ws.onclose = lambda do |event|
      Rails.logger.info(
        "WebSocket: disconnected: #{event.code} #{event.reason}")
      reconnect
    end
  end

  def self.shared_instance
    @@worker ||= Worker.new
  end
    
  def subscribe_address(address)
    send_json(op: 'addr_sub', addr: address)
    Rails.logger.info("Subscribing to address #{address}")
  end

  def send_json(hash)
    if @ws
      @ws.send(hash.to_json)
    end
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
