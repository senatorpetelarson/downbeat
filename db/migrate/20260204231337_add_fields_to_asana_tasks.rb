class AddFieldsToAsanaTasks < ActiveRecord::Migration[7.1]
  def change
    add_column :asana_tasks, :asana_project_id, :bigint, null: false
    add_column :asana_tasks, :task_gid, :string, null: false
    add_column :asana_tasks, :name, :string, null: false
    
    add_index :asana_tasks, :asana_project_id
    add_index :asana_tasks, :task_gid, unique: true
    add_foreign_key :asana_tasks, :asana_projects
  end
end