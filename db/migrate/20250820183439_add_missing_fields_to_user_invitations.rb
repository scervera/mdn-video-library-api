class AddMissingFieldsToUserInvitations < ActiveRecord::Migration[8.0]
  def change
    add_column :user_invitations, :status, :string, default: 'pending', null: false
    add_column :user_invitations, :resent_count, :integer, default: 0, null: false
    add_column :user_invitations, :resent_at, :datetime
    add_column :user_invitations, :cancelled_at, :datetime
    add_column :user_invitations, :message, :text
    
    add_index :user_invitations, :status
    add_index :user_invitations, :resent_at
    add_index :user_invitations, :cancelled_at
  end
end
