class MakeTimestampNullableInBookmarks < ActiveRecord::Migration[8.0]
  def change
    change_column_null :bookmarks, :timestamp, true
  end
end
