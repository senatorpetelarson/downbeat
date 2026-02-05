class AddUserIdToAsanaWorkspaces < ActiveRecord::Migration[7.1]
  def change
    add_column :asana_workspaces, :user_id, :bigint, null: false
    add_index :asana_workspaces, :user_id
    add_foreign_key :asana_workspaces, :users
  end
end