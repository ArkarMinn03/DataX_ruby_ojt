class SessionsController < ApplicationController
  def googleAuth
    auth = request.env["omniauth.auth"]
    user = User.find_by(email: auth.info.email)
    user.update(
      google_token: auth.credentials.token,
      google_refresh_token: auth.credentials.refresh_token,
      expired_at: Time.current + auth.credentials.expires_in.to_i.seconds
    )
    redirect_to user_path(user), notice: "Google account connected successfully!!"
  end

  def disconnect
    user = User.find(params[:id])
    if user.google_token
      revoke_token(user)
      user.update(
        google_token: nil,
        google_refresh_token: nil,
        expired_at: nil
      )
      redirect_to user_path(user), notice: "Successfully disconnected from google."
    else
      redirect_to user_path(user), notice: "Google account is not connected in the first place."
    end
  end

  private
    def revoke_token(user)
      access_token = user.google_token
      url = "https://accounts.google.com/o/oauth2/revoke?token=#{access_token}"
      response = Net::HTTP.get_response(URI.parse(url))
      if response.code != '200'
        flash[:notice] = "Failed to revoke token."
      end
    end
end