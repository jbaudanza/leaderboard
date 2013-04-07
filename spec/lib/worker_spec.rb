require_relative '../spec_helper'

describe 'Worker' do
  before do
    @ws = mock(Faye::WebSocket::Client, 
        :onopen= => nil, :onclose= => nil, :onmessage= => nil, :onerror= => nil)
    Faye::WebSocket::Client.stub(:new).and_return(@ws)
    @worker = Worker.new
  end

  it "should work" do
    @identity = Identity.create! do |i|
      i.name = 'Test User'
      i.validation_address = '1MMqBiVZiciztWqL635TLVMnTXeqSQ8jLU'
    end

    @worker.handle_message('{"op":"utx","x":{"hash":"0d9794aa7fa3551b128c1ed7d9da523d6d8cb90eccf5cc1e081756e34f740e42","vin_sz":1,"vout_sz":2,"lock_time":"Unavailable","size":257,"relayed_by":"96.237.251.60","tx_index":65183126,"time":1365304711,"inputs":[{"prev_out":{"value":3000000,"type":0,"addr":"1dice2vQoUkQwDMbfDACM1xz6svEXdhYb","addr_tag":"SatoshiDICE 0.01%","addr_tag_link":"http://satoshidice.com"}}],"out":[{"value":15000,"type":0,"addr":"1MMqBiVZiciztWqL635TLVMnTXeqSQ8jLU"},{"value":2885000,"type":0,"addr":"1JmcV7G3r8k7ev2EkS84MmsvxGyhiRGP84"}]}}')

    @identity.reload
    @identity.addresses.length.should == 1
  end
end
