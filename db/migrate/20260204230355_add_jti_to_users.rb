class AddJtiToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :jti, :string
    
    # Generate JTI for existing users
    User.find_each do |user|
      user.update_column(:jti, SecureRandom.uuid)
    end
    
    # Now add the null constraint
    change_column_null :users, :jti, false
    add_index :users, :jti, unique: true
  end
end