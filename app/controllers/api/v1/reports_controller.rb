module Api
  module V1
    class ReportsController < ApplicationController
      def monthly
        year = params[:year]&.to_i || Time.current.year
        month = params[:month]&.to_i || Time.current.month
        client_id = params[:client_id]

        if client_id
          @client = current_user.clients.find(client_id)
          render json: client_monthly_report(@client, year, month)
        else
          render json: all_clients_monthly_report(year, month)
        end
      end

      private

      def client_monthly_report(client, year, month)
        entries = client.time_entries.for_month(year, month).includes(:asana_project, :asana_task)
        
        total_seconds = entries.sum(:duration_seconds)
        
        by_project = entries.group_by(&:asana_project).map do |project, project_entries|
          {
            project: project ? { id: project.id, name: project.name } : { name: 'Unspecified' },
            total_hours: (project_entries.sum(&:duration_seconds) / 3600.0).round(2),
            entries: project_entries.map { |e| entry_summary(e) }
          }
        end

        {
          client: {
            id: client.id,
            name: client.name,
            color: client.color
          },
          month: "#{Date::MONTHNAMES[month]} #{year}",
          total_hours: (total_seconds / 3600.0).round(2),
          hourly_rate: client.hourly_rate,
          total_amount: client.hourly_rate ? (total_seconds / 3600.0 * client.hourly_rate).round(2) : nil,
          by_project: by_project
        }
      end

      def all_clients_monthly_report(year, month)
        entries = current_user.time_entries.for_month(year, month).includes(:client)
        
        by_client = entries.group_by(&:client).map do |client, client_entries|
          total_seconds = client_entries.sum(&:duration_seconds)
          total_hours = (total_seconds / 3600.0).round(2)
          
          {
            client: {
              id: client.id,
              name: client.name,
              color: client.color
            },
            total_hours: total_hours,
            total_amount: client.hourly_rate ? (total_hours * client.hourly_rate).round(2) : nil
          }
        end.sort_by { |r| -r[:total_hours] }

        {
          month: "#{Date::MONTHNAMES[month]} #{year}",
          total_hours: (entries.sum(:duration_seconds) / 3600.0).round(2),
          by_client: by_client
        }
      end

      def entry_summary(entry)
        {
          id: entry.id,
          started_at: entry.started_at,
          duration_hours: entry.duration_in_hours.round(2),
          task: entry.asana_task ? entry.asana_task.name : nil,
          notes: entry.notes
        }
      end
    end
  end
end
