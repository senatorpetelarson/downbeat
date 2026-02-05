class AddFieldsToAsanaWorkspaces < ActiveRecord::Migration[7.1]
  def change
    add_column :asana_workspaces, :workspace_gid, :string, null: false
    add_column :asana_workspaces, :name, :string, null: false
    
    add_index :asana_workspaces, [:user_id, :workspace_gid], unique: true
  end
end