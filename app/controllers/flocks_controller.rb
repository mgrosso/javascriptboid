class FlocksController < ApplicationController
  inherit_resources
  respond_to :html, :json
  actions :index, :show, :new, :create, :update, :destroy
end
