class AddFieldsToClients < ActiveRecord::Migration[7.1]
  def change
    add_column :clients, :user_id, :bigint, null: false
    add_column :clients, :name, :string, null: false
    add_column :clients, :color, :string
    add_column :clients, :hourly_rate, :decimal, precision: 10, scale: 2
    add_column :clients, :active, :boolean, default: true, null: false
    
    add_index :clients, :user_id
    add_foreign_key :clients, :users
  end
end
