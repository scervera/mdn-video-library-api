# Tenant Gem Project

## **Gem Design Strategy**

### **Version 1.0: Path-Based Only (Current Focus)**
- **Primary strategy**: Path-based multitenancy with `X-Tenant` headers
- **Clean, focused implementation** without subdomain complexity
- **Extensible architecture** to support subdomain strategy later

### **Future Versions:**
- **v1.1**: Add subdomain-based strategy
- **v1.2**: Add Cloudflare DNS integration
- **v1.3**: Add custom domain support

## **Database Migration Strategy**

### **Recommendation: Gem Should Handle Migrations**

**Pros of gem-managed migrations:**
- **Consistent schema** across all applications
- **Easier onboarding** for new projects
- **Centralized tenant structure** management
- **Automatic versioning** of tenant schema changes

**Implementation approach:**
```ruby
# In the gem
class Multitenancy::InstallGenerator < Rails::Generators::Base
  def create_migrations
    generate "migration", "CreateTenants"
    generate "migration", "AddTenantToUsers"
    # etc.
  end
end
```

**Usage:**
```bash
rails generate multitenancy:install
```

## **Architecture Design for Future Extensibility**

### **Strategy Pattern for Tenant Identification**
```ruby
# Base strategy class
class Multitenancy::Strategies::Base
  def extract_tenant(request)
    raise NotImplementedError
  end
end

# Path-based strategy (v1.0)
class Multitenancy::Strategies::PathBased < Base
  def extract_tenant(request)
    # Current path-based logic
  end
end

# Subdomain-based strategy (future v1.1)
class Multitenancy::Strategies::SubdomainBased < Base
  def extract_tenant(request)
    # Future subdomain logic
  end
end
```

### **Configuration for Strategy Selection**
```ruby
Multitenancy.configure do |config|
  config.strategy = :path_based  # Will support :subdomain_based later
  config.tenant_header = 'X-Tenant'
  config.tenant_column = 'tenant_id'
  # Future: config.dns_provider = :cloudflare
end
```

## **Immediate Development Plan**

### **Phase 1: Core Gem (v1.0)**
1. **Extract current path-based logic** into gem
2. **Create flexible configuration system**
3. **Include database migrations**
4. **Comprehensive test suite**
5. **Documentation and examples**

### **Phase 2: Integration with Current App**
1. **Add gem as dependency** to current app
2. **Create compatibility layer** (no breaking changes)
3. **Test thoroughly** in current environment
4. **Gradual migration** to gem usage

### **Phase 3: New Application Integration**
1. **Install gem** in your new application
2. **Run gem migrations** to set up tenant structure
3. **Configure for path-based strategy**
4. **Test tenant isolation**

## **Key Design Decisions for Future-Proofing**

### **1. Strategy Abstraction**
- **Base strategy class** that all strategies inherit from
- **Factory pattern** for strategy instantiation
- **Configuration-driven** strategy selection

### **2. Database Schema Flexibility**
- **Configurable column names** (tenant_id, organization_id, etc.)
- **Customizable tenant model** name
- **Versioned migrations** for schema evolution

### **3. Middleware Architecture**
- **Pluggable middleware** that can be customized
- **Health check bypass** configuration
- **Error handling** strategies

### **4. Configuration Management**
- **Environment-specific** configurations
- **Runtime configuration** changes
- **Validation** of configuration options

## **Migration Strategy for Current App**

### **Non-Disruptive Approach:**
1. **Create gem** alongside current app
2. **Test gem** with current app's data
3. **Add gem as dependency** but don't use it yet
4. **Create adapter** that uses gem internally
5. **Switch over** when confident

### **Rollback Plan:**
- **Feature flags** to switch between implementations
- **Gradual migration** of components
- **Easy rollback** to current implementation

## **New Application Integration**

### **Quick Start Process:**
```bash
# Add gem to Gemfile
gem 'multitenancy'

# Install and configure
rails generate multitenancy:install
rails generate multitenancy:config

# Run migrations
rails db:migrate

# Add middleware to application.rb
config.middleware.use Multitenancy::Middleware
```

### **Minimal Configuration:**
```ruby
# config/initializers/multitenancy.rb
Multitenancy.configure do |config|
  config.strategy = :path_based
  config.tenant_header = 'X-Tenant'
end
```

## **Timeline Recommendation**

### **Week 1-2: Gem Development**
- Extract core logic into gem
- Create configuration system
- Write comprehensive tests

### **Week 3: Current App Integration**
- Add gem as dependency
- Create compatibility layer
- Test thoroughly

### **Week 4: New App Integration**
- Install gem in new application
- Configure and test
- Document lessons learned

## **Questions for Clarification**

1. **What's the new application's tech stack?** (Rails version, database, etc.)
2. **Do you want the gem to be open source, or private?**
3. **Should the gem include any UI components** (like tenant selection dropdowns)?
4. **What's your preference for gem naming?** (e.g., `multitenancy`, `rails-multitenancy`, `tenant_scope`)

## **Feasibility Assessment: High**

The current implementation is well-structured and follows Rails conventions, making it an excellent candidate for gem extraction. Here's why:

### **What's Already Gem-Ready:**
1. **TenantMiddleware** - Pure Rack middleware, easily extractable
2. **Current model** - Uses ActiveSupport::CurrentAttributes, standard Rails pattern
3. **ApplicationRecord default_scope** - Standard ActiveRecord pattern
4. **Tenant model** - Clean, focused model with good validations
5. **Database migrations** - Well-structured tenant setup

### **What Would Need Adaptation:**
1. **Configuration flexibility** - Make tenant identification strategies configurable
2. **Database schema** - Allow for different tenant column naming
3. **Routing strategies** - Support both path-based and subdomain-based approaches

## **Best Approach: Incremental Extraction**

### **Phase 1: Create the Gem (Non-Disruptive)**
1. **Create a new gem repository** alongside your current app
2. **Extract core logic** without changing your current implementation
3. **Add configuration options** to support different strategies
4. **Write comprehensive tests** for the gem
5. **Document usage patterns**

### **Phase 2: Gradual Migration**
1. **Add the gem as a dependency** to your current app
2. **Create a compatibility layer** that uses the gem internally
3. **Test thoroughly** to ensure no breaking changes
4. **Gradually replace** direct usage with gem calls

### **Phase 3: Clean Up**
1. **Remove duplicate code** from the main app
2. **Update to use gem configuration** instead of hardcoded values
3. **Optimize and refine** based on usage patterns

## **Gem Architecture Considerations**

### **Configuration-Driven Design:**
```ruby
# Example gem configuration
Multitenancy.configure do |config|
  config.strategy = :path_based  # or :subdomain_based
  config.tenant_header = 'X-Tenant'
  config.tenant_column = 'tenant_id'
  config.tenant_model = 'Tenant'
  config.tenant_slug_column = 'slug'
  config.health_check_paths = ['/up']
end
```

### **Flexible Tenant Identification:**
- **Path-based**: Extract from URL path
- **Subdomain-based**: Extract from hostname
- **Header-based**: Extract from HTTP headers
- **Custom**: Allow custom extraction logic

### **Database Schema Flexibility:**
- Support different tenant column names (`tenant_id`, `organization_id`, etc.)
- Allow custom tenant model names
- Support different slug/subdomain column names

## **Benefits of Gem Extraction**

### **For Your Current App:**
1. **No disruption** - Can be done incrementally
2. **Better testing** - Isolated, focused tests
3. **Easier maintenance** - Centralized logic
4. **Future flexibility** - Easy to add new strategies

### **For Other Applications:**
1. **Consistent implementation** across projects
2. **Shared improvements** and bug fixes
3. **Reduced development time** for new apps
4. **Standardized patterns** for your team

## **Potential Challenges**

### **Configuration Complexity:**
- Need to handle various Rails app structures
- Different database naming conventions
- Various deployment scenarios

### **Backward Compatibility:**
- Ensure existing apps continue working
- Provide migration paths for different strategies
- Handle edge cases in tenant identification

### **Testing Strategy:**
- Need comprehensive test suite for gem
- Integration tests with different Rails versions
- Real-world usage scenarios

## **Recommended Approach**

### **Start Small:**
1. **Extract the middleware first** - It's the most self-contained
2. **Add the Current model** - Simple ActiveSupport extension
3. **Create the base configuration** - Minimal but flexible
4. **Add the ApplicationRecord concern** - Most complex part

### **Version Strategy:**
- **v0.1.0**: Basic path-based multitenancy
- **v0.2.0**: Add subdomain support
- **v0.3.0**: Add custom strategies
- **v1.0.0**: Stable API with full documentation

### **Integration Strategy:**
- **Option A**: Replace current implementation gradually
- **Option B**: Keep both running in parallel initially
- **Option C**: Use feature flags to switch between implementations

## **Next Steps (When Ready)**

1. **Create gem skeleton** with basic structure
2. **Extract TenantMiddleware** as the first component
3. **Add configuration system** for flexibility
4. **Write comprehensive tests** before any extraction
5. **Create migration guide** for existing applications

The beauty of this approach is that you can start the gem development without touching your current working application, ensuring zero disruption while building a reusable solution for your future projects.
