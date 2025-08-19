class CreateUserInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :user_invitations do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      t.string :email, null: false
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.datetime :used_at

      t.timestamps
    end

    add_index :user_invitations, :token, unique: true
    add_index :user_invitations, :email
    add_index :user_invitations, :expires_at
    add_index :user_invitations, :used_at
  end
end
