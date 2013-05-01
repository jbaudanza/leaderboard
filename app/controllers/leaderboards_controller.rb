class LeaderboardsController < ApplicationController
  def show
      @identities = Identity.leaderboard
          
    if params[:name]
      @identity = Identity.find_by_param!(params[:name])
    else
      @identity = @identities.first
    end
  end
end