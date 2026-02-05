module Api
	module V1
		class AsanaTasksController < ApplicationController
			def index
				@project = AsanaProject.joins(:asana_workspace)
					.where(asana_workspaces: { user_id: current_user.id })
					.find(params[:asana_project_id])
				
				# Always sync tasks to get latest from Asana
				if sync_tasks_for_project(@project)
					render json: @project.asana_tasks.reload.map { |task| task_json(task) }
				else
					render json: { 
						error: 'Failed to sync tasks. Please reconnect your Asana account.' 
					}, status: :unauthorized
				end
			end

			private

			def sync_tasks_for_project(project)
				Rails.logger.info "Attempting to sync tasks for project: #{project.project_gid}"
				
				# Try to refresh token if needed
				unless ensure_asana_token_valid
					Rails.logger.error "Token validation/refresh failed"
					return false
				end

				client = Asana::Client.new do |c|
					c.authentication :oauth2, bearer_token: current_user.asana_access_token
				end

				tasks = client.tasks.find_by_project(project: project.project_gid)
				Rails.logger.info "Found #{tasks.count} tasks from Asana"
				
				tasks.each do |task|
					asana_task = project.asana_tasks.find_or_create_by(task_gid: task.gid) do |t|
						t.name = task.name
					end
					asana_task.update(name: task.name) if asana_task.persisted? && !asana_task.new_record?
				end
				
				true
			rescue StandardError => e
				Rails.logger.error("Failed to sync tasks: #{e.class} - #{e.message}")
				Rails.logger.error(e.backtrace.join("\n"))
				false
			end

			def ensure_asana_token_valid
				# Check if token is valid
				if current_user.asana_token_valid?
					return true
				end

				# Token expired, try to refresh
				Rails.logger.info "Token expired, attempting refresh for user #{current_user.id}"
				AsanaService.refresh_token(current_user)
				current_user.reload
				
				# Check again after refresh
				current_user.asana_token_valid?
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