class LeaderboardsController < ApplicationController
  def show
    Worker.shared_instance
    @identities = Identity.leaderboard.limit(10)
  end
end