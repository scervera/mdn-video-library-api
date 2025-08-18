class AddTenantToAllTables < ActiveRecord::Migration[8.0]
  def up
    # Create a default tenant for existing data (temporarily disable validations)
    default_tenant = Tenant.new(
      name: 'Default Organization',
      subdomain: 'default',
      domain: 'curriculum-library-api.cerveras.com'
    )
    default_tenant.save!(validate: false)

    # Add tenant_id columns without NOT NULL constraint first
    add_reference :users, :tenant, foreign_key: true
    add_reference :curriculums, :tenant, foreign_key: true
    add_reference :chapters, :tenant, foreign_key: true
    add_reference :lessons, :tenant, foreign_key: true
    add_reference :bookmarks, :tenant, foreign_key: true
    add_reference :user_progresses, :tenant, foreign_key: true
    add_reference :lesson_progresses, :tenant, foreign_key: true
    add_reference :user_notes, :tenant, foreign_key: true
    add_reference :user_highlights, :tenant, foreign_key: true

    # Update all existing records to use the default tenant
    User.update_all(tenant_id: default_tenant.id)
    Curriculum.update_all(tenant_id: default_tenant.id)
    Chapter.update_all(tenant_id: default_tenant.id)
    Lesson.update_all(tenant_id: default_tenant.id)
    Bookmark.update_all(tenant_id: default_tenant.id)
    UserProgress.update_all(tenant_id: default_tenant.id)
    LessonProgress.update_all(tenant_id: default_tenant.id)
    UserNote.update_all(tenant_id: default_tenant.id)
    UserHighlight.update_all(tenant_id: default_tenant.id)

    # Now add NOT NULL constraints
    change_column_null :users, :tenant_id, false
    change_column_null :curriculums, :tenant_id, false
    change_column_null :chapters, :tenant_id, false
    change_column_null :lessons, :tenant_id, false
    change_column_null :bookmarks, :tenant_id, false
    change_column_null :user_progresses, :tenant_id, false
    change_column_null :lesson_progresses, :tenant_id, false
    change_column_null :user_notes, :tenant_id, false
    change_column_null :user_highlights, :tenant_id, false
  end

  def down
    remove_reference :users, :tenant
    remove_reference :curriculums, :tenant
    remove_reference :chapters, :tenant
    remove_reference :lessons, :tenant
    remove_reference :bookmarks, :tenant
    remove_reference :user_progresses, :tenant
    remove_reference :lesson_progresses, :tenant
    remove_reference :user_notes, :tenant
    remove_reference :user_highlights, :tenant
  end
end
