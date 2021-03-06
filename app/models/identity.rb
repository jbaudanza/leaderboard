class Identity < ActiveRecord::Base
  validates_presence_of :name
  attr_accessible :name, :balance, :address_blob
  has_many :addresses
  attr_accessor :address_blob
  
  after_create :update_balance
  after_create :assign_validation_address

  before_save :parse_address_blob
  validates_uniqueness_of :name
  
  scope :leaderboard, -> {
    where('balance IS NOT NULL').order('balance DESC')
  }
  
  def to_param
    name
  end

  def self.find_by_param!(param)
    where(['LOWER(name) = ?', param.downcase]).first!
  end

  def update_balance
    total = self.addresses.sum do |address|
      address.update_balance
      address.balance
    end
    update_attributes(:balance => total)
  end
  
  def balance_in_bitcoin
    0.00000001 * balance if balance
  end
  
  def parse_address_blob
    return unless address_blob.present?
    
    address_blob.split.each do |text|
      addresses.build(:address => text)
    end
  end
  
  def rank
    Identity.where('balance > ?', self.balance).count + 1
  end

  def as_json(options={})
    super(options.merge(:include => :addresses))
  end

  def refresh
    return unless validation_address.present?

    Net::HTTP.start('blockchain.info', 80) do |http|
      response = http.get("/address/#{validation_address}?format=json")
      json = JSON.parse(response.body)
      json['txs'].each do |transaction|
        transaction['inputs'].each do |input|
          import_transaction(input)
        end
      end
    end
  
    update_balance
  end

  def import_transaction(input)
    address = input['prev_out']['addr']
    Rails.logger.info("Adding address #{address} to identity #{id}")
    addresses.find_or_create_by_address!(:address => address)
  end

  def assign_validation_address
    return if validation_address.present?

    transaction do
      validation_address = ValidationAddress.limit(1).first
      raise 'No more validation addresses to assign' unless validation_address
      update_attribute(:validation_address, validation_address.address)
      validation_address.destroy
    end
    Worker.shared_instance.subscribe_address(validation_address)
  end
end
