# Cloudflare Stream Integration

This document outlines the complete Cloudflare Stream integration for the MDN Video Library API, including setup, configuration, and usage.

## 🎥 Overview

The application now supports Cloudflare Stream for video hosting and playback, replacing the previous video player implementation. This integration provides:

- **High-performance video delivery** via Cloudflare's global network
- **Adaptive streaming** with multiple quality options
- **Built-in analytics** and viewer insights
- **Secure video access** with signed URLs
- **Automatic transcoding** and optimization

## 📋 Features Implemented

### 1. Database Schema Updates
- Added `cloudflare_stream_id` field to lessons table
- Added `cloudflare_stream_thumbnail` for video thumbnails
- Added `cloudflare_stream_duration` for video length
- Added `cloudflare_stream_status` for video processing status

### 2. CloudflareStreamService
- **Video metadata retrieval** from Cloudflare Stream API
- **Player URL generation** with customizable options
- **Thumbnail URL generation** with size options
- **Video status checking** and readiness validation
- **Analytics integration** for viewer insights

### 3. Enhanced Lesson Model
- **Cloudflare video detection** methods
- **Player URL generation** with options
- **Duration formatting** in human-readable format
- **Video readiness checking** for playback
- **Comprehensive video data** for API responses

### 4. API Integration
- **Enhanced lesson endpoints** with Cloudflare Stream data
- **Video player information** in API responses
- **Backward compatibility** with existing video fields
- **Versioned API support** (v1 and legacy)

## 🚀 Quick Start

### 1. Test the Integration

Visit the test page to see the Cloudflare Player in action:
```
http://localhost:3000/cloudflare_player_test.html
```

### 2. API Testing

Get lesson data with Cloudflare Stream information:
```bash
# Login to get a token
curl -X POST -H "Content-Type: application/json" \
  -d '{"username":"demo","password":"password"}' \
  http://localhost:3000/api/v1/auth/login

# Get lesson with Cloudflare Stream data
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:3000/api/v1/lessons/61
```

### 3. Test Video Information

- **Video ID**: `73cb888469576ace114104f131e8c6c2`
- **Status**: Ready for playback
- **API Endpoint**: `/api/v1/lessons/61`
- **Player URL**: `https://iframe.videodelivery.net/73cb888469576ace114104f131e8c6c2`

## 🔧 Configuration

### Environment Variables

Add these to your environment configuration:

```bash
# Cloudflare Stream API Token (for metadata fetching)
CLOUDFLARE_API_TOKEN=your_cloudflare_api_token_here

# Optional: Cloudflare Account ID
CLOUDFLARE_ACCOUNT_ID=your_account_id_here
```

### Kamal Deployment Configuration

Update `config/deploy.yml` to include Cloudflare environment variables:

```yaml
env:
  secret:
    - RAILS_MASTER_KEY
    - KAMAL_REGISTRY_PASSWORD
    - DATABASE_PASSWORD
    - CLOUDFLARE_API_TOKEN  # Add this line
  clear:
    # ... existing configuration ...
    CLOUDFLARE_ACCOUNT_ID: your_account_id_here  # Optional
```

## 📊 API Response Format

### Lesson with Cloudflare Stream Data

```json
{
  "id": 61,
  "title": "Cloudflare Stream Test Video",
  "description": "Test lesson using Cloudflare Stream video player",
  "content_type": "video",
  "content": "This is a test lesson using Cloudflare Stream for video playback.",
  "media_url": null,
  "order_index": 4,
  "published": true,
  "chapter_id": 11,
  "completed": false,
  "completed_at": null,
  "cloudflare_stream_id": "73cb888469576ace114104f131e8c6c2",
  "cloudflare_stream_thumbnail": "https://videodelivery.net/...",
  "cloudflare_stream_duration": 120,
  "cloudflare_stream_status": "ready",
  "formatted_duration": "2:00",
  "video_ready": true,
  "video_player_data": {
    "cloudflare_stream_id": "73cb888469576ace114104f131e8c6c2",
    "player_url": "https://iframe.videodelivery.net/...",
    "thumbnail_url": "https://videodelivery.net/...",
    "duration": 120,
    "formatted_duration": "2:00",
    "status": "ready",
    "ready": true,
    "preview_url": "https://videodelivery.net/.../manifest/video.m3u8",
    "download_url": "https://videodelivery.net/.../downloads/default.mp4"
  }
}
```

## 🛠️ Usage Examples

### 1. Creating a Lesson with Cloudflare Stream

```ruby
# In Rails console or controller
lesson = chapter.lessons.create!(
  title: "My Video Lesson",
  description: "A lesson with Cloudflare Stream video",
  content_type: "video",
  cloudflare_stream_id: "your_video_id_here",
  published: true,
  order_index: 1
)

# Update with metadata from Cloudflare
lesson.update_cloudflare_metadata
```

### 2. Generating Player URLs

```ruby
# Basic player URL
player_url = lesson.cloudflare_player_url

# Custom player options
player_url = lesson.cloudflare_player_url(
  autoplay: true,
  controls: true,
  loop: false,
  muted: true,
  width: '100%',
  height: '400px'
)

# Generate iframe HTML
iframe_html = lesson.cloudflare_player_iframe(
  width: '100%',
  height: '400',
  allowfullscreen: true
)
```

### 3. Getting Video Information

```ruby
# Check if video is ready
if lesson.video_ready_for_playback?
  puts "Video is ready to play"
end

# Get formatted duration
puts lesson.formatted_duration  # "2:30" or "1:23:45"

# Get thumbnail URL
thumbnail_url = lesson.cloudflare_thumbnail_url(
  width: 640,
  height: 360,
  fit: 'scale-down'
)
```

## 🔍 Service Methods

### CloudflareStreamService

```ruby
# Get video metadata
metadata = CloudflareStreamService.get_video_metadata(video_id)

# Generate player URL
player_url = CloudflareStreamService.player_url(video_id, options)

# Generate iframe HTML
iframe_html = CloudflareStreamService.player_iframe(video_id, options)

# Check video readiness
ready = CloudflareStreamService.video_ready?(video_id)

# Get thumbnail URL
thumbnail_url = CloudflareStreamService.thumbnail_url(video_id, options)

# Get preview URL (HLS)
preview_url = CloudflareStreamService.preview_url(video_id)

# Get download URL
download_url = CloudflareStreamService.download_url(video_id, quality)

# Validate video ID format
valid = CloudflareStreamService.valid_video_id?(video_id)
```

## 🎯 Frontend Integration

### React/Next.js Example

```jsx
import React from 'react';

const VideoPlayer = ({ lesson }) => {
  if (!lesson.cloudflare_video) {
    return <div>No video available</div>;
  }

  return (
    <div className="video-container">
      <iframe
        src={lesson.video_player_data.player_url}
        width="100%"
        height="400"
        frameBorder="0"
        allowFullScreen
        allow="autoplay; fullscreen"
      />
      <div className="video-info">
        <p>Duration: {lesson.video_player_data.formatted_duration}</p>
        <p>Status: {lesson.video_player_data.status}</p>
      </div>
    </div>
  );
};
```

### Vanilla JavaScript Example

```javascript
function createVideoPlayer(lesson) {
  if (!lesson.cloudflare_stream_id) {
    return 'No video available';
  }

  const iframe = document.createElement('iframe');
  iframe.src = lesson.video_player_data.player_url;
  iframe.width = '100%';
  iframe.height = '400';
  iframe.frameBorder = '0';
  iframe.allowFullscreen = true;
  iframe.allow = 'autoplay; fullscreen';

  return iframe;
}
```

## 📈 Analytics and Monitoring

### Video Analytics

```ruby
# Get video analytics (requires API token)
analytics = CloudflareStreamService.get_video_analytics(video_id)

# Analytics data includes:
# - View count
# - Watch time
# - Geographic distribution
# - Device types
# - Quality metrics
```

### Health Monitoring

```ruby
# Check video status
status = lesson.cloudflare_stream_status

# Monitor video readiness
if lesson.video_ready_for_playback?
  # Video is ready for users
else
  # Video is still processing or has issues
end
```

## 🔒 Security Considerations

### 1. API Token Security
- Store `CLOUDFLARE_API_TOKEN` as a secret in Kamal
- Never commit API tokens to version control
- Use environment-specific tokens

### 2. Video Access Control
- Cloudflare Stream provides signed URLs for secure access
- Implement user authentication before serving video URLs
- Consider implementing video access permissions

### 3. Rate Limiting
- Cloudflare Stream API has rate limits
- Implement caching for video metadata
- Handle API errors gracefully

## 🚀 Deployment

### 1. Update Kamal Secrets

```bash
# Add Cloudflare API token to secrets
echo "CLOUDFLARE_API_TOKEN=your_token_here" >> .kamal/secrets
```

### 2. Deploy with Kamal

```bash
# Deploy the updated application
kamal deploy

# Verify the deployment
kamal app status
```

### 3. Test in Production

```bash
# Test the API endpoint
curl -H "Authorization: Bearer YOUR_TOKEN" \
  https://your-domain.com/api/v1/lessons/61
```

## 🔧 Troubleshooting

### Common Issues

1. **"CLOUDFLARE_API_TOKEN not set"**
   - Set the environment variable in your deployment
   - Check Kamal secrets configuration

2. **"Failed to fetch Cloudflare Stream metadata"**
   - Verify API token is valid
   - Check video ID format (32 character hex string)
   - Ensure video exists in your Cloudflare Stream account

3. **Video not playing**
   - Check video status is "ready"
   - Verify CORS settings if embedding in different domain
   - Test player URL directly in browser

4. **API errors**
   - Check Cloudflare Stream API documentation
   - Verify account permissions
   - Monitor rate limits

### Debug Commands

```ruby
# In Rails console
lesson = Lesson.find(61)
puts lesson.cloudflare_video?
puts lesson.video_ready_for_playback?
puts lesson.cloudflare_player_url

# Test service directly
metadata = CloudflareStreamService.get_video_metadata("73cb888469576ace114104f131e8c6c2")
puts metadata
```

## 📚 Additional Resources

- [Cloudflare Stream Documentation](https://developers.cloudflare.com/stream/)
- [Cloudflare Stream API Reference](https://developers.cloudflare.com/stream/api/)
- [Cloudflare Player Documentation](https://developers.cloudflare.com/stream/viewing-videos/using-the-stream-player/)
- [Rails HTTParty Documentation](https://github.com/jnunemaker/httparty)

## 🎉 Success!

Your Cloudflare Stream integration is now complete and ready for production use! The test video is available at:

- **Test Page**: http://localhost:3000/cloudflare_player_test.html
- **API Endpoint**: http://localhost:3000/api/v1/lessons/61
- **Player URL**: https://iframe.videodelivery.net/73cb888469576ace114104f131e8c6c2

The integration provides a robust foundation for video hosting and playback in your curriculum application.
