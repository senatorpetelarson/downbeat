class AsanaProject < ApplicationRecord
  belongs_to :asana_workspace
  belongs_to :client, optional: true
  has_many :asana_tasks, dependent: :destroy
  has_many :time_entries, dependent: :nullify

  validates :project_gid, presence: true, uniqueness: { scope: :asana_workspace_id }
  validates :name, presence: true
end
