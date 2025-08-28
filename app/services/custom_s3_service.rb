class CustomS3Service < ActiveStorage::Service::S3Service
  def initialize(**options)
    # Explicitly configure the AWS SDK client to avoid endpoint resolution issues
    client_options = {
      access_key_id: options[:access_key_id],
      secret_access_key: options[:secret_access_key],
      region: options[:region] || 'us-east-1',
      force_path_style: options[:force_path_style] || false
    }
    
    # Only add endpoint if it's explicitly provided and not the default S3 endpoint
    if options[:endpoint] && options[:endpoint] != 'https://s3.amazonaws.com'
      client_options[:endpoint] = options[:endpoint]
    end
    
    @client = Aws::S3::Client.new(client_options)
    @bucket = options[:bucket]
    @public = options[:public] || false
  end
end
