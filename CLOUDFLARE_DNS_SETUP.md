# Cloudflare DNS Integration Setup

This application automatically creates DNS records for tenant subdomains using the Cloudflare API.

## Prerequisites

1. **Cloudflare Account**: You need a Cloudflare account with the domain `cerveras.com`
2. **API Token**: You need a Cloudflare API token with DNS editing permissions

## Setup Instructions

### 1. Create Cloudflare API Token

1. Log in to your Cloudflare dashboard
2. Go to **My Profile** → **API Tokens**
3. Click **Create Token**
4. Choose **Custom token** template
5. Configure the token with these permissions:
   - **Zone** → **Zone** → **Read**
   - **Zone** → **DNS** → **Edit**
6. Set **Zone Resources** to **Include** → **Specific zone** → **cerveras.com**
7. Set **Client IP Address Filtering** to **Not restricted** (or restrict to your server IPs)
8. Click **Continue to summary** and then **Create Token**
9. **Copy the token** - you'll need it for the next step

### 2. Get Zone ID

1. In your Cloudflare dashboard, select the **cerveras.com** domain
2. Go to **Overview** tab
3. Copy the **Zone ID** (it's a 32-character string)

### 3. Configure Rails Credentials

Add the Cloudflare credentials to your Rails credentials:

```bash
# For development
EDITOR="code --wait" bin/rails credentials:edit

# For production
EDITOR="code --wait" bin/rails credentials:edit --environment production
```

Add this section to your credentials:

```yaml
cloudflare:
  api_token: your_cloudflare_api_token_here
  zone_id: your_zone_id_here
  domain: cerveras.com
```

### 4. Test the Integration

Run the test script to verify everything is working:

```bash
ruby test_cloudflare_dns.rb
```

## How It Works

### Tenant Registration Process

1. **Subdomain Validation**: When a tenant tries to register, the system checks:
   - Subdomain format (3-63 characters, alphanumeric + hyphens)
   - Reserved subdomains (www, api, admin, etc.)
   - Database conflicts (existing tenants)
   - DNS conflicts (existing DNS records)

2. **DNS Record Creation**: If validation passes:
   - Creates a CNAME record pointing to `cerveras.com`
   - Stores the DNS record ID in the tenant record
   - Handles rollback if DNS creation fails

3. **DNS Record Cleanup**: When a tenant is deleted:
   - Automatically deletes the DNS record
   - Logs errors if deletion fails

### API Endpoints

#### Subdomain Validation
```http
GET /api/v1/subdomain_validation/check?subdomain=mycompany
```

**Response:**
```json
{
  "available": true,
  "subdomain": "mycompany",
  "full_domain": "mycompany.cerveras.com"
}
```

#### Tenant Registration
```http
POST /tenant
Content-Type: application/json

{
  "tenant": {
    "name": "My Company",
    "subdomain": "mycompany"
  },
  "admin_username": "admin",
  "admin_email": "admin@mycompany.com",
  "admin_password": "password123",
  "admin_first_name": "Admin",
  "admin_last_name": "User"
}
```

## Error Handling

The system handles various error scenarios:

- **Invalid subdomain format**: Returns validation error
- **Subdomain already taken**: Returns availability error
- **DNS API errors**: Logs error and rolls back tenant creation
- **Network issues**: Retries with exponential backoff

## Security Considerations

1. **API Token Security**: Store tokens in Rails credentials, never in code
2. **Rate Limiting**: Cloudflare API has rate limits (1200 requests per 5 minutes)
3. **DNS Propagation**: DNS changes can take up to 48 hours to propagate globally
4. **Subdomain Validation**: Strict validation prevents malicious subdomains

## Troubleshooting

### Common Issues

1. **"API Token Invalid"**
   - Check token permissions
   - Verify zone access

2. **"Zone Not Found"**
   - Verify zone ID is correct
   - Check if domain is in Cloudflare

3. **"Subdomain Already Exists"**
   - Check database for existing tenants
   - Check Cloudflare DNS records

4. **"DNS Creation Failed"**
   - Check API token permissions
   - Verify network connectivity
   - Check Cloudflare API status

### Debug Commands

```bash
# Test DNS service
ruby test_cloudflare_dns.rb

# Check tenant DNS records
rails console
> Tenant.all.map { |t| [t.subdomain, t.dns_record_id] }

# Test subdomain validation
curl "http://localhost:3000/api/v1/subdomain_validation/check?subdomain=test123"
```

## Production Deployment

1. **Set Production Credentials**:
   ```bash
   EDITOR="code --wait" bin/rails credentials:edit --environment production
   ```

2. **Deploy with Kamal**:
   ```bash
   kamal deploy
   ```

3. **Verify DNS Integration**:
   ```bash
   kamal app exec --reuse "ruby test_cloudflare_dns.rb"
   ```

## Monitoring

Monitor these metrics in production:

- DNS creation success rate
- DNS deletion success rate
- API response times
- Error rates by error type

Set up alerts for:
- DNS creation failures
- High error rates
- API rate limit approaching
