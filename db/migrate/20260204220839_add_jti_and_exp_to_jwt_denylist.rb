class AddJtiAndExpToJwtDenylist < ActiveRecord::Migration[7.1]
  def change
    add_column :jwt_denylist, :jti, :string, null: false
    add_column :jwt_denylist, :exp, :datetime, null: false
    add_index :jwt_denylist, :jti
  end
end
