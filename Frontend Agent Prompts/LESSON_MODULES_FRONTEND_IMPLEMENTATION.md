# Frontend Agent Prompt: Lesson Modules Implementation

## Overview

You are tasked with implementing the frontend for a new **Lesson Modules system** that allows creating rich, modular educational content. The backend API is complete and ready for integration.

## System Architecture

### Module Types
The system supports 5 different module types, each with unique functionality:

1. **TextModule** - Rich text content with Tiptap editor
2. **VideoModule** - Cloudflare Stream video integration
3. **AssessmentModule** - Interactive quizzes and assessments
4. **ResourcesModule** - Downloadable files and links
5. **ImageModule** - Image galleries and visual content

### Key Concepts
- **STI (Single Table Inheritance)**: All modules share a common base but have type-specific data
- **Position-based ordering**: Modules are ordered by a `position` field
- **Settings JSONB**: Each module type has flexible configuration via a `settings` field
- **Type-specific responses**: API returns different data based on module type

## Implementation Requirements

### 1. API Integration

#### Base API Client
Create or update your API client to handle the new endpoints:

```typescript
// API endpoints to implement
const lessonModulesAPI = {
  // List all modules for a lesson
  list: (lessonId: number) => GET(`/api/v1/lessons/${lessonId}/lesson_modules`),
  
  // Get single module
  get: (lessonId: number, moduleId: number) => GET(`/api/v1/lessons/${lessonId}/lesson_modules/${moduleId}`),
  
  // Create new module
  create: (lessonId: number, data: LessonModuleData) => POST(`/api/v1/lessons/${lessonId}/lesson_modules`, data),
  
  // Update module
  update: (lessonId: number, moduleId: number, data: Partial<LessonModuleData>) => PATCH(`/api/v1/lessons/${lessonId}/lesson_modules/${moduleId}`, data),
  
  // Delete module
  delete: (lessonId: number, moduleId: number) => DELETE(`/api/v1/lessons/${lessonId}/lesson_modules/${moduleId}`),
  
  // Reorder modules
  reorder: (lessonId: number, moduleIds: number[]) => PATCH(`/api/v1/lessons/${lessonId}/lesson_modules/reorder`, { module_ids: moduleIds }),
  
  // Get lesson with modules
  getLessonWithModules: (lessonId: number) => GET(`/api/v1/lessons/${lessonId}?include_modules=true`)
};
```

#### Type Definitions
Create comprehensive TypeScript types:

```typescript
// Base module interface
interface BaseLessonModule {
  id: number;
  type: 'TextModule' | 'VideoModule' | 'AssessmentModule' | 'ResourcesModule' | 'ImageModule';
  title: string;
  description: string;
  position: number;
  settings: Record<string, any>;
  published: boolean;
  published_at: string | null;
  created_at: string;
  updated_at: string;
}

// Type-specific interfaces
interface TextModule extends BaseLessonModule {
  type: 'TextModule';
  content: string;
  word_count: number;
  reading_time: number;
  table_of_contents: Array<{
    id: string;
    level: number;
    text: string;
    index: number;
  }>;
  excerpt: string;
}

interface VideoModule extends BaseLessonModule {
  type: 'VideoModule';
  cloudflare_stream_id: string;
  cloudflare_stream_thumbnail: string | null;
  cloudflare_stream_duration: number | null;
  cloudflare_stream_status: string;
  formatted_duration: string | null;
  video_ready: boolean;
  video_player_data: {
    cloudflare_stream_id: string;
    player_url: string;
    thumbnail_url: string;
    duration: number;
    formatted_duration: string;
    status: string;
    ready: boolean;
    preview_url: string;
    download_url: string;
  } | null;
}

interface AssessmentModule extends BaseLessonModule {
  type: 'AssessmentModule';
  questions: Array<{
    text: string;
    type: 'single_choice' | 'multiple_choice' | 'true_false';
    options: string[];
    correct_answer: number;
    points: number;
  }>;
  question_count: number;
  total_points: number;
  passing_score: number;
  estimated_time: number;
}

interface ResourcesModule extends BaseLessonModule {
  type: 'ResourcesModule';
  resources: Array<{
    title: string;
    type: 'file' | 'link' | 'video';
    url: string;
    file_size?: number;
  }>;
  resource_count: number;
  file_resources: Array<any>;
  link_resources: Array<any>;
  total_file_size: number;
  formatted_total_size: string;
}

interface ImageModule extends BaseLessonModule {
  type: 'ImageModule';
  images: Array<{
    title: string;
    url: string;
    alt_text: string;
    thumbnail_url?: string;
  }>;
  image_count: number;
  layout: 'single' | 'gallery' | 'carousel' | 'grid';
  single_image: boolean;
  gallery: boolean;
  carousel: boolean;
  grid: boolean;
}

type LessonModule = TextModule | VideoModule | AssessmentModule | ResourcesModule | ImageModule;
```

### 2. Module Components

Create reusable components for each module type:

#### TextModule Component
```typescript
interface TextModuleProps {
  module: TextModule;
  isEditing?: boolean;
  onUpdate?: (data: Partial<TextModule>) => void;
}

const TextModuleComponent: React.FC<TextModuleProps> = ({ module, isEditing, onUpdate }) => {
  // Implement Tiptap editor for editing mode
  // Display formatted content in view mode
  // Show word count, reading time, table of contents
};
```

#### VideoModule Component
```typescript
interface VideoModuleProps {
  module: VideoModule;
  isEditing?: boolean;
  onUpdate?: (data: Partial<VideoModule>) => void;
}

const VideoModuleComponent: React.FC<VideoModuleProps> = ({ module, isEditing, onUpdate }) => {
  // Integrate Cloudflare Stream player
  // Show video controls, duration, status
  // Handle video upload/selection in edit mode
};
```

#### AssessmentModule Component
```typescript
interface AssessmentModuleProps {
  module: AssessmentModule;
  isEditing?: boolean;
  onUpdate?: (data: Partial<AssessmentModule>) => void;
  onTakeAssessment?: () => void;
}

const AssessmentModuleComponent: React.FC<AssessmentModuleProps> = ({ module, isEditing, onUpdate, onTakeAssessment }) => {
  // Question builder interface for editing
  // Assessment taking interface for students
  // Results display and scoring
};
```

#### ResourcesModule Component
```typescript
interface ResourcesModuleProps {
  module: ResourcesModule;
  isEditing?: boolean;
  onUpdate?: (data: Partial<ResourcesModule>) => void;
}

const ResourcesModuleComponent: React.FC<ResourcesModuleProps> = ({ module, isEditing, onUpdate }) => {
  // Resource list with download/click functionality
  // File upload interface for editing
  // Resource management (add/remove/reorder)
};
```

#### ImageModule Component
```typescript
interface ImageModuleProps {
  module: ImageModule;
  isEditing?: boolean;
  onUpdate?: (data: Partial<ImageModule>) => void;
}

const ImageModuleComponent: React.FC<ImageModuleProps> = ({ module, isEditing, onUpdate }) => {
  // Image gallery/carousel display
  // Image upload and management for editing
  // Layout selection (single/gallery/carousel/grid)
};
```

### 3. Module Factory Component

Create a factory component that renders the appropriate module based on type:

```typescript
interface ModuleFactoryProps {
  module: LessonModule;
  isEditing?: boolean;
  onUpdate?: (data: Partial<LessonModule>) => void;
  onDelete?: (moduleId: number) => void;
}

const ModuleFactory: React.FC<ModuleFactoryProps> = ({ module, isEditing, onUpdate, onDelete }) => {
  const renderModule = () => {
    switch (module.type) {
      case 'TextModule':
        return <TextModuleComponent module={module} isEditing={isEditing} onUpdate={onUpdate} />;
      case 'VideoModule':
        return <VideoModuleComponent module={module} isEditing={isEditing} onUpdate={onUpdate} />;
      case 'AssessmentModule':
        return <AssessmentModuleComponent module={module} isEditing={isEditing} onUpdate={onUpdate} />;
      case 'ResourcesModule':
        return <ResourcesModuleComponent module={module} isEditing={isEditing} onUpdate={onUpdate} />;
      case 'ImageModule':
        return <ImageModuleComponent module={module} isEditing={isEditing} onUpdate={onUpdate} />;
      default:
        return <div>Unknown module type: {module.type}</div>;
    }
  };

  return (
    <div className="module-container">
      {renderModule()}
      {isEditing && (
        <div className="module-actions">
          <button onClick={() => onDelete?.(module.id)}>Delete</button>
        </div>
      )}
    </div>
  );
};
```

### 4. Lesson Editor

Create a comprehensive lesson editor that allows managing modules:

```typescript
interface LessonEditorProps {
  lessonId: number;
  isEditing?: boolean;
}

const LessonEditor: React.FC<LessonEditorProps> = ({ lessonId, isEditing }) => {
  const [modules, setModules] = useState<LessonModule[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Load modules
  useEffect(() => {
    loadModules();
  }, [lessonId]);

  const loadModules = async () => {
    try {
      setLoading(true);
      const response = await lessonModulesAPI.list(lessonId);
      setModules(response.data);
    } catch (err) {
      setError('Failed to load modules');
    } finally {
      setLoading(false);
    }
  };

  // Add new module
  const addModule = async (moduleData: LessonModuleData) => {
    try {
      const response = await lessonModulesAPI.create(lessonId, moduleData);
      setModules(prev => [...prev, response.data]);
    } catch (err) {
      setError('Failed to create module');
    }
  };

  // Update module
  const updateModule = async (moduleId: number, data: Partial<LessonModuleData>) => {
    try {
      const response = await lessonModulesAPI.update(lessonId, moduleId, data);
      setModules(prev => prev.map(m => m.id === moduleId ? response.data : m));
    } catch (err) {
      setError('Failed to update module');
    }
  };

  // Delete module
  const deleteModule = async (moduleId: number) => {
    try {
      await lessonModulesAPI.delete(lessonId, moduleId);
      setModules(prev => prev.filter(m => m.id !== moduleId));
    } catch (err) {
      setError('Failed to delete module');
    }
  };

  // Reorder modules
  const reorderModules = async (moduleIds: number[]) => {
    try {
      await lessonModulesAPI.reorder(lessonId, moduleIds);
      await loadModules(); // Reload to get updated positions
    } catch (err) {
      setError('Failed to reorder modules');
    }
  };

  return (
    <div className="lesson-editor">
      {loading && <div>Loading modules...</div>}
      {error && <div className="error">{error}</div>}
      
      {isEditing && (
        <div className="add-module-section">
          <h3>Add New Module</h3>
          <ModuleTypeSelector onSelect={addModule} />
        </div>
      )}
      
      <div className="modules-list">
        {modules.map((module) => (
          <ModuleFactory
            key={module.id}
            module={module}
            isEditing={isEditing}
            onUpdate={(data) => updateModule(module.id, data)}
            onDelete={() => deleteModule(module.id)}
          />
        ))}
      </div>
      
      {isEditing && modules.length > 1 && (
        <ModuleReorderer modules={modules} onReorder={reorderModules} />
      )}
    </div>
  );
};
```

### 5. Module Type Selector

Create a component for selecting and creating new modules:

```typescript
interface ModuleTypeSelectorProps {
  onSelect: (moduleData: LessonModuleData) => void;
}

const ModuleTypeSelector: React.FC<ModuleTypeSelectorProps> = ({ onSelect }) => {
  const moduleTypes = [
    { type: 'TextModule', label: 'Text Content', icon: '📝', description: 'Rich text with Tiptap editor' },
    { type: 'VideoModule', label: 'Video', icon: '🎥', description: 'Cloudflare Stream video' },
    { type: 'AssessmentModule', label: 'Assessment', icon: '📋', description: 'Interactive quiz or test' },
    { type: 'ResourcesModule', label: 'Resources', icon: '📁', description: 'Files and links' },
    { type: 'ImageModule', label: 'Images', icon: '🖼️', description: 'Image gallery or single image' }
  ];

  const handleCreate = (type: string) => {
    const defaultData = {
      type,
      title: `New ${type.replace('Module', '')}`,
      description: '',
      settings: {}
    };
    
    // Add type-specific defaults
    switch (type) {
      case 'TextModule':
        defaultData.content = '<h1>New Content</h1><p>Start writing...</p>';
        break;
      case 'AssessmentModule':
        defaultData.settings = {
          questions: [],
          passing_score: 70
        };
        break;
      case 'ResourcesModule':
        defaultData.settings = { resources: [] };
        break;
      case 'ImageModule':
        defaultData.settings = { images: [], layout: 'single' };
        break;
    }
    
    onSelect(defaultData);
  };

  return (
    <div className="module-type-selector">
      {moduleTypes.map(({ type, label, icon, description }) => (
        <button
          key={type}
          className="module-type-option"
          onClick={() => handleCreate(type)}
        >
          <span className="icon">{icon}</span>
          <div className="content">
            <h4>{label}</h4>
            <p>{description}</p>
          </div>
        </button>
      ))}
    </div>
  );
};
```

### 6. Module Reorderer

Create a drag-and-drop interface for reordering modules:

```typescript
interface ModuleReordererProps {
  modules: LessonModule[];
  onReorder: (moduleIds: number[]) => void;
}

const ModuleReorderer: React.FC<ModuleReordererProps> = ({ modules, onReorder }) => {
  const [draggedModule, setDraggedModule] = useState<number | null>(null);

  const handleDragStart = (moduleId: number) => {
    setDraggedModule(moduleId);
  };

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
  };

  const handleDrop = (targetModuleId: number) => {
    if (!draggedModule || draggedModule === targetModuleId) return;
    
    const currentOrder = modules.map(m => m.id);
    const draggedIndex = currentOrder.indexOf(draggedModule);
    const targetIndex = currentOrder.indexOf(targetModuleId);
    
    // Reorder array
    const newOrder = [...currentOrder];
    newOrder.splice(draggedIndex, 1);
    newOrder.splice(targetIndex, 0, draggedModule);
    
    onReorder(newOrder);
    setDraggedModule(null);
  };

  return (
    <div className="module-reorderer">
      <h3>Reorder Modules</h3>
      <div className="modules-list">
        {modules.map((module) => (
          <div
            key={module.id}
            className={`module-item ${draggedModule === module.id ? 'dragging' : ''}`}
            draggable
            onDragStart={() => handleDragStart(module.id)}
            onDragOver={handleDragOver}
            onDrop={() => handleDrop(module.id)}
          >
            <span className="drag-handle">⋮⋮</span>
            <span className="position">{module.position}</span>
            <span className="title">{module.title}</span>
            <span className="type">{module.type}</span>
          </div>
        ))}
      </div>
    </div>
  );
};
```

### 7. Error Handling & Loading States

Implement comprehensive error handling:

```typescript
// Error handling utilities
const handleApiError = (error: any) => {
  if (error.response?.status === 401) {
    // Handle authentication error
    redirectToLogin();
  } else if (error.response?.status === 403) {
    // Handle authorization error
    showNotification('Admin access required', 'error');
  } else if (error.response?.data?.errors) {
    // Handle validation errors
    const errors = error.response.data.errors;
    showNotification(errors.join(', '), 'error');
  } else {
    // Handle generic errors
    showNotification('An unexpected error occurred', 'error');
  }
};

// Loading states
const LoadingSpinner = () => <div className="loading-spinner">Loading...</div>;
const ErrorMessage = ({ message }: { message: string }) => (
  <div className="error-message">{message}</div>
);
```

### 8. Styling & UX

Implement responsive, accessible styling:

```css
/* Module container styles */
.module-container {
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 16px;
  background: white;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.module-type-selector {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}

.module-type-option {
  display: flex;
  align-items: center;
  padding: 16px;
  border: 2px dashed #d1d5db;
  border-radius: 8px;
  background: #f9fafb;
  cursor: pointer;
  transition: all 0.2s;
}

.module-type-option:hover {
  border-color: #3b82f6;
  background: #eff6ff;
}

.module-reorderer .module-item {
  display: flex;
  align-items: center;
  padding: 12px;
  border: 1px solid #e5e7eb;
  border-radius: 4px;
  margin-bottom: 8px;
  background: white;
  cursor: move;
}

.module-item.dragging {
  opacity: 0.5;
  transform: rotate(2deg);
}
```

## Implementation Checklist

### Phase 1: Core Infrastructure
- [ ] Set up API client for lesson modules endpoints
- [ ] Create TypeScript type definitions
- [ ] Implement ModuleFactory component
- [ ] Create basic module display components

### Phase 2: Module Components
- [ ] Implement TextModule component with Tiptap integration
- [ ] Implement VideoModule component with Cloudflare Stream
- [ ] Implement AssessmentModule component with quiz functionality
- [ ] Implement ResourcesModule component with file management
- [ ] Implement ImageModule component with gallery support

### Phase 3: Editor Interface
- [ ] Create ModuleTypeSelector component
- [ ] Implement ModuleReorderer with drag-and-drop
- [ ] Build comprehensive LessonEditor
- [ ] Add error handling and loading states

### Phase 4: Integration & Polish
- [ ] Integrate with existing lesson pages
- [ ] Add proper authentication checks
- [ ] Implement responsive design
- [ ] Add accessibility features
- [ ] Write comprehensive tests

## Testing Strategy

1. **Unit Tests**: Test individual module components
2. **Integration Tests**: Test API integration and data flow
3. **E2E Tests**: Test complete user workflows
4. **Accessibility Tests**: Ensure WCAG compliance

## Performance Considerations

1. **Lazy Loading**: Load modules on demand
2. **Caching**: Cache module data appropriately
3. **Optimistic Updates**: Update UI immediately, sync with server
4. **Debouncing**: Debounce reorder operations

## Security Considerations

1. **Input Validation**: Validate all user inputs
2. **XSS Prevention**: Sanitize HTML content
3. **File Upload Security**: Validate file types and sizes
4. **Authentication**: Ensure proper auth checks

## Next Steps

1. Start with the API integration and type definitions
2. Build the ModuleFactory and basic display components
3. Implement the editor interface
4. Add advanced features like drag-and-drop reordering
5. Polish the UI/UX and add comprehensive testing

Remember to follow the existing codebase patterns and maintain consistency with the current design system.
