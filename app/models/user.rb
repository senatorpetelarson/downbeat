class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  has_many :asana_workspaces, dependent: :destroy
  has_many :clients, dependent: :destroy
  has_many :time_entries, dependent: :destroy

  def asana_token_valid?
    asana_access_token.present? && 
    asana_token_expires_at.present? && 
    asana_token_expires_at > Time.current
  end
end

# app/models/jwt_denylist.rb
class JwtDenylist < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist

  self.table_name = 'jwt_denylist'
end
