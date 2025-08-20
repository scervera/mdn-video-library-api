class AddFieldsToStripeConnectAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :stripe_connect_accounts, :requirements, :json
    add_column :stripe_connect_accounts, :capabilities, :json
    add_column :stripe_connect_accounts, :business_type, :string
    add_column :stripe_connect_accounts, :country, :string
  end
end
