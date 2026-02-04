class AsanaTask < ApplicationRecord
  belongs_to :asana_project
  has_many :time_entries, dependent: :nullify

  validates :task_gid, presence: true, uniqueness: { scope: :asana_project_id }
  validates :name, presence: true

  def stale?
    cached_at.nil? || cached_at < 1.hour.ago
  end
end
