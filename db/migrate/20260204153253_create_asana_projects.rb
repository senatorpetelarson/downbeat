class CreateAsanaProjects < ActiveRecord::Migration[7.1]
  def change
    create_table :asana_projects do |t|

      t.timestamps
    end
  end
end
