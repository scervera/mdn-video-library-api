class VideoModule < LessonModule
  # Video-specific validations
  validates :cloudflare_stream_id, presence: true, format: { with: /\A[a-f0-9]{32}\z/ }
  
  # Video-specific settings
  def self.default_settings
    {
      show_transcript: true,
      autoplay: false,
      quality: '720p',
      allow_download: true,
      show_controls: true
    }
  end
  
  # Instance methods
  def cloudflare_video?
    cloudflare_stream_id.present?
  end

  def cloudflare_player_url(options = {})
    return nil unless cloudflare_video?
    CloudflareStreamService.player_url(cloudflare_stream_id, options)
  end

  def cloudflare_player_iframe(options = {})
    return nil unless cloudflare_video?
    CloudflareStreamService.player_iframe(cloudflare_stream_id, options)
  end

  def cloudflare_thumbnail_url(options = {})
    return nil unless cloudflare_video?
    CloudflareStreamService.thumbnail_url(cloudflare_stream_id, options)
  end

  def cloudflare_preview_url
    return nil unless cloudflare_video?
    CloudflareStreamService.preview_url(cloudflare_stream_id)
  end

  def cloudflare_download_url(quality = settings['quality'] || '720p')
    return nil unless cloudflare_video?
    CloudflareStreamService.download_url(cloudflare_stream_id, quality)
  end

  def cloudflare_video_ready?
    return false unless cloudflare_video?
    CloudflareStreamService.video_ready?(cloudflare_stream_id)
  end

  def cloudflare_video_metadata
    return nil unless cloudflare_video?
    CloudflareStreamService.get_video_metadata(cloudflare_stream_id)
  end

  def update_cloudflare_metadata
    return false unless cloudflare_video?
    CloudflareStreamService.update_lesson_with_stream_data(self, cloudflare_stream_id)
  end

  # Video duration in human-readable format
  def formatted_duration
    return nil unless cloudflare_stream_duration
    
    total_seconds = cloudflare_stream_duration
    hours = total_seconds / 3600
    minutes = (total_seconds % 3600) / 60
    seconds = total_seconds % 60
    
    if hours > 0
      sprintf("%d:%02d:%02d", hours, minutes, seconds)
    else
      sprintf("%d:%02d", minutes, seconds)
    end
  end

  # Check if video is ready for playback
  def video_ready_for_playback?
    cloudflare_video? && cloudflare_stream_status == 'ready'
  end

  # Get video player data for API responses
  def video_player_data
    return nil unless cloudflare_video?
    
    {
      cloudflare_stream_id: cloudflare_stream_id,
      player_url: cloudflare_player_url,
      thumbnail_url: cloudflare_thumbnail_url,
      duration: cloudflare_stream_duration,
      formatted_duration: formatted_duration,
      status: cloudflare_stream_status,
      ready: video_ready_for_playback?,
      preview_url: cloudflare_preview_url,
      download_url: cloudflare_download_url
    }
  end
  
  # Class methods
  def self.display_name
    'Video Module'
  end
  
  def self.description
    'Embed video content with Cloudflare Stream integration'
  end
end
