class DropActiveStorageTables < ActiveRecord::Migration[7.1]
  def change
    drop_table :active_storage_tables if table_exists?(:active_storage_tables)
  end
end