class Client < ApplicationRecord
  belongs_to :user
  has_many :asana_projects, dependent: :nullify
  has_many :time_entries, dependent: :destroy

  has_one_attached :logo

  validates :name, presence: true
  validates :color, format: { with: /\A#[0-9A-F]{6}\z/i }, allow_blank: true

  scope :active, -> { where(active: true) }

  def total_hours(start_date: nil, end_date: nil)
    entries = time_entries
    entries = entries.where('started_at >= ?', start_date) if start_date
    entries = entries.where('started_at <= ?', end_date) if end_date
    entries.sum(:duration_seconds) / 3600.0
  end
end
