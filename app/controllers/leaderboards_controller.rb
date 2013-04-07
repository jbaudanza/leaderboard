class LeaderboardsController < ApplicationController
  def show
    Worker.start_timer
    @identities = Identity.leaderboard.limit(10)
  end
end