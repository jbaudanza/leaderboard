class Identity < ActiveRecord::Base
  validates_presence_of :name
  attr_accessible :name, :balance
  has_many :addresses

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
    return nil unless balance
    btc = 0.00000001 * balance
    
    btc
  end
end