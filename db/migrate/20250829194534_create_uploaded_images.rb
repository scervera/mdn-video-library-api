class CreateUploadedImages < ActiveRecord::Migration[8.0]
  def change
    create_table :uploaded_images do |t|
      t.references :user, null: false, foreign_key: true
      t.references :lesson, null: true, foreign_key: true
      t.references :lesson_module, null: true, foreign_key: true

      t.timestamps
    end
  end
end
