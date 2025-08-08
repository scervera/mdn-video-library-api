# Rails Backend for Christian Curriculum App

This document outlines the Rails backend structure needed to support the Next.js frontend.

## Rails Application Setup

### Prerequisites
- Ruby 3.2+
- Rails 7.0+
- PostgreSQL
- Redis (for session storage)

### Initial Setup

```bash
# Create new Rails API application
rails new christian-curriculum-api --api --database=postgresql

# Add necessary gems to Gemfile
gem 'bcrypt'
gem 'jwt'
gem 'rack-cors'
gem 'active_storage'
gem 'aws-sdk-s3' # For file storage
gem 'pundit' # For authorization
gem 'fast_jsonapi' # For JSON serialization
```

## Database Schema

### Users
```ruby
create_table :users do |t|
  t.string :username, null: false, unique: true
  t.string :email, null: false, unique: true
  t.string :password_digest, null: false
  t.string :first_name
  t.string :last_name
  t.boolean :active, default: true
  t.timestamps
end
```

### Chapters
```ruby
create_table :chapters do |t|
  t.string :title, null: false
  t.text :description
  t.string :duration
  t.integer :order_index, null: false
  t.boolean :published, default: false
  t.timestamps
end
```

### Lessons
```ruby
create_table :lessons do |t|
  t.references :chapter, null: false, foreign_key: true
  t.string :title, null: false
  t.text :description
  t.string :content_type # video, text, image, pdf
  t.text :content
  t.string :media_url
  t.integer :order_index, null: false
  t.boolean :published, default: false
  t.timestamps
end
```

### User Progress
```ruby
create_table :user_progress do |t|
  t.references :user, null: false, foreign_key: true
  t.references :chapter, null: false, foreign_key: true
  t.boolean :completed, default: false
  t.datetime :completed_at
  t.timestamps
end
```

### Lesson Progress
```ruby
create_table :lesson_progress do |t|
  t.references :user, null: false, foreign_key: true
  t.references :lesson, null: false, foreign_key: true
  t.boolean :completed, default: false
  t.datetime :completed_at
  t.timestamps
end
```

### User Notes
```ruby
create_table :user_notes do |t|
  t.references :user, null: false, foreign_key: true
  t.references :chapter, null: false, foreign_key: true
  t.text :content
  t.timestamps
end
```

### User Highlights
```ruby
create_table :user_highlights do |t|
  t.references :user, null: false, foreign_key: true
  t.references :chapter, null: false, foreign_key: true
  t.string :highlighted_text
  t.timestamps
end
```

## API Routes

```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    # Authentication
    post 'auth/login'
    post 'auth/logout'
    get 'auth/me'
    
    # Chapters
    resources :chapters, only: [:index, :show] do
      member do
        post :complete
      end
      resources :lessons, only: [:index]
    end
    
    # Lessons
    resources :lessons, only: [:show] do
      member do
        post :complete
      end
    end
    
    # User Progress
    namespace :user do
      get 'progress'
      resources :notes, only: [:index, :show, :create, :update]
      resources :highlights, only: [:index, :show, :create, :update]
    end
  end
end
```

## Controllers

### Authentication Controller
```ruby
# app/controllers/api/auth_controller.rb
class Api::AuthController < ApplicationController
  def login
    user = User.find_by(username: params[:username])
    
    if user&.authenticate(params[:password])
      token = JWT.encode({ user_id: user.id }, Rails.application.secrets.secret_key_base)
      render json: { user: user, token: token }
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end
  
  def logout
    # In a real app, you might want to blacklist the token
    render json: { message: 'Logged out successfully' }
  end
  
  def me
    render json: current_user
  end
end
```

### Chapters Controller
```ruby
# app/controllers/api/chapters_controller.rb
class Api::ChaptersController < ApplicationController
  before_action :authenticate_user!
  
  def index
    chapters = Chapter.published.order(:order_index)
    render json: chapters.map { |chapter| chapter_with_progress(chapter) }
  end
  
  def show
    chapter = Chapter.find(params[:id])
    render json: chapter_with_progress(chapter)
  end
  
  def complete
    chapter = Chapter.find(params[:id])
    progress = current_user.user_progress.find_or_create_by(chapter: chapter)
    progress.update(completed: true, completed_at: Time.current)
    render json: { message: 'Chapter completed' }
  end
  
  private
  
  def chapter_with_progress(chapter)
    progress = current_user.user_progress.find_by(chapter: chapter)
    {
      id: chapter.id,
      title: chapter.title,
      description: chapter.description,
      duration: chapter.duration,
      lessons: chapter.lessons.published.order(:order_index).pluck(:title),
      isLocked: chapter.order_index > current_user.completed_chapters_count + 1,
      completed: progress&.completed || false
    }
  end
end
```

### Lessons Controller
```ruby
# app/controllers/api/lessons_controller.rb
class Api::LessonsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    chapter = Chapter.find(params[:chapter_id])
    lessons = chapter.lessons.published.order(:order_index)
    render json: lessons.map { |lesson| lesson_with_progress(lesson) }
  end
  
  def show
    lesson = Lesson.find(params[:id])
    render json: lesson_with_progress(lesson)
  end
  
  def complete
    lesson = Lesson.find(params[:id])
    progress = current_user.lesson_progress.find_or_create_by(lesson: lesson)
    progress.update(completed: true, completed_at: Time.current)
    render json: { message: 'Lesson completed' }
  end
  
  private
  
  def lesson_with_progress(lesson)
    progress = current_user.lesson_progress.find_by(lesson: lesson)
    {
      id: lesson.id,
      title: lesson.title,
      type: lesson.content_type,
      content: lesson.content,
      description: lesson.description,
      completed: progress&.completed || false
    }
  end
end
```

### User Progress Controller
```ruby
# app/controllers/api/user/progress_controller.rb
class Api::User::ProgressController < ApplicationController
  before_action :authenticate_user!
  
  def index
    render json: {
      completedChapters: current_user.user_progress.where(completed: true).pluck(:chapter_id),
      completedLessons: current_user.lesson_progress.where(completed: true).pluck(:lesson_id),
      notes: current_user.user_notes.index_by(&:chapter_id).transform_values(&:content),
      highlights: current_user.user_highlights.group_by(&:chapter_id).transform_values { |highlights| highlights.pluck(:highlighted_text) }
    }
  end
end
```

## Models

### User Model
```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_secure_password
  
  has_many :user_progress, dependent: :destroy
  has_many :lesson_progress, dependent: :destroy
  has_many :user_notes, dependent: :destroy
  has_many :user_highlights, dependent: :destroy
  
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  
  def completed_chapters_count
    user_progress.where(completed: true).count
  end
end
```

### Chapter Model
```ruby
# app/models/chapter.rb
class Chapter < ApplicationRecord
  has_many :lessons, dependent: :destroy
  has_many :user_progress, dependent: :destroy
  
  validates :title, presence: true
  validates :order_index, presence: true, uniqueness: true
  
  scope :published, -> { where(published: true) }
end
```

### Lesson Model
```ruby
# app/models/lesson.rb
class Lesson < ApplicationRecord
  belongs_to :chapter
  has_many :lesson_progress, dependent: :destroy
  
  validates :title, presence: true
  validates :content_type, presence: true, inclusion: { in: %w[video text image pdf] }
  validates :order_index, presence: true, uniqueness: { scope: :chapter_id }
  
  scope :published, -> { where(published: true) }
end
```

## Authentication

### Application Controller
```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  before_action :authenticate_user!
  
  private
  
  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    return render json: { error: 'No token provided' }, status: :unauthorized unless token
    
    begin
      decoded = JWT.decode(token, Rails.application.secrets.secret_key_base)[0]
      @current_user = User.find(decoded['user_id'])
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end
  
  def current_user
    @current_user
  end
end
```

## File Storage

### Active Storage Setup
```ruby
# config/storage.yml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>

amazon:
  service: S3
  access_key_id: <%= ENV['AWS_ACCESS_KEY_ID'] %>
  secret_access_key: <%= ENV['AWS_SECRET_ACCESS_KEY'] %>
  region: <%= ENV['AWS_REGION'] %>
  bucket: <%= ENV['AWS_BUCKET'] %>
```

### Media Attachments
```ruby
# app/models/lesson.rb
class Lesson < ApplicationRecord
  has_one_attached :media_file
  
  def media_url
    media_file.attached? ? Rails.application.routes.url_helpers.rails_blob_url(media_file) : nil
  end
end
```

## Environment Variables

Create a `.env` file:
```bash
# Database
DATABASE_URL=postgresql://localhost/christian_curriculum_development

# JWT Secret
JWT_SECRET_KEY=your-secret-key-here

# AWS S3 (if using)
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_REGION=us-east-1
AWS_BUCKET=your-bucket-name

# CORS
ALLOWED_ORIGINS=http://localhost:3000,https://yourdomain.com
```

## CORS Configuration

```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV['ALLOWED_ORIGINS']&.split(',') || ['http://localhost:3000']
    
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
```

## Sample Data

Create a seeds file to populate the database with sample curriculum data:

```ruby
# db/seeds.rb
# Create sample chapters and lessons
chapters_data = [
  {
    title: "Foundation of Faith",
    description: "Understanding the core principles of Christian faith",
    duration: "2 hours",
    order_index: 1,
    lessons: [
      { title: "Introduction to Faith", content_type: "video", order_index: 1 },
      { title: "The Bible as Foundation", content_type: "text", order_index: 2 },
      { title: "Prayer Basics", content_type: "text", order_index: 3 }
    ]
  },
  # Add more chapters...
]

chapters_data.each do |chapter_data|
  chapter = Chapter.create!(
    title: chapter_data[:title],
    description: chapter_data[:description],
    duration: chapter_data[:duration],
    order_index: chapter_data[:order_index],
    published: true
  )
  
  chapter_data[:lessons].each do |lesson_data|
    chapter.lessons.create!(
      title: lesson_data[:title],
      content_type: lesson_data[:content_type],
      order_index: lesson_data[:order_index],
      content: "Sample content for #{lesson_data[:title]}",
      description: "Description for #{lesson_data[:title]}",
      published: true
    )
  end
end
```

## Testing

### RSpec Setup
```ruby
# Gemfile
group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
end
```

### Sample Test
```ruby
# spec/requests/api/chapters_spec.rb
require 'rails_helper'

RSpec.describe 'Chapters API', type: :request do
  let(:user) { create(:user) }
  let(:token) { JWT.encode({ user_id: user.id }, Rails.application.secrets.secret_key_base) }
  
  before do
    @headers = { 'Authorization' => "Bearer #{token}" }
  end
  
  describe 'GET /api/chapters' do
    it 'returns all published chapters' do
      chapter = create(:chapter, published: true)
      
      get '/api/chapters', headers: @headers
      
      expect(response).to have_http_status(200)
      expect(json_response.size).to eq(1)
      expect(json_response.first['title']).to eq(chapter.title)
    end
  end
end
```

This Rails backend structure provides all the necessary endpoints and functionality to support the Next.js frontend. The API is RESTful, secure, and scalable for production use.
