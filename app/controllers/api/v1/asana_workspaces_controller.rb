module Api
	module V1
		class AsanaWorkspacesController < ApplicationController
			def index
				@workspaces = current_user.asana_workspaces.includes(:asana_projects)
				render json: @workspaces.map { |ws| workspace_json(ws) }
			end

			def create
				# This syncs workspaces from Asana
				unless ensure_asana_token_valid
					return render json: { 
						error: 'Asana token invalid or expired. Please reconnect.' 
					}, status: :unauthorized
				end

				client = Asana::Client.new do |c|
					c.authentication :oauth2, bearer_token: current_user.asana_access_token
				end

				workspaces = client.workspaces.find_all

				synced_workspaces = []
				workspaces.each do |ws|
					workspace = current_user.asana_workspaces.find_or_create_by(workspace_gid: ws.gid) do |w|
						w.name = ws.name
					end
					workspace.update(name: ws.name) if workspace.persisted?
					synced_workspaces << workspace
				end

				render json: synced_workspaces.map { |ws| workspace_json(ws) }
			rescue StandardError => e
				Rails.logger.error "Asana sync error: #{e.class} - #{e.message}"
				Rails.logger.error e.backtrace.join("\n")
				render json: { error: e.message, type: e.class.to_s }, status: :bad_request
			end

			def sync_projects
				@workspace = current_user.asana_workspaces.find(params[:id])
				
				unless ensure_asana_token_valid
					return render json: { 
						error: 'Asana token invalid or expired. Please reconnect.' 
					}, status: :unauthorized
				end

				client = Asana::Client.new do |c|
					c.authentication :oauth2, bearer_token: current_user.asana_access_token
				end

				projects = client.projects.find_by_workspace(workspace: @workspace.workspace_gid, archived: false)

				projects.each do |proj|
					project = @workspace.asana_projects.find_or_create_by(project_gid: proj.gid) do |p|
						p.name = proj.name
					end
					project.update(name: proj.name) if project.persisted?
				end

				render json: workspace_json(@workspace.reload)
			rescue StandardError => e
				Rails.logger.error "Project sync error: #{e.message}"
				render json: { error: e.message }, status: :bad_request
			end

			private

			def ensure_asana_token_valid
				return true if current_user.asana_token_valid?

				Rails.logger.info "Token expired, attempting refresh"
				AsanaService.refresh_token(current_user)
				current_user.reload
				
				current_user.asana_token_valid?
			end

			def workspace_json(workspace)
				{
					id: workspace.id,
					workspace_gid: workspace.workspace_gid,
					name: workspace.name,
					projects_count: workspace.asana_projects.count,
					created_at: workspace.created_at
				}
			end
		end
	end
end