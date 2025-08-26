# Frontend Cloudflare Stream Integration Guide

## 🎯 **CRITICAL UPDATE REQUIRED**

**Issue**: The frontend is currently trying to access a video with ID `"demo-video-placeholder"` which doesn't exist in the backend database.

**Solution**: Update the frontend to use the correct Cloudflare Stream video IDs from the API response.

---

## 📋 **Current Backend Status**

✅ **Cloudflare Stream Implementation**: **FULLY FUNCTIONAL**
- All static methods implemented in `CloudflareStreamService`
- Video URLs, thumbnails, and metadata generation working
- API endpoints returning complete video player data

✅ **Database Status**: 
- All lessons have valid Cloudflare Stream IDs: `73cb888469576ace114104f131e8c6c2`
- Video status: `"ready"` for all videos
- Video player data includes all required URLs and metadata

---

## 🔧 **Required Frontend Changes**

### **1. Remove Hardcoded Video ID**

**❌ Current (Broken)**:
```javascript
// Remove any hardcoded references to "demo-video-placeholder"
const videoId = "demo-video-placeholder"; // ❌ WRONG
```

**✅ Correct Implementation**:
```javascript
// Use the video ID from the API response
const videoId = lesson.cloudflare_stream_id; // ✅ CORRECT
```

### **2. Use API Response Data**

The lessons API now returns complete video player data:

```json
{
  "id": 116,
  "title": "Empathy and User Research",
  "content_type": "video",
  "cloudflare_stream_id": "73cb888469576ace114104f131e8c6c2",
  "video_ready": true,
  "video_player_data": {
    "cloudflare_stream_id": "73cb888469576ace114104f131e8c6c2",
    "player_url": "https://iframe.videodelivery.net/73cb888469576ace114104f131e8c6c2?controls=true&autoplay=false&muted=false&loop=false&width=100%&height=100%",
    "thumbnail_url": "https://videodelivery.net/73cb888469576ace114104f131e8c6c2/thumbnails/thumbnail.jpg?width=640&height=360&fit=scale-down",
    "duration": null,
    "formatted_duration": null,
    "status": "ready",
    "ready": true,
    "preview_url": "https://videodelivery.net/73cb888469576ace114104f131e8c6c2/manifest/video.m3u8",
    "download_url": "https://videodelivery.net/73cb888469576ace114104f131e8c6c2/manifest/video.m3u8"
  }
}
```

### **3. Video Player Implementation**

**Option A: Use Cloudflare Player URL (Recommended)**
```javascript
// For iframe embedding
const VideoPlayer = ({ lesson }) => {
  if (!lesson.video_ready || !lesson.video_player_data?.player_url) {
    return <div>Video not ready</div>;
  }

  return (
    <iframe
      src={lesson.video_player_data.player_url}
      width="100%"
      height="400"
      frameBorder="0"
      allowFullScreen
    />
  );
};
```

**Option B: Use Cloudflare Player SDK**
```javascript
// For custom player implementation
import { Player } from '@cloudflare/stream-react';

const VideoPlayer = ({ lesson }) => {
  if (!lesson.video_ready || !lesson.cloudflare_stream_id) {
    return <div>Video not ready</div>;
  }

  return (
    <Player
      src={lesson.cloudflare_stream_id}
      controls
      responsive
      fluid
    />
  );
};
```

### **4. Thumbnail Display**

```javascript
const VideoThumbnail = ({ lesson }) => {
  if (!lesson.video_player_data?.thumbnail_url) {
    return <div>No thumbnail available</div>;
  }

  return (
    <img
      src={lesson.video_player_data.thumbnail_url}
      alt={lesson.title}
      className="video-thumbnail"
    />
  );
};
```

---

## 🧪 **Testing Checklist**

### **API Testing**
- [ ] `GET /api/v1/chapters/{id}/lessons` returns video data
- [ ] `video_ready` field is `true` for video lessons
- [ ] `video_player_data` contains all required URLs
- [ ] `cloudflare_stream_id` is a valid 32-character hex string

### **Video Player Testing**
- [ ] Videos load and play correctly
- [ ] Thumbnails display properly
- [ ] Player controls work (play, pause, volume, etc.)
- [ ] Videos work on different screen sizes
- [ ] No 404 errors for video resources

### **Error Handling**
- [ ] Graceful fallback when video is not ready
- [ ] Loading states while video loads
- [ ] Error messages for failed video loads

---

## 🔗 **API Endpoints**

### **Get Lessons with Video Data**
```
GET /api/v1/chapters/{chapter_id}/lessons
Headers: 
  X-Tenant: {tenant_slug}
  Authorization: Bearer {token}
```

### **Get Single Lesson**
```
GET /api/v1/lessons/{lesson_id}
Headers:
  X-Tenant: {tenant_slug}
  Authorization: Bearer {token}
```

---

## 📊 **Video Data Structure**

| Field | Type | Description |
|-------|------|-------------|
| `cloudflare_stream_id` | string | 32-character hex video ID |
| `video_ready` | boolean | Whether video is ready for playback |
| `video_player_data.player_url` | string | Complete iframe player URL |
| `video_player_data.thumbnail_url` | string | Video thumbnail URL |
| `video_player_data.status` | string | Video processing status |
| `video_player_data.duration` | number | Video duration in seconds |
| `video_player_data.formatted_duration` | string | Human-readable duration |

---

## 🚨 **Common Issues & Solutions**

### **Issue**: 404 errors for video resources
**Solution**: Ensure you're using the `cloudflare_stream_id` from the API response, not hardcoded values.

### **Issue**: Video not loading
**Solution**: Check that `video_ready` is `true` before attempting to load the video.

### **Issue**: Thumbnail not displaying
**Solution**: Use `video_player_data.thumbnail_url` instead of constructing URLs manually.

---

## ✅ **Success Criteria**

- [ ] No hardcoded video IDs in frontend code
- [ ] All video lessons display and play correctly
- [ ] Thumbnails load properly
- [ ] No 404 errors in browser console
- [ ] Video player responsive on all devices
- [ ] Proper loading and error states implemented

---

## 📞 **Support**

If you encounter any issues:
1. Check the browser console for errors
2. Verify the API response contains valid video data
3. Ensure you're using the correct video IDs from the API
4. Test with the provided video ID: `73cb888469576ace114104f131e8c6c2`

**Backend Status**: ✅ **READY** - All Cloudflare Stream functionality is implemented and deployed.
