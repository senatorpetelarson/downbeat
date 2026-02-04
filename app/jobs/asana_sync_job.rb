class AsanaSyncJob < ApplicationJob
  queue_as :default

  retry_on Asana::Errors::RateLimitEnforced, wait: :exponentially_longer, attempts: 5
  retry_on Asana::Errors::ServerError, wait: 5.seconds, attempts: 3

  def perform(time_entry_id)
    time_entry = TimeEntry.find(time_entry_id)
    
    # Skip if already synced or no task to sync to
    return if time_entry.synced_to_asana || time_entry.asana_task_id.blank?
    
    # Skip if user's token is invalid
    return unless time_entry.user.asana_token_valid?

    AsanaService.post_time_entry_to_task(time_entry)
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("TimeEntry #{time_entry_id} not found for Asana sync")
  rescue Asana::Errors::AsanaError => e
    Rails.logger.error("Asana sync failed for TimeEntry #{time_entry_id}: #{e.message}")
    raise # Re-raise to trigger retry logic
  end
end
