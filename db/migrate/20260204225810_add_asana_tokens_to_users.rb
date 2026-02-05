class AddAsanaTokensToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :asana_access_token, :text
    add_column :users, :asana_refresh_token, :text
    add_column :users, :asana_token_expires_at, :datetime
  end
end
