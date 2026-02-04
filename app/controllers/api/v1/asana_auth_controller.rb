class AsanaAuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [:callback]

  def callback
    # Exchange code for token
    response = HTTParty.post('https://app.asana.com/-/oauth_token', {
      body: {
        grant_type: 'authorization_code',
        client_id: ENV['ASANA_CLIENT_ID'],
        client_secret: ENV['ASANA_CLIENT_SECRET'],
        redirect_uri: ENV['ASANA_REDIRECT_URI'],
        code: params[:code]
      }
    })

    if response.success?
      token_data = JSON.parse(response.body)
      
      current_user.update(
        asana_access_token: token_data['access_token'],
        asana_refresh_token: token_data['refresh_token'],
        asana_token_expires_at: token_data['expires_in'].seconds.from_now
      )

      # Redirect to frontend with success
      redirect_to "#{ENV['FRONTEND_URL']}/asana/connected"
    else
      # Redirect to frontend with error
      redirect_to "#{ENV['FRONTEND_URL']}/asana/error"
    end
  end
end
