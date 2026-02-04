class ApplicationController < ActionController::API
  before_action :authenticate_user!
  
  respond_to :json
  
  private
  
  def current_user
    @current_user ||= super || User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
