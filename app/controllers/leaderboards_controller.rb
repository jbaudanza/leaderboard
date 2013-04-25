class LeaderboardsController < ApplicationController
  def show
    # Worker.shared_instance
    if params[:name]
      @identity = Identity.where(['LOWER(name) = ?', params[:name].downcase]).first!  
    end
    
    #  find the identity in the whole set
    # grab a subset, say 5 before and 24 after
    @identities = Identity.leaderboard.limit(10)
  end
end