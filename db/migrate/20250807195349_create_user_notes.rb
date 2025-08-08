class CreateUserNotes < ActiveRecord::Migration[7.1]
  def change
    create_table :user_notes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :chapter, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
