class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update, :approve, :destroy]
  before_action :authenticate_user!
  before_action :check_admin
  before_action :count_admins

  def new
    @user = User.new
  end

  def index
    if params[:approved] == "false"
      @users = User.where(approved: false).order(:email)
    else
      @users = User.all.order(:email)
    end
  end

  def edit
  end

  def update
    count_admins
    if @admin_count == 1 && @user.admin? && !params[:admin]
      render action: 'edit'
      return
    end
    if @user.update(user_params)
      redirect_to action: "index" , notice: 'User was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    if @user.destroy
      redirect_to users_path, notice: "User was successfully deleted."
    else
      redirect_to :back, alert: "An error occurred when deleting the user."
    end
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to users_path, notice: "User was successfully created."
    else
      render :new
    end
  end
  
  def approve
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:approved, :organization_id, :admin, :password, :password_confirmation, :email)
    end

    def check_admin
      unless current_user.admin?
        flash[:notice] = "Admin account required to access users page."
        redirect_to trails_path
      end
    end

    def count_admins
      @admin_count = User.where(admin: "t").count
    end
end
