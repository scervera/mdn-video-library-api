class AddEnhancedFieldsToBookmarks < ActiveRecord::Migration[8.0]
  def change
    add_column :bookmarks, :in_sec, :integer
    add_column :bookmarks, :out_sec, :integer
    add_column :bookmarks, :type, :string, default: 'bookmark'
    add_column :bookmarks, :privacy_level, :string, default: 'private'
    add_column :bookmarks, :shared_with, :jsonb, default: []
    add_column :bookmarks, :group_id, :string
    
    # Add indexes for performance
    add_index :bookmarks, :type
    add_index :bookmarks, :privacy_level
    add_index :bookmarks, [:lesson_id, :type]
    add_index :bookmarks, [:user_id, :privacy_level]
    add_index :bookmarks, :shared_with, using: :gin
  end
end
