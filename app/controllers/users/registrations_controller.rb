class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        # Don't sign in - just return the user
        render json: {
          user: {
            id: resource.id,
            email: resource.email
          }
        }, status: :created
      else
        expire_data_after_sign_in!
        render json: {
          user: {
            id: resource.id,
            email: resource.email
          }
        }, status: :created
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      render json: {
        errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end