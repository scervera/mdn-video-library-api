#!/usr/bin/env ruby

require_relative 'config/environment'

puts "=== Tenant Isolation Debug ==="

# Check all tenants
tenants = Tenant.all
puts "\nAll tenants:"
tenants.each do |tenant|
  puts "  - #{tenant.name} (#{tenant.slug}) - ID: #{tenant.id}"
end

# Check curricula for each tenant
puts "\nCurricula by tenant:"
tenants.each do |tenant|
  puts "\n#{tenant.name} (#{tenant.slug}):"
  curricula = tenant.curriculums
  curricula.each do |curriculum|
    puts "  - #{curriculum.title} (ID: #{curriculum.id})"
  end
end

# Check if default_scope is working
puts "\n=== Testing Default Scope ==="

# Set Current.tenant to acme1
acme1 = Tenant.find_by(slug: 'acme1')
if acme1
  puts "\nSetting Current.tenant to acme1..."
  Current.tenant = acme1
  curricula = Curriculum.all
  puts "Curricula with acme1 scope: #{curricula.count}"
  curricula.each do |curriculum|
    puts "  - #{curriculum.title} (ID: #{curriculum.id}, Tenant: #{curriculum.tenant_id})"
  end
end

# Set Current.tenant to acme2
acme2 = Tenant.find_by(slug: 'acme2')
if acme2
  puts "\nSetting Current.tenant to acme2..."
  Current.tenant = acme2
  curricula = Curriculum.all
  puts "Curricula with acme2 scope: #{curricula.count}"
  curricula.each do |curriculum|
    puts "  - #{curriculum.title} (ID: #{curriculum.id}, Tenant: #{curriculum.tenant_id})"
  end
end

puts "\n=== Debug Complete ==="
