module Api
  module V1
    class ClientsController < ApplicationController
      before_action :set_client, only: [:show, :update, :destroy, :remove_logo]

      def index
        @clients = current_user.clients.includes(logo_attachment: :blob)
        render json: @clients.map { |client| client_json(client) }
      end

      def show
        render json: client_json(@client)
      end

      def create
        @client = current_user.clients.build(client_params)
        
        if @client.save
          render json: client_json(@client), status: :created
        else
          render json: { errors: @client.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @client.update(client_params)
          render json: client_json(@client)
        else
          render json: { errors: @client.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @client.destroy
        head :no_content
      end

      def remove_logo
        @client.logo.purge if @client.logo.attached?
        render json: client_json(@client)
      end

      private

      def set_client
        @client = current_user.clients.find(params[:id])
      end

      def client_params
        params.require(:client).permit(:name, :color, :hourly_rate, :active, :logo)
      end

      def client_json(client)
        {
          id: client.id,
          name: client.name,
          color: client.color,
          hourly_rate: client.hourly_rate,
          active: client.active,
          logo_url: client.logo.attached? ? url_for(client.logo) : nil,
          created_at: client.created_at,
          updated_at: client.updated_at
        }
      end
    end
  end
end