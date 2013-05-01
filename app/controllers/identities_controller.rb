class IdentitiesController < ApplicationController
  def create
    @identity = Identity.new(params[:identity])

    existing = Identity.find_by_name(@identity.name)
    if existing
      @identity = existing
    else
      @identity.save!
    end

    redirect_to name_url(@identity.name)
  end

  def refresh
    @identity = Identity.find_by_param!(params[:id])
    @identity.refresh
    render :json => @identity
  end
  
  def new
    @identity = Identity.new
  end
  
  def show
    @identity = Identity.find_by_param!(params[:id])
    render :json => @identity
  end
end