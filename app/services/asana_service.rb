class AsanaService
  class << self
    # Post a time entry as a story/comment on an Asana task
    def post_time_entry_to_task(time_entry)
      return unless time_entry.asana_task && time_entry.stopped_at.present?

      client = asana_client(time_entry.user)
      task_gid = time_entry.asana_task.task_gid
      
      # Format the comment
      duration_text = format_duration(time_entry.duration_seconds)
      date_text = time_entry.started_at.strftime("%B %d, %Y")
      
      comment_text = "⏱️ Logged #{duration_text} on #{date_text}"
      comment_text += "\n#{time_entry.notes}" if time_entry.notes.present?
      
      # Post to Asana
      story = client.stories.create_story_for_task(
        task_gid: task_gid,
        text: comment_text
      )
      
      # Mark as synced
      time_entry.update(
        synced_to_asana: true,
        asana_story_gid: story.gid
      )
      
      Rails.logger.info("Synced TimeEntry #{time_entry.id} to Asana task #{task_gid}")
    rescue Asana::Errors::AsanaError => e
      Rails.logger.error("Failed to sync TimeEntry #{time_entry.id}: #{e.message}")
      raise
    end

    # Refresh Asana access token if expired
    def refresh_token(user)
      return unless user.asana_refresh_token.present?

      response = HTTParty.post('https://app.asana.com/-/oauth_token', {
        body: {
          grant_type: 'refresh_token',
          client_id: ENV['ASANA_CLIENT_ID'],
          client_secret: ENV['ASANA_CLIENT_SECRET'],
          refresh_token: user.asana_refresh_token
        }
      })

      if response.success?
        token_data = JSON.parse(response.body)
        user.update(
          asana_access_token: token_data['access_token'],
          asana_refresh_token: token_data['refresh_token'],
          asana_token_expires_at: token_data['expires_in'].seconds.from_now
        )
        true
      else
        Rails.logger.error("Failed to refresh Asana token for user #{user.id}")
        false
      end
    end

    private

    def asana_client(user)
      # Try to refresh token if expired
      if user.asana_token_expires_at && user.asana_token_expires_at < 5.minutes.from_now
        refresh_token(user)
        user.reload
      end

      Asana::Client.new do |c|
        c.authentication :oauth2, user.asana_access_token
      end
    end

    def format_duration(seconds)
      hours = seconds / 3600
      minutes = (seconds % 3600) / 60
      
      parts = []
      parts << "#{hours}h" if hours > 0
      parts << "#{minutes}m" if minutes > 0
      
      parts.any? ? parts.join(' ') : '0m'
    end
  end
end
