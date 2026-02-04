class CreateAsanaWorkspaces < ActiveRecord::Migration[7.1]
  def change
    create_table :asana_workspaces do |t|

      t.timestamps
    end
  end
end
