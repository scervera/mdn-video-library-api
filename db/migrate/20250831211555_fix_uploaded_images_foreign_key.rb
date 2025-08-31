class FixUploadedImagesForeignKey < ActiveRecord::Migration[8.0]
  def up
    # Remove the existing foreign key constraint
    remove_foreign_key :uploaded_images, :lesson_modules
    
    # Add the foreign key constraint with cascade delete
    add_foreign_key :uploaded_images, :lesson_modules, on_delete: :cascade
  end

  def down
    # Remove the cascade foreign key constraint
    remove_foreign_key :uploaded_images, :lesson_modules
    
    # Add back the original foreign key constraint (restrict)
    add_foreign_key :uploaded_images, :lesson_modules
  end
end
