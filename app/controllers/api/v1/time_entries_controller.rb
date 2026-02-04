module Api
  module V1
    class TimeEntriesController < ApplicationController
      before_action :set_time_entry, only: [:show, :update, :destroy, :forgot_stop]

      def index
        @entries = current_user.time_entries
                              .includes(:client, :asana_project, :asana_task)
                              .order(started_at: :desc)
        
        # Optional filtering
        @entries = @entries.where(client_id: params[:client_id]) if params[:client_id]
        @entries = @entries.where('started_at >= ?', params[:start_date]) if params[:start_date]
        @entries = @entries.where('started_at <= ?', params[:end_date]) if params[:end_date]
        
        render json: @entries.map { |entry| time_entry_json(entry) }
      end

      def show
        render json: time_entry_json(@time_entry)
      end

      def active
        @entry = current_user.time_entries.active.first
        
        if @entry
          render json: time_entry_json(@entry)
        else
          render json: { active: false }, status: :ok
        end
      end

      def create
        @time_entry = current_user.time_entries.build(time_entry_params)
        @time_entry.started_at ||= Time.current
        
        if @time_entry.save
          render json: time_entry_json(@time_entry), status: :created
        else
          render json: { errors: @time_entry.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @time_entry.update(time_entry_params)
          render json: time_entry_json(@time_entry)
        else
          render json: { errors: @time_entry.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def forgot_stop
        stop_time = params[:stopped_at] || Time.current
        
        if @time_entry.update(stopped_at: stop_time)
          render json: time_entry_json(@time_entry)
        else
          render json: { errors: @time_entry.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @time_entry.destroy
        head :no_content
      end

      def sync_to_asana
        @time_entry = current_user.time_entries.find(params[:id])
        
        AsanaService.post_time_entry_to_task(@time_entry)
        
        render json: time_entry_json(@time_entry.reload)
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def set_time_entry
        @time_entry = current_user.time_entries.find(params[:id])
      end

      def time_entry_params
        params.require(:time_entry).permit(
          :client_id,
          :asana_project_id,
          :asana_task_id,
          :started_at,
          :stopped_at,
          :notes
        )
      end

      def time_entry_json(entry)
        {
          id: entry.id,
          client: {
            id: entry.client.id,
            name: entry.client.name,
            color: entry.client.color
          },
          asana_project: entry.asana_project ? {
            id: entry.asana_project.id,
            name: entry.asana_project.name
          } : nil,
          asana_task: entry.asana_task ? {
            id: entry.asana_task.id,
            name: entry.asana_task.name
          } : nil,
          started_at: entry.started_at,
          stopped_at: entry.stopped_at,
          duration_seconds: entry.duration_seconds,
          duration_hours: entry.duration_in_hours.round(2),
          notes: entry.notes,
          running: entry.running?,
          synced_to_asana: entry.synced_to_asana,
          created_at: entry.created_at,
          updated_at: entry.updated_at
        }
      end
    end
  end
end