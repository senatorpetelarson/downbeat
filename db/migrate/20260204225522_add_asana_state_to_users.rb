class AddAsanaStateToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :asana_oauth_state, :string
  end
end
