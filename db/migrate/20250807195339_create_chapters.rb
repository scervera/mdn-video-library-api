class CreateChapters < ActiveRecord::Migration[7.1]
  def change
    create_table :chapters do |t|
      t.string :title
      t.text :description
      t.string :duration
      t.integer :order_index
      t.boolean :published

      t.timestamps
    end
  end
end
