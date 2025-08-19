class CreateBillingTiers < ActiveRecord::Migration[8.0]
  def change
    create_table :billing_tiers do |t|
      t.string :name, null: false
      t.decimal :monthly_price, precision: 10, scale: 2, default: 0, null: false
      t.decimal :per_user_price, precision: 10, scale: 2, default: 0, null: false
      t.integer :user_limit
      t.jsonb :features, default: [], null: false
      t.references :tenant, null: false, foreign_key: true

      t.timestamps
    end

    add_index :billing_tiers, [:tenant_id, :name], unique: true
    add_index :billing_tiers, :features, using: :gin
  end
end
