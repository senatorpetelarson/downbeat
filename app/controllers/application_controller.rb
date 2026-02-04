class ApplicationController < ActionController::API
  respond_to :json
  before_action :authenticate_user!

  private

  def current_user
    @current_user ||= warden.user
  end
end
