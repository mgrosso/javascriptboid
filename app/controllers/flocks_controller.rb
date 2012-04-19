class FlocksController < ApplicationController
  # GET /flocks
  # GET /flocks.json
  def index
    @flocks = Flock.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @flocks }
    end
  end

  # GET /flocks/1
  # GET /flocks/1.json
  def show
    @flock = Flock.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @flock }
    end
  end

  # GET /flocks/new
  # GET /flocks/new.json
  def new
    @flock = Flock.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @flock }
    end
  end

  # GET /flocks/1/edit
  def edit
    @flock = Flock.find(params[:id])
  end

  # POST /flocks
  # POST /flocks.json
  def create
    @flock = Flock.new(params[:flock])

    respond_to do |format|
      if @flock.save
        format.html { redirect_to @flock, notice: 'Flock was successfully created.' }
        format.json { render json: @flock, status: :created, location: @flock }
      else
        format.html { render action: "new" }
        format.json { render json: @flock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /flocks/1
  # PUT /flocks/1.json
  def update
    @flock = Flock.find(params[:id])

    respond_to do |format|
      if @flock.update_attributes(params[:flock])
        format.html { redirect_to @flock, notice: 'Flock was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @flock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /flocks/1
  # DELETE /flocks/1.json
  def destroy
    @flock = Flock.find(params[:id])
    @flock.destroy

    respond_to do |format|
      format.html { redirect_to flocks_url }
      format.json { head :no_content }
    end
  end
end
