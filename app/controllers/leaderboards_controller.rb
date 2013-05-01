class LeaderboardsController < ApplicationController
  def show
      @identities = Identity.leaderboard
          
    if params[:name]
      @identity = Identity.where(['LOWER(name) = ?', params[:name].downcase]).first!  
    else
      @identity = @identities.first
    end
  end
end