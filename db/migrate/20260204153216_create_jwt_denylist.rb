class CreateJwtDenylist < ActiveRecord::Migration[7.1]
  def change
    create_table :jwt_denylists do |t|

      t.timestamps
    end
  end
end
