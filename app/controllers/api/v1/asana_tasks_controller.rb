module Api
  module V1
    class AsanaTasksController < ApplicationController
      def index
        @project = AsanaProject.joins(:asana_workspace)
                              .where(asana_workspaces: { user_id: current_user.id })
                              .find(params[:asana_project_id])
        
        # Always sync tasks to get latest from Asana
        sync_tasks_for_project(@project)

        render json: @project.asana_tasks.reload.map { |task| task_json(task) }
      end

      private

      def sync_tasks_for_project(project)
        return unless current_user.asana_token_valid?

        client = Asana::Client.new do |c|
          c.authentication :oauth2, bearer_token: current_user.asana_access_token
        end

        tasks = client.tasks.find_by_project(project: project.project_gid)
        
        tasks.each do |task|
          asana_task = project.asana_tasks.find_or_create_by(task_gid: task.gid) do |t|
            t.name = task.name
          end
          # Update name if task already exists
          asana_task.update(name: task.name) if asana_task.persisted? && !asana_task.new_record?
        end
      rescue StandardError => e
        Rails.logger.error("Failed to sync tasks: #{e.message}")
      end

      def task_json(task)
        {
          id: task.id,
          task_gid: task.task_gid,
          name: task.name,
          project_id: task.asana_project_id,
          created_at: task.created_at
        }
      end
    end
  end
end