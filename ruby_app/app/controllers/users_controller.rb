class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]


  def index
    @users = User.all.decorate
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    respond_to do |format|
      begin
        user_usecase = Users::UserUsecase.new(user_params)
        response = user_usecase.create
        if response[:status] == :created
          format.html { redirect_to users_path, notice: t('messages.common.create_success', data: "User") }
          format.json { render :index, status: :ok, location: @user }
        else
          flash[:errors] = response[:errors]
          format.html { redirect_to new_user_path, status: :unprocessable_entity, user: response[:user], errors: response[:errors] }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      rescue StandardError => each
        logger.error "Something went wrong. #{e.message}"
        format.html { render file: "#{Rails.root}/public/500.html", layout: true, status: :internal_server_error}
      end
    end
  end

  def edit
  end

  def update
    updated_user = Users::UserUsecase.new(user_params)
    respond_to do |format|
      if (updated_user.update(@user))
        format.html { redirect_to @user, notice: t('messages.common.update_success', data: "User") }
        format.json { render :show, status: :ok, location: @user}
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    delete_user = Users::UserUsecase.new(nil)

    respond_to do |format|
      if delete_user.destroy(@user)
        format.html { redirect_to users_url, notice: t('messages.common.destroy_success', data: "User") }
        format.json { head :no_content }
      end
    end
  end

  private
    def set_user
      @user = User.find(params[:id]).decorate
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :encrypted_password, :about_me, :profile, :gender)
    end
end