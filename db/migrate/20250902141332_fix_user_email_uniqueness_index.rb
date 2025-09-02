class FixUserEmailUniquenessIndex < ActiveRecord::Migration[8.0]
  def up
    # Remove the global email uniqueness index
    remove_index :users, :email
    
    # Add composite indexes for tenant-scoped uniqueness
    add_index :users, [:email, :tenant_id], unique: true
    add_index :users, [:username, :tenant_id], unique: true
  end

  def down
    # Remove the composite indexes
    remove_index :users, [:email, :tenant_id]
    remove_index :users, [:username, :tenant_id]
    
    # Add back the global email uniqueness index
    add_index :users, :email, unique: true
  end
end
