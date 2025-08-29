# Active Storage Frontend Integration Prompt

## Overview

You need to implement frontend integration for the new Active Storage file upload functionality in lesson modules. The backend has been enhanced with file upload capabilities for ResourcesModule and ImageModule types.

## Backend Changes Summary

### ✅ Completed Backend Features

1. **Active Storage Integration**
   - ResourcesModule: `has_many_attached :files`
   - ImageModule: `has_many_attached :images`
   - Automatic cleanup when modules are destroyed
   - Rich metadata support in module settings

2. **Enhanced API Endpoints**
   - `POST /api/v1/lessons/:lesson_id/lesson_modules/:id/upload_file`
   - `DELETE /api/v1/lessons/:lesson_id/lesson_modules/:id/remove_file`

3. **File Validation**
   - ResourcesModule: 50MB max, PDF, Office docs, text files, ZIP
   - ImageModule: 10MB max, JPEG, PNG, GIF, WebP, SVG
   - Content type validation
   - File size validation

4. **Enhanced Response Data**
   - Files now include full metadata (title, description, alt_text, etc.)
   - File URLs, sizes, and content types
   - Rich attachment data with metadata

## Frontend Implementation Requirements

### 1. **File Upload Components**

Create reusable file upload components:

```typescript
// FileUploader.tsx
interface FileUploaderProps {
  moduleId: number;
  lessonId: number;
  moduleType: 'ResourcesModule' | 'ImageModule';
  onUploadSuccess: (fileData: FileData) => void;
  onUploadError: (error: string) => void;
  maxFileSize?: number;
  allowedTypes?: string[];
  multiple?: boolean;
}

interface FileData {
  attachment: {
    id: number;
    filename: string;
    content_type: string;
    byte_size: number;
    url: string;
  };
  metadata: {
    title: string;
    description?: string;
    alt_text?: string;
  };
  filename: string;
  content_type: string;
  byte_size: number;
  url: string;
  title: string;
  description?: string;
  alt_text?: string;
}
```

### 2. **File Management Components**

Create components for displaying and managing uploaded files:

```typescript
// FileList.tsx
interface FileListProps {
  files: FileData[];
  onRemove: (index: number) => void;
  onEdit: (index: number, metadata: Partial<FileData>) => void;
  moduleType: 'ResourcesModule' | 'ImageModule';
}

// FilePreview.tsx
interface FilePreviewProps {
  file: FileData;
  moduleType: 'ResourcesModule' | 'ImageModule';
  onRemove?: () => void;
  onEdit?: (metadata: Partial<FileData>) => void;
}
```

### 3. **API Integration**

Extend the existing lesson modules API service:

```typescript
// api/lessonModules.ts
export const lessonModulesApi = {
  // ... existing methods ...
  
  uploadFile: async (
    lessonId: number, 
    moduleId: number, 
    file: File, 
    metadata: {
      title?: string;
      description?: string;
      alt_text?: string;
    } = {}
  ): Promise<LessonModule> => {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('metadata', JSON.stringify(metadata));
    
    const response = await fetch(`/api/v1/lessons/${lessonId}/lesson_modules/${moduleId}/upload_file`, {
      method: 'POST',
      headers: {
        'X-Tenant': getTenantSlug(),
        'Authorization': `Bearer ${getAuthToken()}`,
      },
      body: formData,
    });
    
    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || 'File upload failed');
    }
    
    return response.json();
  },
  
  removeFile: async (
    lessonId: number, 
    moduleId: number, 
    fileIndex: number
  ): Promise<LessonModule> => {
    const response = await fetch(`/api/v1/lessons/${lessonId}/lesson_modules/${moduleId}/remove_file`, {
      method: 'DELETE',
      headers: {
        'X-Tenant': getTenantSlug(),
        'Authorization': `Bearer ${getAuthToken()}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ file_index: fileIndex }),
    });
    
    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || 'File removal failed');
    }
    
    return response.json();
  },
};
```

### 4. **Module-Specific Components**

Update existing module components to support file uploads:

#### ResourcesModule Component
```typescript
// ResourcesModule.tsx
interface ResourcesModuleProps {
  module: LessonModule;
  lessonId: number;
  isEditing?: boolean;
}

const ResourcesModule: React.FC<ResourcesModuleProps> = ({ module, lessonId, isEditing }) => {
  const [files, setFiles] = useState<FileData[]>(module.resources || []);
  
  const handleFileUpload = async (file: File, metadata: any) => {
    try {
      const updatedModule = await lessonModulesApi.uploadFile(lessonId, module.id, file, metadata);
      setFiles(updatedModule.resources);
    } catch (error) {
      // Handle error
    }
  };
  
  const handleFileRemove = async (index: number) => {
    try {
      const updatedModule = await lessonModulesApi.removeFile(lessonId, module.id, index);
      setFiles(updatedModule.resources);
    } catch (error) {
      // Handle error
    }
  };
  
  return (
    <div className="resources-module">
      <h3>{module.title}</h3>
      <p>{module.description}</p>
      
      {isEditing && (
        <FileUploader
          moduleId={module.id}
          lessonId={lessonId}
          moduleType="ResourcesModule"
          onUploadSuccess={(fileData) => setFiles([...files, fileData])}
          onUploadError={(error) => console.error(error)}
          multiple={true}
        />
      )}
      
      <FileList
        files={files}
        onRemove={handleFileRemove}
        onEdit={(index, metadata) => {
          // Handle metadata editing
        }}
        moduleType="ResourcesModule"
      />
    </div>
  );
};
```

#### ImageModule Component
```typescript
// ImageModule.tsx
interface ImageModuleProps {
  module: LessonModule;
  lessonId: number;
  isEditing?: boolean;
}

const ImageModule: React.FC<ImageModuleProps> = ({ module, lessonId, isEditing }) => {
  const [images, setImages] = useState<FileData[]>(module.images || []);
  
  const handleImageUpload = async (file: File, metadata: any) => {
    try {
      const updatedModule = await lessonModulesApi.uploadFile(lessonId, module.id, file, metadata);
      setImages(updatedModule.images);
    } catch (error) {
      // Handle error
    }
  };
  
  const handleImageRemove = async (index: number) => {
    try {
      const updatedModule = await lessonModulesApi.removeFile(lessonId, module.id, index);
      setImages(updatedModule.images);
    } catch (error) {
      // Handle error
    }
  };
  
  return (
    <div className="image-module">
      <h3>{module.title}</h3>
      <p>{module.description}</p>
      
      {isEditing && (
        <FileUploader
          moduleId={module.id}
          lessonId={lessonId}
          moduleType="ImageModule"
          onUploadSuccess={(fileData) => setImages([...images, fileData])}
          onUploadError={(error) => console.error(error)}
          multiple={true}
        />
      )}
      
      <div className={`image-gallery layout-${module.layout}`}>
        {images.map((image, index) => (
          <FilePreview
            key={index}
            file={image}
            moduleType="ImageModule"
            onRemove={() => handleImageRemove(index)}
            onEdit={(metadata) => {
              // Handle metadata editing
            }}
          />
        ))}
      </div>
    </div>
  );
};
```

### 5. **File Upload UI/UX**

Implement drag-and-drop file upload with progress indicators:

```typescript
// DragDropUploader.tsx
const DragDropUploader: React.FC<FileUploaderProps> = ({ onUploadSuccess, onUploadError, ...props }) => {
  const [isDragOver, setIsDragOver] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [progress, setProgress] = useState(0);
  
  const handleDrop = async (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragOver(false);
    
    const files = Array.from(e.dataTransfer.files);
    await uploadFiles(files);
  };
  
  const handleFileSelect = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || []);
    await uploadFiles(files);
  };
  
  const uploadFiles = async (files: File[]) => {
    setUploading(true);
    setProgress(0);
    
    try {
      for (let i = 0; i < files.length; i++) {
        const file = files[i];
        setProgress((i / files.length) * 100);
        
        await onUploadSuccess(file);
      }
      setProgress(100);
    } catch (error) {
      onUploadError(error.message);
    } finally {
      setUploading(false);
      setProgress(0);
    }
  };
  
  return (
    <div
      className={`drag-drop-uploader ${isDragOver ? 'drag-over' : ''}`}
      onDragOver={(e) => {
        e.preventDefault();
        setIsDragOver(true);
      }}
      onDragLeave={() => setIsDragOver(false)}
      onDrop={handleDrop}
    >
      {uploading ? (
        <div className="upload-progress">
          <div className="progress-bar">
            <div className="progress-fill" style={{ width: `${progress}%` }} />
          </div>
          <p>Uploading... {Math.round(progress)}%</p>
        </div>
      ) : (
        <>
          <input
            type="file"
            multiple={props.multiple}
            accept={props.allowedTypes?.join(',')}
            onChange={handleFileSelect}
            style={{ display: 'none' }}
            id="file-input"
          />
          <label htmlFor="file-input" className="upload-area">
            <Icon name="upload" />
            <p>Drag and drop files here or click to browse</p>
            <p className="file-limits">
              Max size: {formatFileSize(props.maxFileSize || 50 * 1024 * 1024)}
            </p>
          </label>
        </>
      )}
    </div>
  );
};
```

### 6. **Error Handling & Validation**

Implement comprehensive error handling:

```typescript
// FileValidation.ts
export const validateFile = (
  file: File, 
  moduleType: 'ResourcesModule' | 'ImageModule'
): { valid: boolean; error?: string } => {
  const maxSizes = {
    ResourcesModule: 50 * 1024 * 1024, // 50MB
    ImageModule: 10 * 1024 * 1024, // 10MB
  };
  
  const allowedTypes = {
    ResourcesModule: [
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.ms-powerpoint',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'text/plain',
      'text/csv',
      'application/zip',
      'application/x-zip-compressed'
    ],
    ImageModule: [
      'image/jpeg',
      'image/jpg',
      'image/png',
      'image/gif',
      'image/webp',
      'image/svg+xml'
    ],
  };
  
  if (file.size > maxSizes[moduleType]) {
    return {
      valid: false,
      error: `File size exceeds maximum allowed size of ${formatFileSize(maxSizes[moduleType])}`
    };
  }
  
  if (!allowedTypes[moduleType].includes(file.type)) {
    return {
      valid: false,
      error: `File type not allowed. Allowed types: ${allowedTypes[moduleType].join(', ')}`
    };
  }
  
  return { valid: true };
};
```

### 7. **Type Definitions**

Update TypeScript interfaces:

```typescript
// types/lessonModules.ts
export interface FileData {
  attachment: {
    id: number;
    filename: string;
    content_type: string;
    byte_size: number;
    url: string;
  };
  metadata: {
    title: string;
    description?: string;
    alt_text?: string;
  };
  filename: string;
  content_type: string;
  byte_size: number;
  url: string;
  title: string;
  description?: string;
  alt_text?: string;
}

export interface ResourcesModule extends BaseModule {
  type: 'ResourcesModule';
  resources: FileData[];
  resource_count: number;
  file_resources: any[];
  link_resources: any[];
  total_file_size: number;
  formatted_total_size: string;
}

export interface ImageModule extends BaseModule {
  type: 'ImageModule';
  images: FileData[];
  image_count: number;
  layout: 'single' | 'gallery' | 'carousel' | 'grid';
  single_image: boolean;
  gallery: boolean;
  carousel: boolean;
  grid: boolean;
}
```

### 8. **Styling & CSS**

Create responsive styles for file upload components:

```css
/* FileUploader.css */
.drag-drop-uploader {
  border: 2px dashed #ddd;
  border-radius: 8px;
  padding: 2rem;
  text-align: center;
  transition: all 0.3s ease;
  background: #fafafa;
}

.drag-drop-uploader.drag-over {
  border-color: #007bff;
  background: #f0f8ff;
}

.upload-area {
  cursor: pointer;
  display: block;
}

.upload-area:hover {
  opacity: 0.8;
}

.upload-progress {
  width: 100%;
}

.progress-bar {
  width: 100%;
  height: 8px;
  background: #e9ecef;
  border-radius: 4px;
  overflow: hidden;
  margin-bottom: 1rem;
}

.progress-fill {
  height: 100%;
  background: #007bff;
  transition: width 0.3s ease;
}

/* FileList.css */
.file-list {
  display: grid;
  gap: 1rem;
  margin-top: 1rem;
}

.file-item {
  display: flex;
  align-items: center;
  padding: 1rem;
  border: 1px solid #ddd;
  border-radius: 8px;
  background: white;
}

.file-icon {
  margin-right: 1rem;
  font-size: 1.5rem;
}

.file-info {
  flex: 1;
}

.file-title {
  font-weight: 600;
  margin-bottom: 0.25rem;
}

.file-meta {
  font-size: 0.875rem;
  color: #666;
}

.file-actions {
  display: flex;
  gap: 0.5rem;
}

/* ImageGallery.css */
.image-gallery {
  display: grid;
  gap: 1rem;
  margin-top: 1rem;
}

.image-gallery.layout-single {
  grid-template-columns: 1fr;
}

.image-gallery.layout-gallery {
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
}

.image-gallery.layout-grid {
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
}

.image-gallery.layout-carousel {
  display: flex;
  overflow-x: auto;
  gap: 1rem;
  padding: 1rem 0;
}

.image-item {
  position: relative;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.image-item img {
  width: 100%;
  height: auto;
  display: block;
}

.image-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.image-item:hover .image-overlay {
  opacity: 1;
}
```

## Implementation Priority

1. **High Priority**
   - File upload components with drag-and-drop
   - API integration for upload/remove
   - Basic file display components
   - Error handling and validation

2. **Medium Priority**
   - File metadata editing
   - Progress indicators
   - Image gallery layouts
   - File preview components

3. **Low Priority**
   - Advanced image editing
   - File reordering
   - Bulk operations
   - Advanced metadata features

## Testing Requirements

- Test file upload with various file types and sizes
- Test error handling for invalid files
- Test drag-and-drop functionality
- Test file removal
- Test responsive design on different screen sizes
- Test accessibility features

## Notes

- The backend automatically handles file cleanup when modules are deleted
- File URLs are signed and expire after 5 minutes
- All file operations require admin privileges
- The architecture supports rich metadata for each file
- Files are stored in S3 and served via CDN for optimal performance

Implement this integration following the existing codebase patterns and ensure proper error handling, loading states, and user feedback throughout the upload process.
