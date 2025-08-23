require 'net/http'
require 'json'

class CloudflareStreamService
  include ActiveSupport::Configurable

  def initialize
    config = Rails.application.config_for(:cloudflare)
    @api_token = config[:stream_api_token]
    @account_id = config[:stream_account_id]
  end

  # Upload a video to Cloudflare Stream
  def upload_video(file_path, metadata = {})
    return { success: false, error: 'API token not configured' } unless cloudflare_configured?

    begin
      uri = URI("https://api.cloudflare.com/client/v4/accounts/#{@account_id}/stream")
      
      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Bearer #{@api_token}"
      request['Content-Type'] = 'multipart/form-data'
      
      # Add file and metadata
      request.body = build_multipart_body(file_path, metadata)
      
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end
      
      if response.code == '200'
        result = JSON.parse(response.body)
        if result['success']
          { success: true, video_id: result['result']['uid'], data: result['result'] }
        else
          { success: false, error: result['errors']&.first&.dig('message') || 'Unknown error' }
        end
      else
        { success: false, error: "HTTP #{response.code}: #{response.body}" }
      end
    rescue => e
      { success: false, error: "Upload failed: #{e.message}" }
    end
  end

  # Get video information
  def get_video(video_id)
    return { success: false, error: 'API token not configured' } unless cloudflare_configured?

    begin
      uri = URI("https://api.cloudflare.com/client/v4/accounts/#{@account_id}/stream/#{video_id}")
      
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{@api_token}"
      
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end
      
      if response.code == '200'
        result = JSON.parse(response.body)
        if result['success']
          { success: true, video: result['result'] }
        else
          { success: false, error: result['errors']&.first&.dig('message') || 'Unknown error' }
        end
      else
        { success: false, error: "HTTP #{response.code}: #{response.body}" }
      end
    rescue => e
      { success: false, error: "Get video failed: #{e.message}" }
    end
  end

  # Delete a video
  def delete_video(video_id)
    return { success: false, error: 'API token not configured' } unless cloudflare_configured?

    begin
      uri = URI("https://api.cloudflare.com/client/v4/accounts/#{@account_id}/stream/#{video_id}")
      
      request = Net::HTTP::Delete.new(uri)
      request['Authorization'] = "Bearer #{@api_token}"
      
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end
      
      if response.code == '200'
        result = JSON.parse(response.body)
        if result['success']
          { success: true }
        else
          { success: false, error: result['errors']&.first&.dig('message') || 'Unknown error' }
        end
      else
        { success: false, error: "HTTP #{response.code}: #{response.body}" }
      end
    rescue => e
      { success: false, error: "Delete video failed: #{e.message}" }
    end
  end

  # List videos with pagination
  def list_videos(page = 1, per_page = 20)
    return { success: false, error: 'API token not configured' } unless cloudflare_configured?

    begin
      uri = URI("https://api.cloudflare.com/client/v4/accounts/#{@account_id}/stream?page=#{page}&limit=#{per_page}")
      
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{@api_token}"
      
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end
      
      if response.code == '200'
        result = JSON.parse(response.body)
        if result['success']
          { success: true, videos: result['result'], pagination: result['result_info'] }
        else
          { success: false, error: result['errors']&.first&.dig('message') || 'Unknown error' }
        end
      else
        { success: false, error: "HTTP #{response.code}: #{response.body}" }
      end
    rescue => e
      { success: false, error: "List videos failed: #{e.message}" }
    end
  end

  # Get usage statistics
  def get_usage_stats
    return { success: false, error: 'API token not configured' } unless cloudflare_configured?

    begin
      uri = URI("https://api.cloudflare.com/client/v4/accounts/#{@account_id}/stream/usage")
      
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{@api_token}"
      
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end
      
      if response.code == '200'
        result = JSON.parse(response.body)
        if result['success']
          { success: true, usage: result['result'] }
        else
          { success: false, error: result['errors']&.first&.dig('message') || 'Unknown error' }
        end
      else
        { success: false, error: "HTTP #{response.code}: #{response.body}" }
      end
    rescue => e
      { success: false, error: "Get usage stats failed: #{e.message}" }
    end
  end

  # Static methods for URL generation and utility functions
  def self.player_url(video_id, options = {})
    return nil unless video_id.present?
    
    # Default options
    default_options = {
      controls: true,
      autoplay: false,
      muted: false,
      loop: false,
      width: '100%',
      height: '100%'
    }.merge(options)
    
    # Build query parameters
    query_params = default_options.map { |k, v| "#{k}=#{v}" }.join('&')
    
    "https://iframe.videodelivery.net/#{video_id}?#{query_params}"
  end

  def self.player_iframe(video_id, options = {})
    return nil unless video_id.present?
    
    player_url = player_url(video_id, options)
    return nil unless player_url
    
    width = options[:width] || '100%'
    height = options[:height] || '100%'
    
    "<iframe src=\"#{player_url}\" width=\"#{width}\" height=\"#{height}\" frameborder=\"0\" allowfullscreen></iframe>"
  end

  def self.thumbnail_url(video_id, options = {})
    return nil unless video_id.present?
    
    # Default options
    default_options = {
      width: 640,
      height: 360,
      fit: 'scale-down'
    }.merge(options)
    
    # Build query parameters
    query_params = default_options.map { |k, v| "#{k}=#{v}" }.join('&')
    
    "https://videodelivery.net/#{video_id}/thumbnails/thumbnail.jpg?#{query_params}"
  end

  def self.preview_url(video_id)
    return nil unless video_id.present?
    "https://videodelivery.net/#{video_id}/manifest/video.m3u8"
  end

  def self.download_url(video_id, quality = '720p')
    return nil unless video_id.present?
    
    # Handle demo video placeholder
    if video_id == 'demo-video-placeholder'
      return "https://videodelivery.net/73cb888469576ace114104f131e8c6c2/manifest/video.m3u8"
    end
    
    "https://videodelivery.net/#{video_id}/manifest/video.m3u8"
  end

  def self.video_ready?(video_id)
    return false unless video_id.present?
    
    # For now, assume all videos are ready
    # In a real implementation, you would check the video status via API
    true
  end

  def self.get_video_metadata(video_id)
    return nil unless video_id.present?
    
    # For now, return basic metadata
    # In a real implementation, you would fetch this from Cloudflare API
    {
      uid: video_id,
      status: 'ready',
      duration: 120, # Default duration in seconds
      width: 1920,
      height: 1080,
      size: 1024000 # Default size in bytes
    }
  end

  def self.update_lesson_with_stream_data(lesson, video_id)
    return false unless video_id.present?
    
    metadata = get_video_metadata(video_id)
    return false unless metadata
    
    lesson.update(
      cloudflare_stream_duration: metadata[:duration],
      cloudflare_stream_status: metadata[:status],
      cloudflare_stream_thumbnail: thumbnail_url(video_id)
    )
    
    true
  end

  def self.valid_video_id?(video_id)
    return false unless video_id.present?
    # Cloudflare Stream video IDs are 32-character hex strings
    video_id.match?(/\A[a-f0-9]{32}\z/)
  end

  def self.get_video_analytics(video_id)
    return nil unless video_id.present?
    
    # For now, return basic analytics
    # In a real implementation, you would fetch this from Cloudflare API
    {
      views: 0,
      play_time: 0,
      completion_rate: 0
    }
  end

  private

  def cloudflare_configured?
    @api_token.present? && @account_id.present?
  end

  def build_multipart_body(file_path, metadata)
    boundary = "----WebKitFormBoundary#{SecureRandom.hex(16)}"
    
    body = []
    
    # Add file
    body << "--#{boundary}"
    body << "Content-Disposition: form-data; name=\"file\"; filename=\"#{File.basename(file_path)}\""
    body << "Content-Type: video/mp4"
    body << ""
    body << File.read(file_path)
    
    # Add metadata
    metadata.each do |key, value|
      body << "--#{boundary}"
      body << "Content-Disposition: form-data; name=\"#{key}\""
      body << ""
      body << value.to_s
    end
    
    body << "--#{boundary}--"
    
    body.join("\r\n")
  end
end
