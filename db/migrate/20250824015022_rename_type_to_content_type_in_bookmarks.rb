class RenameTypeToContentTypeInBookmarks < ActiveRecord::Migration[8.0]
  def change
    rename_column :bookmarks, :type, :content_type
    
    # Update the indexes to use the new column name
    if index_exists?(:bookmarks, :type)
      remove_index :bookmarks, :type
      add_index :bookmarks, :content_type
    end
    
    if index_exists?(:bookmarks, [:lesson_id, :type])
      remove_index :bookmarks, [:lesson_id, :type]
      add_index :bookmarks, [:lesson_id, :content_type]
    end
  end
end
