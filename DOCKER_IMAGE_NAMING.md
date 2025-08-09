# Docker Image Naming Convention

## Overview

Docker image names follow a specific format that helps identify where the image is stored, who owns it, and what it contains. Understanding this convention is crucial for proper image management and deployment.

## Basic Format

```
[registry/][username/]repository-name[:tag]
```

### Components Breakdown

1. **Registry** (optional): The server where the image is stored
2. **Username** (optional): The account/organization that owns the image
3. **Repository Name** (required): The name of the specific image
4. **Tag** (optional): Version or variant identifier

## Common Patterns

### 1. Official Images (Docker Hub)
```
nginx:latest
postgres:15
redis:7.0
```
- **Registry**: Docker Hub (default)
- **Username**: Official Docker images (no username needed)
- **Repository**: `nginx`, `postgres`, `redis`
- **Tag**: `latest`, `15`, `7.0`

### 2. User Images (Docker Hub)
```
username/app-name:latest
scervera/my-api:v1.0.0
```
- **Registry**: Docker Hub (default)
- **Username**: `username`, `scervera`
- **Repository**: `app-name`, `my-api`
- **Tag**: `latest`, `v1.0.0`

### 3. Private Registry Images
```
registry.company.com/team/project:latest
registry.digitalocean.com/cervera/scervera/app:latest
```
- **Registry**: `registry.company.com`, `registry.digitalocean.com`
- **Username**: `team`, `cervera`
- **Repository**: `project`, `scervera/app`
- **Tag**: `latest`

## Your Specific Case

### Current Configuration
```yaml
# config/deploy.yml
service: curriculum_library_api
image: scervera/curriculum_library_api
registry:
  server: registry.digitalocean.com/cervera
  username: scervera
```

### How It Works
1. **Service Name**: `curriculum_library_api` (used internally by Kamal)
2. **Image Name**: `scervera/curriculum_library_api` (username/repository)
3. **Registry**: `registry.digitalocean.com/cervera` (your DigitalOcean registry)

### Final Image Path
When Kamal builds and pushes, it creates:
```
registry.digitalocean.com/cervera/scervera/curriculum_library_api:commit-hash
```

## Best Practices

### 1. Use Descriptive Names
```yaml
# Good
image: scervera/curriculum_library_api
image: scervera/user_management_service

# Avoid
image: scervera/app
image: scervera/service
```

### 2. Use Semantic Versioning
```yaml
# Good
image: scervera/curriculum_library_api:v1.2.3
image: scervera/curriculum_library_api:latest

# Avoid
image: scervera/curriculum_library_api:build-123
```

### 3. Keep Names Consistent
```yaml
# Use consistent naming across environments
image: scervera/curriculum_library_api  # Production
image: scervera/curriculum_library_api  # Staging
```

## Common Mistakes

### 1. Including Registry in Image Name
```yaml
# ❌ Wrong
image: registry.digitalocean.com/cervera/scervera/app

# ✅ Correct
image: scervera/app
registry:
  server: registry.digitalocean.com/cervera
```

### 2. Confusing Registry vs Username
```yaml
# ❌ Wrong (if cervera is your registry name)
image: cervera/app

# ✅ Correct (if scervera is your username)
image: scervera/app
```

### 3. Missing Username
```yaml
# ❌ Wrong (if you need to specify ownership)
image: app

# ✅ Correct
image: scervera/app
```

## Registry-Specific Examples

### Docker Hub
```yaml
image: username/repository
registry:
  server: docker.io  # Default, can be omitted
  username: username
```

### GitHub Container Registry
```yaml
image: username/repository
registry:
  server: ghcr.io
  username: username
```

### Google Container Registry
```yaml
image: username/repository
registry:
  server: gcr.io
  username: username
```

### Amazon ECR
```yaml
image: username/repository
registry:
  server: account-id.dkr.ecr.region.amazonaws.com
  username: AWS
```

## Kamal Configuration

### Complete Example
```yaml
service: curriculum_library_api
image: scervera/curriculum_library_api

registry:
  server: registry.digitalocean.com/cervera
  username: scervera
  password:
    - KAMAL_REGISTRY_PASSWORD
```

### How Kamal Uses This
1. **Builds** the image locally
2. **Tags** it with the full registry path
3. **Pushes** to the specified registry
4. **Deploys** using the full image path

## Troubleshooting

### Common Issues

1. **403 Forbidden**: Check registry permissions and credentials
2. **Repository not found**: Verify the image path and registry settings
3. **Authentication failed**: Ensure environment variables are set correctly

### Debug Commands
```bash
# Check Kamal configuration
bundle exec kamal config

# Verify secrets
bundle exec kamal secrets print

# Test registry access
docker login registry.digitalocean.com/cervera -u scervera -p "$KAMAL_REGISTRY_PASSWORD"
```

## Summary

- **Image name**: `username/repository` (not `registry/username/repository`)
- **Registry**: Specified separately in the `registry.server` field
- **Full path**: Automatically constructed by Kamal as `registry/username/repository:tag`
- **Consistency**: Keep naming consistent across your configuration files

Remember: The `image` parameter is just the identifier, not the full path. Kamal handles the registry prefix automatically.
