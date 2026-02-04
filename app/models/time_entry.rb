class TimeEntry < ApplicationRecord
  belongs_to :user
  belongs_to :client
  belongs_to :asana_project, optional: true
  belongs_to :asana_task, optional: true

  validates :started_at, presence: true
  validate :stopped_at_after_started_at

  before_save :calculate_duration
  after_save :queue_asana_sync, if: :should_sync_to_asana?

  scope :active, -> { where(stopped_at: nil) }
  scope :completed, -> { where.not(stopped_at: nil) }
  scope :for_month, ->(year, month) {
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month
    where(started_at: start_date.beginning_of_day..end_date.end_of_day)
  }

  def running?
    stopped_at.nil?
  end

  def duration_in_hours
    duration_seconds / 3600.0
  end

  private

  def calculate_duration
    return unless started_at && stopped_at
    self.duration_seconds = (stopped_at - started_at).to_i
  end

  def stopped_at_after_started_at
    return unless started_at && stopped_at
    errors.add(:stopped_at, "must be after start time") if stopped_at <= started_at
  end

  def should_sync_to_asana?
    asana_task_id.present? && 
    stopped_at.present? && 
    !synced_to_asana &&
    saved_change_to_stopped_at?
  end

  def queue_asana_sync
    AsanaSyncJob.perform_later(id)
  end
end
