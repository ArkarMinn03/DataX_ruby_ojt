class SessionsController < ApplicationController

  # skip_before_action :verify_authenticity_token

  def googleAuth
    auth = request.env["omniauth.auth"]
    user = User.find_by(email: auth.info.email)
    user.update(
      google_token: auth.credentials.token,
      google_refresh_token: auth.credentials.refresh_token
    )
    redirect_to user_path(user), notice: "Google account connected successfully!!"
  end
end