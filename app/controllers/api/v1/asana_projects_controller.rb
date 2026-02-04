module Api
  module V1
    class AsanaProjectsController < ApplicationController
      def index
        workspace_id = params[:workspace_id]
        
        @projects = if workspace_id
          AsanaProject.joins(:asana_workspace)
                     .where(asana_workspaces: { user_id: current_user.id, id: workspace_id })
        else
          AsanaProject.joins(:asana_workspace)
                     .where(asana_workspaces: { user_id: current_user.id })
        end

        @projects = @projects.includes(:client)
        
        render json: @projects.map { |proj| project_json(proj) }
      end

      def update
        @project = current_user.asana_workspaces.joins(:asana_projects)
                              .find_by(asana_projects: { id: params[:id] })
                              .asana_projects.find(params[:id])
        
        if @project.update(project_params)
          render json: project_json(@project)
        else
          render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def map_to_client
        @project = AsanaProject.joins(:asana_workspace)
                              .where(asana_workspaces: { user_id: current_user.id })
                              .find(params[:id])
        
        client_id = params[:client_id].presence
        
        if @project.update(client_id: client_id)
          render json: project_json(@project)
        else
          render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def project_params
        params.require(:asana_project).permit(:client_id)
      end

      def project_json(project)
        {
          id: project.id,
          project_gid: project.project_gid,
          name: project.name,
          workspace_id: project.asana_workspace_id,
          client: project.client ? {
            id: project.client.id,
            name: project.client.name
          } : nil,
          created_at: project.created_at
        }
      end
    end
  end
end
