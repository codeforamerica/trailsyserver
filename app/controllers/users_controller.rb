class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update]
  before_action :authenticate_user!
  before_action :check_admin


  def index
    if params[:approved] == "false"
      @users = User.find_all_by_approved(false)
    else
      @users = User.all
    end
  end

  def edit
  end

  def update
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
      params.require(:user).permit(:approved, :organization)
    end

    def check_admin
      # TODO: make error message
      redirect_to controller: "trails", action: "index" unless current_user.admin?
    end

end
