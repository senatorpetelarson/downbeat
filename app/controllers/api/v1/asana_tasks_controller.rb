module Api
  module V1
    class AsanaTasksController < ApplicationController
      def index
        @project = AsanaProject.joins(:asana_workspace)
                              .where(asana_workspaces: { user_id: current_user.id })
                              .find(params[:asana_project_id])
        
        # Refresh tasks if stale or empty
        if @project.asana_tasks.empty? || @project.asana_tasks.any?(&:stale?)
          sync_tasks_for_project(@project)
        end

        render json: @project.asana_tasks.map { |task| task_json(task) }
      end

      private

      def sync_tasks_for_project(project)
        return unless current_user.asana_token_valid?

        client = Asana::Client.new do |c|
          c.authentication :oauth2, current_user.asana_access_token
        end

        tasks = client.tasks.find_by_project(project: project.project_gid)
        
        tasks.each do |task|
          project.asana_tasks.find_or_create_by(task_gid: task.gid) do |t|
            t.name = task.name
            t.cached_at = Time.current
          end
        end
      rescue Asana::Errors::AsanaError => e
        Rails.logger.error("Failed to sync tasks: #{e.message}")
      end

      def task_json(task)
        {
          id: task.id,
          task_gid: task.task_gid,
          name: task.name,
          project_id: task.asana_project_id,
          cached_at: task.cached_at
        }
      end
    end
  end
end
