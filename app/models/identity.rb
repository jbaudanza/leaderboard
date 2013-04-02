class Identity < ActiveRecord::Base
  validates_presence_of :name
  attr_accessible :name

  scope :leaderboard, -> {
      where('balance IS NOT NULL').order('balance DESC')
  }
end