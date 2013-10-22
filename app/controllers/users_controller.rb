class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update]
  before_action :authenticate_user!
  before_action :check_admin
  before_action :count_admins


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
  
  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:approved, :organization_id, :admin)
    end

    def check_admin
      # TODO: make error message
      redirect_to controller: "trails", action: "index", notice: "Admin account required to access users page." unless current_user.admin?
    end

    def count_admins
      @admin_count = User.where(admin: "t").count
    end
end
