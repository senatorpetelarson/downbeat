class AddFieldsToTimeEntries < ActiveRecord::Migration[7.1]
  def change
    add_column :time_entries, :user_id, :bigint, null: false
    add_column :time_entries, :client_id, :bigint, null: false
    add_column :time_entries, :asana_project_id, :bigint
    add_column :time_entries, :asana_task_id, :bigint
    add_column :time_entries, :started_at, :datetime, null: false
    add_column :time_entries, :stopped_at, :datetime
    add_column :time_entries, :duration_seconds, :integer
    add_column :time_entries, :notes, :text
    add_column :time_entries, :synced_to_asana, :boolean, default: false
    add_column :time_entries, :asana_story_gid, :string
    
    add_index :time_entries, :user_id
    add_index :time_entries, :client_id
    add_index :time_entries, :asana_project_id
    add_index :time_entries, :asana_task_id
    add_foreign_key :time_entries, :users
    add_foreign_key :time_entries, :clients
  end
end