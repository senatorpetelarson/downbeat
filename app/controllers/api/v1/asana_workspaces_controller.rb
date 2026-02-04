module Api
  module V1
    class AsanaWorkspacesController < ApplicationController
      def index
        @workspaces = current_user.asana_workspaces.includes(:asana_projects)
        render json: @workspaces.map { |ws| workspace_json(ws) }
      end

      def create
        # This syncs workspaces from Asana
        unless current_user.asana_token_valid?
          return render json: { error: 'Asana token invalid or expired' }, status: :unauthorized
        end

        client = Asana::Client.new do |c|
          c.authentication :oauth2, bearer_token: current_user.asana_access_token
        end

        workspaces = client.workspaces.find_all

        workspaces.each do |ws|
          current_user.asana_workspaces.find_or_create_by(workspace_gid: ws.gid) do |workspace|
            workspace.name = ws.name
          end
        end

        @workspaces = current_user.asana_workspaces.reload
        render json: @workspaces.map { |ws| workspace_json(ws) }
      rescue StandardError => e
        render json: { error: e.message }, status: :bad_request
      end

      def sync_projects
        @workspace = current_user.asana_workspaces.find(params[:id])
        
        unless current_user.asana_token_valid?
          return render json: { error: 'Asana token invalid or expired' }, status: :unauthorized
        end

        client = Asana::Client.new do |c|
          c.authentication :oauth2, bearer_token: current_user.asana_access_token
        end

        projects = client.projects.find_by_workspace(workspace: @workspace.workspace_gid)

        projects.each do |proj|
          @workspace.asana_projects.find_or_create_by(project_gid: proj.gid) do |project|
            project.name = proj.name
          end
        end

        render json: workspace_json(@workspace.reload)
      rescue StandardError => e
        render json: { error: e.message }, status: :bad_request
      end

      private

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
