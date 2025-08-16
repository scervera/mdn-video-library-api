class AddCloudflareStreamToLessons < ActiveRecord::Migration[8.0]
  def change
    add_column :lessons, :cloudflare_stream_id, :string
    add_column :lessons, :cloudflare_stream_thumbnail, :string
    add_column :lessons, :cloudflare_stream_duration, :integer
    add_column :lessons, :cloudflare_stream_status, :string, default: 'ready'
    
    # Add index for faster lookups
    add_index :lessons, :cloudflare_stream_id
    
    # Add index for content type filtering
    add_index :lessons, :content_type
  end
end
