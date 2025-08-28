# Active Storage Setup with S3-Compatible Providers

This document explains how to set up Active Storage with S3-compatible storage providers like Cloudflare R2, AWS S3, DigitalOcean Spaces, and others.

## Overview

We provide two setup scripts:
1. **`setup_s3_storage.sh`** - Vendor-neutral script for any S3-compatible provider
2. **`setup_cloudflare_r2.sh`** - Cloudflare R2 specific script that maps to the vendor-neutral script

## Quick Start: Cloudflare R2

### Option 1: Interactive Setup (Recommended)

Simply run the script and it will prompt you for all required values:

```bash
./setup_cloudflare_r2.sh
```

The script will:
- Prompt for your Cloudflare R2 credentials
- Show a summary of your configuration
- Ask for confirmation before proceeding
- Make the environment variables permanent

### Option 2: Pre-set Environment Variables

If you prefer to set the variables first:

```bash
export CLOUDFLARE_R2_ACCESS_KEY='your-r2-access-key'
export CLOUDFLARE_R2_SECRET_KEY='your-r2-secret-key'
export CLOUDFLARE_R2_BUCKET='your-bucket-name'
export CLOUDFLARE_ACCOUNT_ID='your-account-id'

./setup_cloudflare_r2.sh
```

**Note**: The script will automatically make these environment variables permanent by adding them to your shell configuration file (`.zshrc`, `.bashrc`, etc.). This means you won't need to export them again in future terminal sessions.

### 3. Complete Setup

```bash
# Run database migrations
rails db:migrate

# Add to your .env file for development
echo "RAILS_STORAGE_SERVICE=s3" >> .env
```

## Quick Start: Other S3-Compatible Providers

### 1. Set Environment Variables

```bash
export S3_ACCESS_KEY_ID='your-access-key'
export S3_SECRET_ACCESS_KEY='your-secret-key'
export S3_BUCKET='your-bucket-name'
export S3_REGION='your-region'
export S3_ENDPOINT='your-endpoint-url'
export S3_FORCE_PATH_STYLE='false'  # or 'true' for some providers
```

### 2. Run the Setup Script

```bash
./setup_s3_storage.sh
```

## Provider-Specific Examples

### Cloudflare R2

```bash
export CLOUDFLARE_R2_ACCESS_KEY='your-r2-access-key'
export CLOUDFLARE_R2_SECRET_KEY='your-r2-secret-key'
export CLOUDFLARE_R2_BUCKET='your-bucket-name'
export CLOUDFLARE_ACCOUNT_ID='your-account-id'
export CLOUDFLARE_R2_REGION='auto'  # optional, defaults to 'auto'

./setup_cloudflare_r2.sh
```

### AWS S3

```bash
export S3_ACCESS_KEY_ID='your-aws-access-key'
export S3_SECRET_ACCESS_KEY='your-aws-secret-key'
export S3_BUCKET='your-bucket-name'
export S3_REGION='us-east-1'
export S3_ENDPOINT='https://s3.amazonaws.com'
export S3_FORCE_PATH_STYLE='false'

./setup_s3_storage.sh
```

### DigitalOcean Spaces

```bash
export S3_ACCESS_KEY_ID='your-spaces-access-key'
export S3_SECRET_ACCESS_KEY='your-spaces-secret-key'
export S3_BUCKET='your-bucket-name'
export S3_REGION='nyc3'
export S3_ENDPOINT='https://nyc3.digitaloceanspaces.com'
export S3_FORCE_PATH_STYLE='false'

./setup_s3_storage.sh
```

### MinIO (Self-hosted)

```bash
export S3_ACCESS_KEY_ID='your-minio-access-key'
export S3_SECRET_ACCESS_KEY='your-minio-secret-key'
export S3_BUCKET='your-bucket-name'
export S3_REGION='us-east-1'
export S3_ENDPOINT='http://localhost:9000'
export S3_FORCE_PATH_STYLE='true'

./setup_s3_storage.sh
```

## Script Options

Both scripts support the following options:

```bash
# Show help
./setup_s3_storage.sh --help
./setup_cloudflare_r2.sh --help

# Skip connection testing
./setup_s3_storage.sh --skip-test
./setup_cloudflare_r2.sh --skip-test

# Skip Kamal secrets setup
./setup_s3_storage.sh --skip-kamal
./setup_cloudflare_r2.sh --skip-kamal

# Skip making environment variables permanent (R2 script only)
./setup_cloudflare_r2.sh --skip-permanent

# Combine options
./setup_s3_storage.sh --skip-test --skip-kamal
./setup_cloudflare_r2.sh --skip-test --skip-kamal --skip-permanent
```

## What the Scripts Do

### 1. Environment Setup
- Validates required environment variables
- Adds S3 configuration to `.env` file
- Maps Cloudflare R2 variables to S3 format (R2 script only)
- Makes environment variables permanent in shell config (R2 script only)

### 2. Rails Configuration
- Updates `config/storage.yml` with S3 configuration
- Updates `config/application.rb` with Active Storage service configuration
- Adds `aws-sdk-s3` gem to `Gemfile`

### 3. Database Setup
- Creates Active Storage migration
- Sets up Kamal secrets for deployment

### 4. Testing
- Tests S3 connection
- Uploads and deletes a test file
- Validates bucket access

## Manual Setup (Alternative)

If you prefer to set up manually or the scripts don't work for your environment:

### 1. Add AWS SDK to Gemfile

```ruby
# Gemfile
gem 'aws-sdk-s3', require: false
```

### 2. Configure storage.yml

```yaml
# config/storage.yml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>

test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

s3:
  service: S3
  access_key_id: <%= ENV['S3_ACCESS_KEY_ID'] %>
  secret_access_key: <%= ENV['S3_SECRET_ACCESS_KEY'] %>
  region: <%= ENV['S3_REGION'] %>
  bucket: <%= ENV['S3_BUCKET'] %>
  endpoint: <%= ENV['S3_ENDPOINT'] %>
  force_path_style: <%= ENV['S3_FORCE_PATH_STYLE'] == 'true' %>
  public: true
  url_options:
    virtual_host: true
```

### 3. Configure application.rb

```ruby
# config/application.rb
config.active_storage.service = ENV.fetch("RAILS_STORAGE_SERVICE", "local")
```

### 4. Install Active Storage

```bash
rails active_storage:install
rails db:migrate
```

## Using Active Storage in Your Models

### Basic File Attachment

```ruby
class User < ApplicationRecord
  has_one_attached :avatar
end
```

### Multiple File Attachments

```ruby
class Lesson < ApplicationRecord
  has_many_attached :documents
end
```

### File Validation

```ruby
class User < ApplicationRecord
  has_one_attached :avatar
  
  validates :avatar, content_type: ['image/png', 'image/jpeg', 'image/gif'],
                     size: { less_than: 5.megabytes }
end
```

## Environment Configuration

### Development

```bash
# .env
RAILS_STORAGE_SERVICE=s3
```

### Production

The scripts automatically set up Kamal secrets for production deployment.

## Troubleshooting

### Common Issues

1. **"Access Denied" errors**
   - Check your access keys and permissions
   - Verify bucket name and region
   - Ensure bucket exists and is accessible

2. **"Endpoint" errors**
   - Verify the endpoint URL format
   - Check if `force_path_style` should be `true` or `false`

3. **"Region" errors**
   - Use `auto` for Cloudflare R2
   - Use appropriate region for other providers

4. **Connection timeouts**
   - Check network connectivity
   - Verify endpoint URL is correct
   - Check firewall settings

### Testing Connection

You can test the S3 connection manually:

```ruby
# Rails console
require 'aws-sdk-s3'

s3_client = Aws::S3::Client.new(
  access_key_id: ENV['S3_ACCESS_KEY_ID'],
  secret_access_key: ENV['S3_SECRET_ACCESS_KEY'],
  region: ENV['S3_REGION'],
  endpoint: ENV['S3_ENDPOINT'],
  force_path_style: ENV['S3_FORCE_PATH_STYLE'] == 'true'
)

# Test bucket access
s3_client.head_bucket(bucket: ENV['S3_BUCKET'])
puts "Connection successful!"
```

## Security Considerations

1. **Never commit secrets to version control**
2. **Use environment variables for all sensitive data**
3. **Set appropriate bucket permissions**
4. **Consider using IAM roles in production**
5. **Enable bucket versioning for important data**
6. **Set up bucket lifecycle policies**

## Migration from Local Storage

If you're migrating from local storage to S3:

1. **Backup existing files**
2. **Run the setup scripts**
3. **Update environment to use S3**
4. **Test file uploads/downloads**
5. **Migrate existing files (if needed)**

```bash
# Migrate existing files (optional)
rails active_storage:update
```

## Support

For issues with:
- **Scripts**: Check the script help (`--help`)
- **Rails Active Storage**: See [Rails Active Storage Guide](https://guides.rubyonrails.org/active_storage_overview.html)
- **AWS SDK**: See [AWS SDK Documentation](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3.html)
- **Cloudflare R2**: See [Cloudflare R2 Documentation](https://developers.cloudflare.com/r2/)
