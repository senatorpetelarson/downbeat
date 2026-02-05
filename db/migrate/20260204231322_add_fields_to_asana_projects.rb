class AddFieldsToAsanaProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :asana_projects, :asana_workspace_id, :bigint, null: false
    add_column :asana_projects, :project_gid, :string, null: false
    add_column :asana_projects, :name, :string, null: false
    
    add_index :asana_projects, :asana_workspace_id
    add_index :asana_projects, :project_gid, unique: true
    add_foreign_key :asana_projects, :asana_workspaces
  end
end