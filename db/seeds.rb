# Clear existing data
puts "Clearing existing data..."
User.destroy_all
Tenant.destroy_all
Curriculum.destroy_all
Chapter.destroy_all
Lesson.destroy_all
LessonModule.destroy_all

# Create tenants
puts "Creating tenants..."
tenant1 = Tenant.create!(
  name: "Acme Corporation 1",
  slug: "acme1",
  domain: nil,
  branding_settings: {
    primary_color: "#3B82F6",
    secondary_color: "#1E40AF",
    logo_url: "https://example.com/acme1-logo.png"
  }
)

tenant2 = Tenant.create!(
  name: "Acme Corporation 2", 
  slug: "acme2",
  domain: nil,
  branding_settings: {
    primary_color: "#10B981",
    secondary_color: "#059669",
    logo_url: "https://example.com/acme2-logo.png"
  }
)

tenant3 = Tenant.create!(
  name: "Acme Corporation 3",
  slug: "acme3", 
  domain: nil,
  branding_settings: {
    primary_color: "#F59E0B",
    secondary_color: "#D97706",
    logo_url: "https://example.com/acme3-logo.png"
  }
)

# Create users for acme1
puts "Creating users for acme1..."
Current.tenant = tenant1

demo_acme1 = User.create!(
  username: "demo_acme1",
  email: "demo@acme1.com",
  password: "password",
  password_confirmation: "password",
  first_name: "Demo",
  last_name: "Acme1",
  role: "user",
  active: true
)

admin_acme1 = User.create!(
  username: "admin_acme1",
  email: "admin@acme1.com",
  password: "password",
  password_confirmation: "password",
  first_name: "Admin",
  last_name: "Acme1",
  role: "admin",
  active: true
)

# Create users for acme2
puts "Creating users for acme2..."
Current.tenant = tenant2

demo_acme2 = User.create!(
  username: "demo_acme2",
  email: "demo@acme2.com",
  password: "password",
  password_confirmation: "password",
  first_name: "Demo",
  last_name: "Acme2",
  role: "user",
  active: true
)

admin_acme2 = User.create!(
  username: "admin_acme2",
  email: "admin@acme2.com",
  password: "password",
  password_confirmation: "password",
  first_name: "Admin",
  last_name: "Acme2",
  role: "admin",
  active: true
)

# Create users for acme3
puts "Creating users for acme3..."
Current.tenant = tenant3

demo_acme3 = User.create!(
  username: "demo_acme3",
  email: "demo@acme3.com",
  password: "password",
  password_confirmation: "password",
  first_name: "Demo",
  last_name: "Acme3",
  role: "user",
  active: true
)

admin_acme3 = User.create!(
  username: "admin_acme3",
  email: "admin@acme3.com",
  password: "password",
  password_confirmation: "password",
  first_name: "Admin",
  last_name: "Acme3",
  role: "admin",
  active: true
)

# Create curriculum for acme1
puts "Creating curriculum for acme1..."
Current.tenant = tenant1
curriculum = Curriculum.create!(
  title: "Web Development Fundamentals",
  description: "Learn the basics of web development with HTML, CSS, and JavaScript",
  order_index: 1,
  published: true
)

# Create chapters
puts "Creating chapters..."
chapter1 = curriculum.chapters.create!(
  title: "Introduction to HTML",
  description: "Learn the fundamentals of HTML markup",
  order_index: 1,
  published: true
)

chapter2 = curriculum.chapters.create!(
  title: "CSS Styling",
  description: "Style your HTML with CSS",
  order_index: 2,
  published: true
)

# Create lessons (without modules)
puts "Creating lessons..."

# Lesson 1: HTML Basics
lesson1 = chapter1.lessons.create!(
  title: "HTML Structure and Elements",
  description: "Learn about HTML document structure and basic elements",
  order_index: 1,
  published: true
)

# Lesson 2: CSS Introduction
lesson2 = chapter1.lessons.create!(
  title: "Introduction to CSS",
  description: "Learn how to style HTML elements with CSS",
  order_index: 2,
  published: true
)

# Lesson 3: JavaScript Basics
lesson3 = chapter2.lessons.create!(
  title: "JavaScript Fundamentals",
  description: "Learn the basics of JavaScript programming",
  order_index: 1,
  published: true
)

puts "Seeding completed successfully!"
puts "Created:"
puts "  - 3 Tenants (acme1, acme2, acme3)"
puts "  - 6 Users (demo and admin for each tenant)"
puts "  - 1 Curriculum (Web Development Fundamentals) for acme1"
puts "  - 2 Chapters (HTML, CSS)"
puts "  - 3 Lessons (no modules - will be created via frontend)"
puts ""
puts "Tenant 1 (acme1) credentials:"
puts "  Demo user: demo@acme1.com / password"
puts "  Admin user: admin@acme1.com / password"
puts ""
puts "Tenant 2 (acme2) credentials:"
puts "  Demo user: demo@acme2.com / password"
puts "  Admin user: admin@acme2.com / password"
puts ""
puts "Tenant 3 (acme3) credentials:"
puts "  Demo user: demo@acme3.com / password"
puts "  Admin user: admin@acme3.com / password"
