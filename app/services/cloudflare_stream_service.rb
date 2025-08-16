class CloudflareStreamService
  include HTTParty
  
  # Cloudflare Stream API base URL
  base_uri 'https://api.cloudflare.com/client/v4/stream'
  
  # Default headers for API requests
  headers 'Authorization' => "Bearer #{ENV['CLOUDFLARE_API_TOKEN']}",
          'Content-Type' => 'application/json'
  
  class << self
    
    # Get video metadata from Cloudflare Stream
    def get_video_metadata(video_id)
      response = get("/#{video_id}")
      
      if response.success?
        data = response.parsed_response['result']
        {
          id: data['uid'],
          title: data['meta']['name'],
          duration: data['duration'],
          thumbnail: data['thumbnail'],
          status: data['status']['state'],
          preview: data['preview'],
          created_at: data['created'],
          modified_at: data['modified']
        }
      else
        Rails.logger.error "Failed to fetch Cloudflare Stream video #{video_id}: #{response.body}"
        nil
      end
    rescue => e
      Rails.logger.error "Error fetching Cloudflare Stream video #{video_id}: #{e.message}"
      nil
    end
    
    # Generate Cloudflare Player embed URL
    def player_url(video_id, options = {})
      base_url = "https://iframe.videodelivery.net/#{video_id}"
      
      # Default player options
      default_options = {
        autoplay: false,
        controls: true,
        loop: false,
        muted: false,
        preload: 'metadata',
        poster: nil,
        width: '100%',
        height: '100%'
      }
      
      # Merge with provided options
      player_options = default_options.merge(options)
      
      # Build query parameters
      query_params = player_options.compact.map { |k, v| "#{k}=#{v}" }.join('&')
      
      # Return URL with query parameters if any
      query_params.empty? ? base_url : "#{base_url}?#{query_params}"
    end
    
    # Generate Cloudflare Player iframe HTML
    def player_iframe(video_id, options = {})
      url = player_url(video_id, options)
      
      # Default iframe attributes
      default_attrs = {
        src: url,
        width: '100%',
        height: '400',
        frameborder: '0',
        allowfullscreen: true,
        allow: 'autoplay; fullscreen'
      }
      
      # Merge with provided attributes
      iframe_attrs = default_attrs.merge(options)
      
      # Build iframe HTML
      attrs_html = iframe_attrs.map { |k, v| "#{k}=\"#{v}\"" }.join(' ')
      "<iframe #{attrs_html}></iframe>"
    end
    
    # Update lesson with Cloudflare Stream metadata
    def update_lesson_with_stream_data(lesson, video_id)
      metadata = get_video_metadata(video_id)
      
      if metadata
        lesson.update!(
          cloudflare_stream_id: video_id,
          cloudflare_stream_thumbnail: metadata[:thumbnail],
          cloudflare_stream_duration: metadata[:duration],
          cloudflare_stream_status: metadata[:status]
        )
        
        Rails.logger.info "Updated lesson #{lesson.id} with Cloudflare Stream data for video #{video_id}"
        true
      else
        Rails.logger.error "Failed to update lesson #{lesson.id} with Cloudflare Stream data for video #{video_id}"
        false
      end
    end
    
    # Check if video is ready for playback
    def video_ready?(video_id)
      metadata = get_video_metadata(video_id)
      metadata && metadata[:status] == 'ready'
    end
    
    # Get video thumbnail URL
    def thumbnail_url(video_id, options = {})
      base_url = "https://videodelivery.net/#{video_id}/thumbnails"
      
      # Default thumbnail options
      default_options = {
        width: 640,
        height: 360,
        fit: 'scale-down'
      }
      
      # Merge with provided options
      thumbnail_options = default_options.merge(options)
      
      # Build query parameters
      query_params = thumbnail_options.map { |k, v| "#{k}=#{v}" }.join('&')
      
      "#{base_url}?#{query_params}"
    end
    
    # Get video preview URL (for download/streaming)
    def preview_url(video_id)
      "https://videodelivery.net/#{video_id}/manifest/video.m3u8"
    end
    
    # Get video download URL
    def download_url(video_id, quality = '720p')
      "https://videodelivery.net/#{video_id}/downloads/default.mp4"
    end
    
    # Validate Cloudflare Stream video ID format
    def valid_video_id?(video_id)
      # Cloudflare Stream video IDs are 32 character hexadecimal strings
      video_id.present? && video_id.match?(/^[a-f0-9]{32}$/)
    end
    
    # Get video analytics (if available)
    def get_video_analytics(video_id)
      response = get("/#{video_id}/analytics")
      
      if response.success?
        response.parsed_response['result']
      else
        Rails.logger.error "Failed to fetch analytics for video #{video_id}: #{response.body}"
        nil
      end
    rescue => e
      Rails.logger.error "Error fetching analytics for video #{video_id}: #{e.message}"
      nil
    end
  end
end
