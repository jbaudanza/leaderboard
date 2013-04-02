class LeaderboardsController < ApplicationController
  def show
    @identities = Identity.leaderboard.limit(10)
  end
end