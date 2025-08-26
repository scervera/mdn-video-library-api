class CreateLessonModules < ActiveRecord::Migration[8.0]
  def change
    create_table :lesson_modules do |t|
      t.references :lesson, null: false, foreign_key: { on_delete: :cascade }
      t.string :type, null: false
      t.string :title, null: false
      t.text :description
      t.integer :position, null: false
      t.jsonb :settings, default: {}
      t.datetime :published_at

      t.timestamps
    end

    # Add indexes for performance
    add_index :lesson_modules, :type
    add_index :lesson_modules, :published_at
    add_index :lesson_modules, [:lesson_id, :type]
    
    # Add unique constraint for position within lesson
    add_index :lesson_modules, [:lesson_id, :position], unique: true
  end
end
