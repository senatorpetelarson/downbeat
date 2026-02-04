class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  # Associations
  has_many :clients, dependent: :destroy
  has_many :time_entries, dependent: :destroy
  has_many :asana_workspaces, dependent: :destroy

  # Asana token validation
  def asana_token_valid?
    asana_access_token.present? && 
    asana_token_expires_at.present? && 
    asana_token_expires_at > Time.current
  end

  def asana_connected?
    asana_access_token.present?
  end
end
