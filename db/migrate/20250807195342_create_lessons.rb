class CreateLessons < ActiveRecord::Migration[7.1]
  def change
    create_table :lessons do |t|
      t.references :chapter, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :content_type
      t.text :content
      t.string :media_url
      t.integer :order_index
      t.boolean :published

      t.timestamps
    end
  end
end
