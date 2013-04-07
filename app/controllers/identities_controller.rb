class IdentitiesController < ApplicationController
  def create
    @identity = Identity.new(params[:identity])
    @identity.save!

    redirect_to root_url
  end

  def refresh
    @identity = Identity.find(params[:id])
    @identity.refresh
    render :json => @identity
  end
  
  def new
    @identity = Identity.new
  end
  
  def show
    @identity = Identity.find(params[:id])
    render :json => @identity
  end
end