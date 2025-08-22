# Clear existing data
puts "Clearing existing data..."
User.destroy_all
Curriculum.destroy_all
Chapter.destroy_all
Lesson.destroy_all
Bookmark.destroy_all
UserProgress.destroy_all
LessonProgress.destroy_all
UserNote.destroy_all
UserHighlight.destroy_all
TenantSubscription.destroy_all
BillingTier.destroy_all
Tenant.destroy_all

# Create demo tenants
puts "Creating demo tenants..."

tenants = [
  {
    name: "ACME Corporation",
    slug: "acme1",
    domain: "curriculum.cerveras.com",
    branding_settings: {
      'primary_color' => '#3B82F6',
      'secondary_color' => '#1F2937',
      'accent_color' => '#F59E0B',
      'company_name' => 'ACME Corporation'
    }
  },
  {
    name: "TechStart Inc",
    slug: "acme2",
    domain: "curriculum.cerveras.com",
    branding_settings: {
      'primary_color' => '#10B981',
      'secondary_color' => '#374151',
      'accent_color' => '#8B5CF6',
      'company_name' => 'TechStart Inc'
    }
  },
  {
    name: "Global Solutions",
    slug: "acme3",
    domain: "curriculum.cerveras.com",
    branding_settings: {
      'primary_color' => '#EF4444',
      'secondary_color' => '#111827',
      'accent_color' => '#06B6D4',
      'company_name' => 'Global Solutions'
    }
  }
]

# Define unique curricula for each tenant
tenant_curricula = {
  "acme1" => [
    {
      title: "ACME Business Fundamentals",
      description: "Essential business practices and corporate leadership for ACME Corporation employees.",
      order_index: 1
    },
    {
      title: "ACME Innovation Workshop",
      description: "Creative problem-solving and innovation techniques specific to ACME's industry.",
      order_index: 2
    }
  ],
  "acme2" => [
    {
      title: "TechStart Programming Bootcamp",
      description: "Modern programming languages and development practices for tech startups.",
      order_index: 1
    },
    {
      title: "TechStart Product Management",
      description: "Product development and management strategies for technology companies.",
      order_index: 2
    }
  ],
  "acme3" => [
    {
      title: "Global Solutions International Business",
      description: "International business practices and global market strategies.",
      order_index: 1
    },
    {
      title: "Global Solutions Cultural Intelligence",
      description: "Cross-cultural communication and international team management.",
      order_index: 2
    }
  ]
}

# Define unique chapters for each curriculum type
curriculum_chapters = {
  "business" => [
    {
      title: "Corporate Strategy",
      description: "Strategic planning and corporate governance principles.",
      duration: "2 hours",
      order_index: 1
    },
    {
      title: "Financial Management",
      description: "Budgeting, forecasting, and financial decision-making.",
      duration: "2.5 hours",
      order_index: 2
    }
  ],
  "innovation" => [
    {
      title: "Design Thinking",
      description: "Human-centered design and creative problem-solving.",
      duration: "2 hours",
      order_index: 1
    },
    {
      title: "Innovation Management",
      description: "Managing innovation processes and fostering creativity.",
      duration: "1.5 hours",
      order_index: 2
    }
  ],
  "programming" => [
    {
      title: "Modern JavaScript",
      description: "ES6+ features and modern JavaScript development practices.",
      duration: "3 hours",
      order_index: 1
    },
    {
      title: "React Development",
      description: "Building user interfaces with React and modern frontend tools.",
      duration: "3.5 hours",
      order_index: 2
    }
  ],
  "product" => [
    {
      title: "Product Strategy",
      description: "Defining product vision and strategic planning.",
      duration: "2 hours",
      order_index: 1
    },
    {
      title: "User Experience Design",
      description: "UX principles and user-centered design methodologies.",
      duration: "2.5 hours",
      order_index: 2
    }
  ],
  "international" => [
    {
      title: "Global Market Entry",
      description: "Strategies for entering international markets.",
      duration: "2.5 hours",
      order_index: 1
    },
    {
      title: "International Trade",
      description: "Trade regulations and international business law.",
      duration: "2 hours",
      order_index: 2
    }
  ],
  "cultural" => [
    {
      title: "Cross-Cultural Communication",
      description: "Effective communication across different cultures.",
      duration: "2 hours",
      order_index: 1
    },
    {
      title: "Global Team Leadership",
      description: "Leading diverse teams across different time zones and cultures.",
      duration: "2.5 hours",
      order_index: 2
    }
  ]
}

# Define unique lessons for each chapter type
chapter_lessons = {
  "corporate_strategy" => [
    {
      title: "Strategic Planning Fundamentals",
      description: "Core principles of strategic planning and execution",
      content_type: "video",
      content: "This lesson covers the fundamental principles of strategic planning in corporate environments.",
      cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
      order_index: 1
    },
    {
      title: "Competitive Analysis",
      description: "Analyzing competitors and market positioning",
      content_type: "video",
      content: "Learn how to conduct thorough competitive analysis and position your company effectively.",
      cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
      order_index: 2
    }
  ],
  "financial_management" => [
    {
      title: "Budget Planning and Control",
      description: "Creating and managing corporate budgets",
      content_type: "video",
      content: "Essential techniques for budget planning and financial control in business.",
      cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
      order_index: 1
    },
    {
      title: "Financial Decision Making",
      description: "Making sound financial decisions for business growth",
      content_type: "video",
      content: "Strategic approaches to financial decision-making and investment analysis.",
      cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
      order_index: 2
    }
  ],
  "design_thinking" => [
    {
      title: "Empathy and User Research",
      description: "Understanding user needs through empathy and research",
      content_type: "video",
      content: "Learn how to conduct user research and develop empathy for your users.",
      cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
      order_index: 1
    },
    {
      title: "Ideation and Prototyping",
      description: "Generating ideas and creating prototypes",
      content_type: "video",
      content: "Techniques for brainstorming and rapid prototyping of innovative solutions.",
      cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
      order_index: 2
    }
  ],
  "innovation_management" => [
    {
      title: "Innovation Culture",
      description: "Building a culture that fosters innovation",
      content_type: "video",
      content: "Creating an organizational culture that encourages and supports innovation.",
      cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
      order_index: 1
    },
    {
      title: "Innovation Processes",
      description: "Structured approaches to managing innovation",
      content_type: "video",
      content: "Systematic processes for managing innovation projects and initiatives.",
      cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
      order_index: 2
    }
  ],
  "modern_javascript" => [
    {
      title: "ES6+ Features",
      description: "Modern JavaScript syntax and features",
      content_type: "video",
      content: "Explore the latest JavaScript features including arrow functions, destructuring, and modules.",
      cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
      order_index: 1
    },
    {
      title: "Async Programming",
      description: "Promises, async/await, and asynchronous programming",
      content_type: "video",
      content: "Master asynchronous programming patterns in modern JavaScript.",
      cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
      order_index: 2
    }
  ],
  "react_development" => [
    {
      title: "React Components",
      description: "Building reusable React components",
      content_type: "video",
      content: "Learn to create and manage React components effectively.",
      cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
      order_index: 1
    },
    {
      title: "State Management",
      description: "Managing state in React applications",
      content_type: "video",
      content: "Understanding state management patterns and best practices in React.",
      cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
      order_index: 2
    }
  ],
  "product_strategy" => [
    {
      title: "Product Vision",
      description: "Defining clear product vision and goals",
      content_type: "video",
      content: "How to define and communicate a compelling product vision.",
      cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
      order_index: 1
    },
    {
      title: "Product Roadmapping",
      description: "Creating and managing product roadmaps",
      content_type: "video",
      content: "Effective techniques for product roadmapping and feature prioritization.",
      cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
      order_index: 2
    }
  ],
  "ux_design" => [
    {
      title: "User Research Methods",
      description: "Conducting effective user research",
      content_type: "video",
      content: "Various methods for understanding user needs and behaviors.",
      cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
      order_index: 1
    },
    {
      title: "Wireframing and Prototyping",
      description: "Creating wireframes and interactive prototypes",
      content_type: "video",
      content: "Tools and techniques for creating effective wireframes and prototypes.",
      cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
      order_index: 2
    }
  ],
  "global_market" => [
    {
      title: "Market Entry Strategies",
      description: "Different approaches to entering global markets",
      content_type: "video",
      content: "Various strategies for entering international markets successfully.",
      cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
      order_index: 1
    },
    {
      title: "Market Research",
      description: "Conducting international market research",
      content_type: "video",
      content: "Methods for researching and understanding international markets.",
      cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
      order_index: 2
    }
  ],
  "international_trade" => [
    {
      title: "Trade Regulations",
      description: "Understanding international trade regulations",
      content_type: "video",
      content: "Key regulations and compliance requirements for international trade.",
      cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
      order_index: 1
    },
    {
      title: "Trade Agreements",
      description: "Navigating international trade agreements",
      content_type: "video",
      content: "Understanding and leveraging international trade agreements.",
      cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
      order_index: 2
    }
  ],
  "cross_cultural" => [
    {
      title: "Cultural Awareness",
      description: "Developing cultural awareness and sensitivity",
      content_type: "video",
      content: "Building awareness of different cultural norms and practices.",
      cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
      order_index: 1
    },
    {
      title: "Communication Styles",
      description: "Adapting communication for different cultures",
      content_type: "video",
      content: "Understanding and adapting to different communication styles across cultures.",
      cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
      order_index: 2
    }
  ],
  "global_leadership" => [
    {
      title: "Virtual Team Management",
      description: "Managing teams across different time zones",
      content_type: "video",
      content: "Effective strategies for managing virtual and distributed teams.",
      cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
      order_index: 1
    },
    {
      title: "Cultural Leadership",
      description: "Leading teams with diverse cultural backgrounds",
      content_type: "video",
      content: "Leadership approaches that work across different cultural contexts.",
      cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
      order_index: 2
    }
  ]
}

tenants.each do |tenant_data|
  # Temporarily disable default scope for tenant creation
  tenant = Tenant.unscoped.create!(tenant_data)
  puts "  - Created tenant: #{tenant.name} (#{tenant.slug})"

  # Create billing tiers for this tenant with Stripe price IDs
  puts "    - Creating billing tiers with Stripe integration..."
  config = BillingConfiguration.current
  
  # Define Stripe price IDs for each tier (these are the ones we created)
  stripe_price_ids = {
    'Trial' => 'price_1RyhtOJLPZyP4RVP26ANYEiZ',
    'Starter' => 'price_1RyhtOJLPZyP4RVPBGkFLBTj', 
    'Professional' => 'price_1RyhtOJLPZyP4RVPnVN9N3CK',
    'Enterprise' => 'price_1RyhtPJLPZyP4RVPFJynYL8F'
  }
  
  config.tiers.each do |tier_key, tier_data|
    billing_tier = tenant.billing_tiers.create!(
      name: tier_data['name'],
      monthly_price: tier_data['monthly_price'],
      per_user_price: tier_data['per_user_price'],
      user_limit: tier_data['user_limit'],
      features: tier_data['features'],
      stripe_price_id: stripe_price_ids[tier_data['name']]
    )
    puts "      - Created billing tier: #{billing_tier.name} (Stripe Price: #{billing_tier.stripe_price_id})"
  end

  # Create trial subscription for this tenant
  trial_tier = tenant.billing_tiers.find_by(name: 'Trial')
  if trial_tier
    subscription = tenant.tenant_subscriptions.create!(
      billing_tier: trial_tier,
      status: 'trial',
      trial_ends_at: 30.days.from_now
    )
    puts "      - Created trial subscription (expires: #{subscription.trial_ends_at.strftime('%Y-%m-%d')})"
  end

  # Create admin user for each tenant
  admin_user = tenant.users.create!(
    username: "admin_#{tenant.slug}",
    email: "admin@#{tenant.slug}.com",
    password: "password",
    password_confirmation: "password",
    first_name: "Admin",
    last_name: tenant.name.split.first,
    role: 'admin'
  )
  puts "    - Created admin user: #{admin_user.username}"

  # Create demo user for each tenant
  demo_user = tenant.users.create!(
    username: "demo_#{tenant.slug}",
    email: "demo@#{tenant.slug}.com",
    password: "password",
    password_confirmation: "password",
    first_name: "Demo",
    last_name: "User",
    role: 'user'
  )
  puts "    - Created demo user: #{demo_user.username}"

  # Create unique curricula for each tenant
  puts "    - Creating unique curricula for #{tenant.name}..."

      curricula_data = tenant_curricula[tenant.slug]
  curricula_data.each_with_index do |curriculum_data, index|
    curriculum = tenant.curriculums.create!(
      title: curriculum_data[:title],
      description: curriculum_data[:description],
      published: true,
      order_index: curriculum_data[:order_index]
    )

    puts "      - Created curriculum: #{curriculum.title}"

    # Determine which chapters to create based on curriculum type
    chapter_type = case tenant.slug
    when "acme1"
      index == 0 ? "business" : "innovation"
    when "acme2"
      index == 0 ? "programming" : "product"
    when "acme3"
      index == 0 ? "international" : "cultural"
    end

    chapters_data = curriculum_chapters[chapter_type]
    chapters_data.each do |chapter_data|
      chapter = curriculum.chapters.create!(
        title: chapter_data[:title],
        description: chapter_data[:description],
        duration: chapter_data[:duration],
        order_index: chapter_data[:order_index],
        published: true,
        tenant_id: tenant.id
      )

      puts "        - Created chapter: #{chapter.title}"

      # Determine which lessons to create based on chapter type
      lesson_type = case chapter_data[:title]
      when "Corporate Strategy"
        "corporate_strategy"
      when "Financial Management"
        "financial_management"
      when "Design Thinking"
        "design_thinking"
      when "Innovation Management"
        "innovation_management"
      when "Modern JavaScript"
        "modern_javascript"
      when "React Development"
        "react_development"
      when "Product Strategy"
        "product_strategy"
      when "User Experience Design"
        "ux_design"
      when "Global Market Entry"
        "global_market"
      when "International Trade"
        "international_trade"
      when "Cross-Cultural Communication"
        "cross_cultural"
      when "Global Team Leadership"
        "global_leadership"
      end

      lessons_data = chapter_lessons[lesson_type]
      lessons_data.each do |lesson_data|
        lesson = chapter.lessons.create!(
          title: lesson_data[:title],
          description: lesson_data[:description],
          content_type: lesson_data[:content_type],
          content: lesson_data[:content],
          cloudflare_stream_id: lesson_data[:cloudflare_stream_id],
          order_index: lesson_data[:order_index],
          published: true,
          tenant_id: tenant.id
        )
        puts "          - Created lesson: #{lesson.title}"
      end
    end
  end

  # Create some user progress for demo user
  puts "    - Creating user progress..."

  # Enroll demo user in first curriculum
  first_curriculum = tenant.curriculums.first
  first_chapter = first_curriculum.chapters.first
  user_progress = demo_user.user_progress.create!(
    curriculum: first_curriculum,
    chapter: first_chapter,
    completed: false,
    tenant_id: tenant.id
  )

  # Mark first lesson as completed
  first_lesson = first_chapter.lessons.first
  lesson_progress = demo_user.lesson_progress.create!(
    lesson: first_lesson,
    completed: true,
    completed_at: Time.current,
    tenant_id: tenant.id
  )

  # Create some notes and highlights
  puts "    - Creating notes and highlights..."

  # Create a note for the first chapter
  note = demo_user.user_notes.create!(
    chapter: first_chapter,
    curriculum: first_curriculum,
    content: "This is a great introduction to #{first_curriculum.title}. I learned a lot about the core concepts.",
    tenant_id: tenant.id
  )

  # Create a highlight for the first chapter
  highlight = demo_user.user_highlights.create!(
    chapter: first_chapter,
    curriculum: first_curriculum,
    highlighted_text: "#{first_curriculum.title} provides essential knowledge for #{tenant.name} employees.",
    tenant_id: tenant.id
  )

  # Create some bookmarks for the first lesson
  puts "    - Creating bookmarks..."

  bookmark1 = demo_user.bookmarks.create!(
    lesson: first_lesson,
    title: "Key Concept",
    notes: "Important point about #{first_lesson.title}",
    timestamp: 120.5,
    tenant_id: tenant.id
  )

  bookmark2 = demo_user.bookmarks.create!(
    lesson: first_lesson,
    title: "Review Point",
    notes: "Need to review this section later",
    timestamp: 300.0,
    tenant_id: tenant.id
  )

  puts "    - Tenant #{tenant.name} setup complete!"
  puts "      API endpoints:"
  tenant.curriculums.each do |curriculum|
    puts "        - #{curriculum.title}: /api/v1/curricula/#{curriculum.id}"
  end
  puts "        - First lesson: /api/v1/lessons/#{first_lesson.id}"
  puts "        - User progress: /api/v1/user/progress"
  puts "        - Bookmarks: /api/v1/lessons/#{first_lesson.id}/bookmarks"
  puts "        - Billing tiers: /api/v1/billing_tiers"
  puts "        - Trial status: /api/v1/trial/status"
  puts "      Login credentials:"
  puts "        - Admin: #{admin_user.username} / password"
  puts "        - Demo: #{demo_user.username} / password"
        puts "      URL: #{tenant.slug}.curriculum.cerveras.com"
  puts ""
end

puts "🎉 Multitenant setup complete with unique content and billing system!"
puts ""
puts "📋 Summary:"
puts "  - Created 3 tenants: acme1, acme2, acme3"
puts "  - Each tenant has unique curricula:"
puts "    * ACME Corporation: Business Fundamentals & Innovation Workshop"
puts "    * TechStart Inc: Programming Bootcamp & Product Management"
puts "    * Global Solutions: International Business & Cultural Intelligence"
puts "  - All video lessons use Cloudflare Stream test video"
puts "  - Demo users have progress, notes, highlights, and bookmarks"
puts "  - Each tenant has unique branding colors"
puts "  - Billing tiers created for each tenant"
puts "  - Trial subscriptions active for all tenants"
puts ""
puts "🚀 Next steps:"
puts "  1. Test tenant isolation by accessing different subdomains"
puts "  2. Verify API endpoints work with tenant context"
puts "  3. Test billing endpoints:"
puts "     - GET /api/v1/billing_tiers"
puts "     - GET /api/v1/trial/status"
puts "     - GET /api/v1/subscriptions"
puts "  4. Test branding customization"
puts "  5. Deploy to production with proper DNS setup"
