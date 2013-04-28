class LeaderboardsController < ApplicationController
  def show
    #  find the identity in the whole set
    # grab a subset, say 5 before and 24 after
    @identities = Identity.leaderboard.limit(10)
    
    
    # Worker.shared_instance
    if params[:name]
      @identity = Identity.where(['LOWER(name) = ?', params[:name].downcase]).first!  
    else
      @identity = @identities.first
    end
  end
end