class AddRoleToUserInvitations < ActiveRecord::Migration[8.0]
  def change
    add_column :user_invitations, :role, :string
  end
end
