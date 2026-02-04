class AsanaWorkspace < ApplicationRecord
  belongs_to :user
  has_many :asana_projects, dependent: :destroy

  validates :workspace_gid, presence: true, uniqueness: { scope: :user_id }
  validates :name, presence: true
end
