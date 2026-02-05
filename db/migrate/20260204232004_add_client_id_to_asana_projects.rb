class AddClientIdToAsanaProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :asana_projects, :client_id, :bigint
    add_index :asana_projects, :client_id
    add_foreign_key :asana_projects, :clients
  end
end