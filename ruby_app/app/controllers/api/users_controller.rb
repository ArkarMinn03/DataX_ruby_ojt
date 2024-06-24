require_relative "../../services/users/user_service.rb"
class Api::UsersController < Api::ApplicationController
  protect_from_forgery with: :null_session

  before_action :set_user, only: %i[ show update destroy ]

  def index
    @users = User.all
    render json: @users, each_serializer: UserSerializer, status: :ok
  end

  def show
    render_user_json(@user, :ok)
  end

  def create
    create_user = Users::UserUsecase.new(user_params)
    if create_user.create[:status] == :created
      render json: { message: "User created successfully", status: :created }
    else
      render json: create_user.create[:errors], status: :unprocessable_entity
    end
  end

  def update
    update_user = Users::UserUsecase.new(user_params)
    response = update_user.update(@user)
    if response[:status] == :updated
      render json: { message: "User successfully updated.", status: :updated }
    else
      render json: response[:errors], status: :unprocessable_entity
    end
  end

  def destroy
    deleted_user = Users::UserUsecase.new(nil)
    if deleted_user.destroy(@user)
      render json: { message: "User successfully deleted.", status: :ok }
    else
      render json: { message: "Something not right." }, status: :unprocessable_entity
    end
  end

  private
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :encrypted_password, :gender, :about_me, :profile)
    end

    def set_user
      @user = User.find(params[:id])
    end

    def render_user_json(user_params, status = :ok)
      render json: user_params, serializer: UserSerializer, status: status
    end
end