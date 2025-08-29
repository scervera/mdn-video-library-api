# Active Storage Module Architecture

## Overview

This document explains the architecture for handling file attachments in lesson modules using Active Storage. The design ensures that attachments are properly managed and automatically cleaned up when modules are destroyed, preventing orphaned files.

## Architecture Principles

### 1. **Module-Owned Attachments**
- ✅ Attachments belong to **modules**, not lessons
- ✅ When a module is destroyed, its attachments are automatically destroyed
- ✅ No orphaned files when modules are deleted
- ✅ Clean separation of concerns

### 2. **Rich Metadata Support**
- ✅ File metadata stored in module's `settings` JSON field
- ✅ Active Storage handles file storage and retrieval
- ✅ Flexible metadata structure for different module types

## Database Schema

### Active Storage Tables
```sql
-- Active Storage Attachments
active_storage_attachments
├── record_type: "ResourcesModule" or "ImageModule"
├── record_id: Module ID
├── name: "files" or "images"
└── blob_id: Reference to actual file

-- Active Storage Blobs
active_storage_blobs
├── key: Unique file identifier
├── filename: Original filename
├── content_type: MIME type
├── byte_size: File size
└── checksum: File integrity check
```

### Module Tables
```sql
-- Lesson Modules
lesson_modules
├── id: Primary key
├── lesson_id: Parent lesson
├── type: "ResourcesModule" or "ImageModule"
├── settings: JSON field for metadata
└── position: Display order
```

## Module Types

### ResourcesModule
```ruby
class ResourcesModule < LessonModule
  has_many_attached :files
  
  # Metadata stored in settings['resources']
  # Each resource can be: file, link, or video
end
```

### ImageModule
```ruby
class ImageModule < LessonModule
  has_many_attached :images
  
  # Metadata stored in settings['images']
  # Supports: single, gallery, carousel, grid layouts
end
```

## Key Methods

### Adding Files with Metadata
```ruby
# ResourcesModule
resources_module.add_file_with_metadata(
  file,
  title: 'Document Title',
  description: 'File description',
  alt_text: 'Accessibility text'
)

# ImageModule
image_module.add_image_with_metadata(
  image,
  title: 'Image Title',
  alt_text: 'Accessibility text',
  description: 'Image description'
)
```

### Retrieving Files with Metadata
```ruby
# Get files with full metadata
resources_module.attached_files_with_metadata
# Returns: [{ attachment:, metadata:, filename:, url:, title:, ... }]

# Get images with full metadata
image_module.attached_images_with_metadata
# Returns: [{ attachment:, metadata:, filename:, url:, title:, alt_text:, ... }]
```

### Removing Files
```ruby
# Remove file and metadata by index
resources_module.remove_file_with_metadata(0)
image_module.remove_image_with_metadata(0)
```

## Automatic Cleanup

### When Module is Destroyed
1. **Active Storage automatically destroys attachments**
2. **Files are removed from S3 storage**
3. **Database records are cleaned up**
4. **No orphaned data remains**

### Callback Chain
```ruby
# In ResourcesModule and ImageModule
after_destroy :cleanup_orphaned_metadata

# Active Storage handles the rest automatically
```

## Benefits of This Architecture

### 1. **No Orphaned Files**
- Files are automatically deleted when modules are destroyed
- No storage waste or security concerns
- Clean database state

### 2. **Rich Metadata Support**
- Store titles, descriptions, alt text, etc.
- Flexible JSON structure
- Easy to extend with new metadata fields

### 3. **Type Safety**
- Each module type has specific attachment types
- ResourcesModule: `files`
- ImageModule: `images`
- Clear separation of concerns

### 4. **Performance**
- Lazy loading of attachments
- Efficient queries with proper indexing
- Minimal database overhead

### 5. **Scalability**
- Works with any S3-compatible storage
- Supports large files and many attachments
- Easy to add new module types

## Testing the Architecture

Run the test script to verify the architecture:

```bash
ruby test_active_storage_modules.rb
```

This script demonstrates:
- ✅ Creating modules with attachments
- ✅ Adding metadata
- ✅ Retrieving files with metadata
- ✅ Automatic cleanup on deletion
- ✅ Verification of no orphaned data

## API Integration

### Creating Modules with Files
```ruby
# POST /api/v1/lessons/:lesson_id/modules
{
  "module": {
    "type": "ResourcesModule",
    "title": "Course Materials",
    "position": 1,
    "files": [
      {
        "file": <file_data>,
        "title": "Course Syllabus",
        "description": "Complete course outline"
      }
    ]
  }
}
```

### Retrieving Modules with Files
```ruby
# GET /api/v1/lessons/:lesson_id/modules
{
  "modules": [
    {
      "id": 1,
      "type": "ResourcesModule",
      "title": "Course Materials",
      "files": [
        {
          "id": 123,
          "filename": "syllabus.pdf",
          "url": "https://...",
          "title": "Course Syllabus",
          "description": "Complete course outline",
          "byte_size": 1024000
        }
      ]
    }
  ]
}
```

## Best Practices

### 1. **Always Use Metadata Methods**
```ruby
# ✅ Good
module.add_file_with_metadata(file, title: 'Document')

# ❌ Avoid
module.files.attach(file)
# (This doesn't add metadata)
```

### 2. **Validate File Types**
```ruby
# In your controllers
def validate_file_type(file)
  allowed_types = ['application/pdf', 'image/jpeg', 'image/png']
  allowed_types.include?(file.content_type)
end
```

### 3. **Handle File Size Limits**
```ruby
# In your models
validates :files, attached: true, content_type: ['application/pdf'], size: { less_than: 10.megabytes }
```

### 4. **Use Proper Error Handling**
```ruby
begin
  module.add_file_with_metadata(file, metadata)
rescue ActiveStorage::FileNotFoundError
  # Handle missing file
rescue ActiveRecord::RecordInvalid
  # Handle validation errors
end
```

## Migration Guide

### From Lesson-Based Attachments
If you're migrating from a lesson-based attachment system:

1. **Create new modules** for existing attachments
2. **Move attachments** to appropriate modules
3. **Update metadata** in module settings
4. **Remove old attachment associations**
5. **Test cleanup** functionality

### Example Migration
```ruby
# Migrate lesson files to ResourcesModule
lesson.files.each_with_index do |file, index|
  module = lesson.lesson_modules.create!(
    type: 'ResourcesModule',
    title: "Resource #{index + 1}",
    position: index + 1
  )
  
  module.files.attach(file)
  # Add metadata as needed
end
```

## Troubleshooting

### Common Issues

1. **Files not being deleted**
   - Check if module is being destroyed properly
   - Verify Active Storage configuration
   - Check S3 permissions

2. **Metadata not syncing**
   - Use `add_file_with_metadata` method
   - Check JSON field structure
   - Verify settings are being saved

3. **Performance issues**
   - Add proper database indexes
   - Use eager loading for attachments
   - Consider pagination for large file lists

### Debugging Commands
```ruby
# Check attachment counts
ActiveStorage::Attachment.count
ActiveStorage::Blob.count

# Find orphaned attachments
ActiveStorage::Attachment.where(record_type: 'ResourcesModule')

# Check module settings
ResourcesModule.first.settings
```

## Conclusion

This architecture provides a robust, scalable solution for file management in lesson modules. It ensures data integrity, prevents orphaned files, and supports rich metadata while maintaining clean separation of concerns.
