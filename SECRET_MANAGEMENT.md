# Secret Management Strategy

This project uses a standardized approach to secret management with Kamal.

## 🔐 **Strategy Overview**

### **Local Development**
- Use `.env` file with dotenv gem
- Environment variables are loaded automatically
- `.env` file is gitignored for security

### **Production**
- Use Kamal secrets that reference environment variables
- Environment variables are set on your local machine
- Kamal copies these to the production server during deployment

### **No Rails Credentials**
- We don't use Rails credentials for this project
- All secrets are managed through environment variables

## 📋 **Required Environment Variables**

### **Local Development Setup**

1. **Set environment variables on your local machine:**
```bash
export CLOUDFLARE_DNS_API_TOKEN="your_dns_api_token_here"
export CLOUDFLARE_ZONE_ID="your_zone_id_here"
export CLOUDFLARE_STREAM_API_TOKEN="your_stream_api_token_here"
export CLOUDFLARE_STREAM_ACCOUNT_ID="your_stream_account_id_here"
export KAMAL_REGISTRY_PASSWORD="your_digitalocean_access_token_here"
export DATABASE_PASSWORD="your_database_password_here"
```

2. **Or use the setup script:**
```bash
./setup_cloudflare_env.sh
```

3. **Add to your shell profile (optional):**
```bash
# Add to ~/.zshrc or ~/.bash_profile
export CLOUDFLARE_DNS_API_TOKEN="your_dns_api_token_here"
export CLOUDFLARE_ZONE_ID="your_zone_id_here"
export CLOUDFLARE_STREAM_API_TOKEN="your_stream_api_token_here"
export CLOUDFLARE_STREAM_ACCOUNT_ID="your_stream_account_id_here"
export KAMAL_REGISTRY_PASSWORD="your_digitalocean_access_token_here"
export DATABASE_PASSWORD="your_database_password_here"
```

### **Production Deployment**

1. **Set secrets in Kamal:**
```bash
kamal secrets set CLOUDFLARE_DNS_API_TOKEN=your_dns_api_token
kamal secrets set CLOUDFLARE_ZONE_ID=your_zone_id
kamal secrets set CLOUDFLARE_STREAM_API_TOKEN=your_stream_api_token
kamal secrets set CLOUDFLARE_STREAM_ACCOUNT_ID=your_stream_account_id
```

2. **Deploy:**
```bash
kamal deploy
```

## 🔧 **How It Works**

### **Local Development Flow**
1. Environment variables are set on your local machine
2. `.env` file contains the same variables (for convenience)
3. Dotenv gem loads `.env` file automatically
4. Application reads from `ENV['VARIABLE_NAME']`

### **Production Flow**
1. Environment variables are set on your local machine
2. `.kamal/secrets` file references these variables: `VARIABLE_NAME=$VARIABLE_NAME`
3. `config/deploy.yml` lists the secrets to inject: `- VARIABLE_NAME`
4. Kamal copies the environment variables to the production server
5. Application reads from `ENV['VARIABLE_NAME']`

## 📁 **File Structure**

```
├── .env                          # Local development (gitignored)
├── .kamal/
│   └── secrets                   # Production secrets (references ENV vars)
├── config/
│   ├── deploy.yml               # Lists secrets to inject
│   └── cloudflare.yml           # Reads from ENV vars
└── app/services/
    ├── cloudflare_dns_service.rb    # Uses config_for(:cloudflare)
    └── cloudflare_stream_service.rb # Uses config_for(:cloudflare)
```

## 🚀 **Getting Started**

1. **Set up local environment variables:**
```bash
./setup_cloudflare_env.sh
```

2. **Test locally:**
```bash
ruby test_cloudflare_config.rb
```

3. **Deploy to production:**
```bash
kamal deploy
```

## 🔍 **Troubleshooting**

### **"API token not configured" error**
- Check that environment variables are set: `echo $CLOUDFLARE_DNS_API_TOKEN`
- Verify `.env` file exists and contains the variables
- Restart your Rails server after setting variables

### **Production deployment fails**
- Verify environment variables are set locally: `env | grep CLOUDFLARE`
- Check Kamal secrets: `kamal secrets list`
- Ensure `.kamal/secrets` file references the correct variables

### **"Secret not found" error**
- Run `kamal secrets set VARIABLE_NAME=value` for missing secrets
- Check that variable is listed in `config/deploy.yml`
- Verify variable is referenced in `.kamal/secrets`
