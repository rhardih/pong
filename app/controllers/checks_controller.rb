class ChecksController < ApplicationController
  before_action :set_check, only: [:show, :edit, :update, :destroy]

  # GET /checks
  def index
    @checks = Check.all
  end

  # GET /checks/1
  def show
  end

  # GET /checks/new
  def new
    @check = Check.new
  end

  # GET /checks/1/edit
  def edit
  end

  # POST /checks
  def create
    @check = Check.new(check_params)

    if @check.save
      redirect_to @check, notice: 'Check was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /checks/1
  def update
    if @check.update(check_params)
      redirect_to @check, notice: 'Check was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /checks/1
  def destroy
    @check.destroy
    redirect_to checks_url, notice: 'Check was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_check
      @check = Check.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def check_params
      params.require(:check).permit(:name, :interval, :protocol, :url)
    end
end
