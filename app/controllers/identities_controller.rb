class IdentitiesController < ApplicationController
  def create
    @identity = Identity.new(params[:identity])
    @identity.save!
    render :text => 'It worked!'
  end
  
  def new
    @identity = Identity.new
  end
  
  def show
    @identity = Identity.find(params[:id])
  end
end