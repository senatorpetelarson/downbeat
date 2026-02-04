class CreateAsanaTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :asana_tasks do |t|

      t.timestamps
    end
  end
end
