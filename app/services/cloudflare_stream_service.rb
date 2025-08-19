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
