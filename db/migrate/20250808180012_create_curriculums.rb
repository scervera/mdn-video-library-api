class CreateCurriculums < ActiveRecord::Migration[7.1]
  def change
    create_table :curriculums do |t|
      t.string :title
      t.text :description
      t.boolean :published
      t.integer :order_index

      t.timestamps
    end
  end
end
