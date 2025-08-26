class AddVideoFieldsToLessonModules < ActiveRecord::Migration[8.0]
  def change
    add_column :lesson_modules, :cloudflare_stream_id, :string
    add_column :lesson_modules, :cloudflare_stream_thumbnail, :string
    add_column :lesson_modules, :cloudflare_stream_duration, :integer
    add_column :lesson_modules, :cloudflare_stream_status, :string, default: 'ready'
    add_column :lesson_modules, :content, :text
    
    # Add indexes for video-specific fields
    add_index :lesson_modules, :cloudflare_stream_id
    add_index :lesson_modules, :cloudflare_stream_status
  end
end
