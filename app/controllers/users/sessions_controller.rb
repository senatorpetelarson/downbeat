class Users::SessionsController < Devise::SessionsController
  respond_to :json
  # Skip authenticity token for API
  skip_before_action :verify_signed_out_user, only: :destroy

  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    render json: {
      user: {
        id: resource.id,
        email: resource.email
      }
    }, status: :ok
  end

  private

  def respond_with(resource, _opts = {})
    render json: {
      user: {
        id: resource.id,
        email: resource.email
      }
    }, status: :ok
  end

  def respond_to_on_destroy(*args)
    render json: { message: 'Logged out successfully' }, status: :ok
  end
end