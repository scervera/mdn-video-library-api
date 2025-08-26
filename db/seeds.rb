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

# Create lessons with modules
puts "Creating lessons with modules..."

# Lesson 1: HTML Basics
lesson1 = chapter1.lessons.create!(
  title: "HTML Structure and Elements",
  description: "Learn about HTML document structure and basic elements",
  order_index: 1,
  published: true
)

# Add text module to lesson 1
lesson1.add_module('TextModule', {
  title: "Introduction to HTML",
  description: "Learn what HTML is and why it's important",
  content: "<h1>What is HTML?</h1><p>HTML (HyperText Markup Language) is the standard markup language for creating web pages. It describes the structure of a web page semantically and originally included cues for the appearance of the document.</p><h2>Key Concepts</h2><ul><li>HTML uses markup to describe web page structure</li><li>Elements are the building blocks of HTML pages</li><li>Tags tell the browser how to display the content</li></ul>"
})

# Add video module to lesson 1
lesson1.add_module('VideoModule', {
  title: "HTML Basics Video",
  description: "Watch this video to understand HTML fundamentals",
  cloudflare_stream_id: "12345678901234567890123456789012"
})

# Add assessment module to lesson 1
lesson1.add_module('AssessmentModule', {
  title: "HTML Knowledge Check",
  description: "Test your understanding of HTML basics",
  settings: {
    questions: [
      {
        text: "What does HTML stand for?",
        type: "single_choice",
        options: ["HyperText Markup Language", "High Tech Modern Language", "Home Tool Markup Language"],
        correct_answer: 0,
        points: 1
      },
      {
        text: "Which tag is used for the main heading?",
        type: "single_choice",
        options: ["<p>", "<h1>", "<div>"],
        correct_answer: 1,
        points: 1
      }
    ],
    passing_score: 70
  }
})

# Lesson 2: CSS Introduction
lesson2 = chapter1.lessons.create!(
  title: "Introduction to CSS",
  description: "Learn how to style HTML elements with CSS",
  order_index: 2,
  published: true
)

# Add text module to lesson 2
lesson2.add_module('TextModule', {
  title: "CSS Fundamentals",
  description: "Understanding CSS selectors and properties",
  content: "<h1>CSS Basics</h1><p>CSS (Cascading Style Sheets) is a style sheet language used for describing the presentation of a document written in HTML.</p><h2>CSS Selectors</h2><p>CSS selectors are patterns used to select and style HTML elements:</p><ul><li><strong>Element selectors:</strong> p, h1, div</li><li><strong>Class selectors:</strong> .classname</li><li><strong>ID selectors:</strong> #idname</li></ul>"
})

# Add resources module to lesson 2
lesson2.add_module('ResourcesModule', {
  title: "CSS Resources",
  description: "Download helpful CSS resources and links",
  settings: {
    resources: [
      {
        title: "CSS Cheat Sheet",
        type: "file",
        url: "https://example.com/css-cheat-sheet.pdf",
        file_size: 512000
      },
      {
        title: "MDN CSS Documentation",
        type: "link",
        url: "https://developer.mozilla.org/en-US/docs/Web/CSS"
      },
      {
        title: "CSS Tutorial Video",
        type: "video",
        url: "https://example.com/css-tutorial.mp4"
      }
    ]
  }
})

# Add image module to lesson 2
lesson2.add_module('ImageModule', {
  title: "CSS Box Model Diagram",
  description: "Visual representation of the CSS box model",
  settings: {
    images: [
      {
        title: "CSS Box Model",
        url: "https://example.com/box-model.png",
        alt_text: "Diagram showing CSS box model with margin, border, padding, and content",
        thumbnail_url: "https://example.com/box-model-thumb.png"
      }
    ],
    layout: "single"
  }
})

# Lesson 3: JavaScript Basics
lesson3 = chapter2.lessons.create!(
  title: "JavaScript Fundamentals",
  description: "Learn the basics of JavaScript programming",
  order_index: 1,
  published: true
)

# Add text module to lesson 3
lesson3.add_module('TextModule', {
  title: "What is JavaScript?",
  description: "Introduction to JavaScript programming language",
  content: "<h1>JavaScript Overview</h1><p>JavaScript is a high-level, interpreted programming language that is one of the core technologies of the World Wide Web.</p><h2>Key Features</h2><ul><li><strong>Dynamic typing:</strong> Variables can hold different types of data</li><li><strong>Object-oriented:</strong> Supports object-oriented programming</li><li><strong>Event-driven:</strong> Responds to user interactions</li></ul>"
})

# Add video module to lesson 3
lesson3.add_module('VideoModule', {
  title: "JavaScript Tutorial",
  description: "Comprehensive JavaScript tutorial for beginners",
  cloudflare_stream_id: "abcdef1234567890abcdef1234567890"
})

# Add assessment module to lesson 3
lesson3.add_module('AssessmentModule', {
  title: "JavaScript Quiz",
  description: "Test your JavaScript knowledge",
  settings: {
    questions: [
      {
        text: "Which keyword is used to declare a variable in JavaScript?",
        type: "single_choice",
        options: ["var", "let", "const", "All of the above"],
        correct_answer: 3,
        points: 1
      },
      {
        text: "What is the result of 2 + '2' in JavaScript?",
        type: "single_choice",
        options: ["4", "22", "Error", "NaN"],
        correct_answer: 1,
        points: 1
      }
    ],
    passing_score: 80
  }
})

# Add image gallery to lesson 3
lesson3.add_module('ImageModule', {
  title: "JavaScript Code Examples",
  description: "Visual examples of JavaScript code",
  settings: {
    images: [
      {
        title: "Variables Example",
        url: "https://example.com/variables.png",
        alt_text: "JavaScript variable declaration examples",
        thumbnail_url: "https://example.com/variables-thumb.png"
      },
      {
        title: "Functions Example",
        url: "https://example.com/functions.png",
        alt_text: "JavaScript function examples",
        thumbnail_url: "https://example.com/functions-thumb.png"
      },
      {
        title: "Objects Example",
        url: "https://example.com/objects.png",
        alt_text: "JavaScript object examples",
        thumbnail_url: "https://example.com/objects-thumb.png"
      }
    ],
    layout: "gallery"
  }
})

puts "Seeding completed successfully!"
puts "Created:"
puts "  - 3 Tenants (acme1, acme2, acme3)"
puts "  - 6 Users (demo and admin for each tenant)"
puts "  - 1 Curriculum (Web Development Fundamentals) for acme1"
puts "  - 2 Chapters (HTML, CSS)"
puts "  - 3 Lessons with various module types"
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
