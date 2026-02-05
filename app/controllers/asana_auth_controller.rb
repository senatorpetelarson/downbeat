class AsanaAuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [:callback]

  # Step 1: Generate authorization URL for frontend
  def authorize
    state_token = generate_state_token(current_user.id)
    
    asana_auth_url = "https://app.asana.com/-/oauth_authorize?" + {
      client_id: ENV['ASANA_CLIENT_ID'],
      redirect_uri: ENV['ASANA_REDIRECT_URI'],
      response_type: 'code',
      state: state_token
    }.to_query

    render json: { authorization_url: asana_auth_url }
  end

  # Step 2: Handle OAuth callback from Asana
  # def callback
  #   # Handle errors from Asana
  #   if params[:error]
  #     redirect_to "#{ENV['FRONTEND_URL']}/settings?asana_error=#{params[:error]}"
  #     return
  #   end

  #   # Verify state token to prevent CSRF
  #   user_id = verify_state_token(params[:state])
  #   unless user_id
  #     redirect_to "#{ENV['FRONTEND_URL']}/settings?asana_error=invalid_state"
  #     return
  #   end

  #   # Exchange code for tokens
  #   response = HTTParty.post('https://app.asana.com/-/oauth_token', {
  #     body: {
  #       grant_type: 'authorization_code',
  #       client_id: ENV['ASANA_CLIENT_ID'],
  #       client_secret: ENV['ASANA_CLIENT_SECRET'],
  #       redirect_uri: ENV['ASANA_REDIRECT_URI'],
  #       code: params[:code]
  #     }
  #   })

  #   if response.success?
  #     token_data = JSON.parse(response.body)
      
  #     user = User.find(user_id)
  #     user.update(
  #       asana_access_token: token_data['access_token'],
  #       asana_refresh_token: token_data['refresh_token'],
  #       asana_token_expires_at: token_data['expires_in'].seconds.from_now
  #     )

  #     # Redirect to frontend with success
  #     redirect_to "#{ENV['FRONTEND_URL']}/settings?asana_success=true"
  #   else
  #     # Redirect to frontend with error
  #     redirect_to "#{ENV['FRONTEND_URL']}/settings?asana_error=token_exchange_failed"
  #   end
  # end
  
  def callback
    # Handle errors from Asana
    if params[:error]
      render json: { error: params[:error] }, status: :unprocessable_entity
      return
    end

    # Verify state token to prevent CSRF
    user_id = verify_state_token(params[:state])
    unless user_id
      render json: { error: 'invalid_state' }, status: :unprocessable_entity
      return
    end

    # Exchange code for tokens
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
      
      user = User.find(user_id)
      user.update(
        asana_access_token: token_data['access_token'],
        asana_refresh_token: token_data['refresh_token'],
        asana_token_expires_at: token_data['expires_in'].seconds.from_now
      )

      render json: { 
        success: true, 
        message: 'Asana connected successfully!',
        user: {
          id: user.id,
          email: user.email,
          asana_connected: true
        }
      }
    else
      render json: { error: 'token_exchange_failed', details: response.body }, status: :unprocessable_entity
    end
  end

  private

  def generate_state_token(user_id)
    token = SecureRandom.urlsafe_base64(32)
    user = User.find(user_id)
    user.update(asana_oauth_state: token)
    token
  end

  def verify_state_token(token)
    return nil unless token.present?
    user = User.find_by(asana_oauth_state: token)
    return nil unless user
    
    # Clear the state after use (one-time token)
    user.update(asana_oauth_state: nil)
    user.id
  end
end