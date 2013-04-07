class Identity < ActiveRecord::Base
  validates_presence_of :name
  attr_accessible :name, :balance, :address_blob
  has_many :addresses
  attr_accessor :address_blob
  
  after_create :update_balance
  after_create :assign_validation_address

  before_save :parse_address_blob
  
  scope :leaderboard, -> {
    where('balance IS NOT NULL').order('balance DESC')
  }
  
  def update_balance
    total = 0
    self.addresses.each do |address|
      address.update_balance
      total = total + address.balance
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

  def assign_validation_address
    transaction do
      validation_address = ValidationAddress.limit(1).first
      raise 'No more validation addresses to assign' unless validation_address
      update_attribute(:validation_address, validation_address.address)
      validation_address.destroy
    end
  end
end
