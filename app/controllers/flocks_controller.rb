class FlocksController < ApplicationController
  inherit_resources
  respond_to :html, :json
  actions :index, :show, :new, :create, :update, :destroy, :homepage
  def homepage
      p "home"
      @flock = Flock.find(1)
      respond_with @flock
  end
end
