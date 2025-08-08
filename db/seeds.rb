# Clear existing data
puts "Clearing existing data..."
User.destroy_all
Chapter.destroy_all
Lesson.destroy_all
UserProgress.destroy_all
LessonProgress.destroy_all
UserNote.destroy_all
UserHighlight.destroy_all

# Create sample users
puts "Creating sample users..."
users = []

# Create demo user
demo_user = User.create!(
  username: 'demo',
  email: 'demo@example.com',
  password: 'password',
  password_confirmation: 'password',
  first_name: 'Demo',
  last_name: 'User',
  active: true
)
users << demo_user
puts "Created user: #{demo_user.full_name} (#{demo_user.username})"

# Create faker users
5.times do |i|
  user = User.create!(
    username: Faker::Internet.unique.username,
    email: Faker::Internet.unique.email,
    password: 'password123',
    password_confirmation: 'password123',
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    active: true
  )
  users << user
  puts "Created user: #{user.full_name} (#{user.username})"
end

# Create sample chapters and lessons
puts "Creating chapters and lessons..."

chapters_data = [
  {
    title: "Foundation of Faith",
    description: "Understanding the core principles of Christian faith and building a strong spiritual foundation.",
    duration: "2 hours",
    order_index: 1,
    lessons: [
      { 
        title: "Introduction to Faith", 
        content_type: "video", 
        order_index: 1,
        content: "In this lesson, we explore what faith means and how it forms the foundation of our Christian walk.",
        description: "Learn the basics of faith and its importance in the Christian life."
      },
      { 
        title: "The Bible as Foundation", 
        content_type: "text", 
        order_index: 2,
        content: "The Bible is our primary source of truth and guidance. We'll explore how to study and apply its teachings.",
        description: "Understanding the Bible as the foundation of our faith."
      },
      { 
        title: "Prayer Basics", 
        content_type: "text", 
        order_index: 3,
        content: "Prayer is our direct line of communication with God. Learn the fundamentals of effective prayer.",
        description: "Mastering the basics of prayer and communication with God."
      }
    ]
  },
  {
    title: "Walking with Christ",
    description: "Practical steps for living a Christ-centered life in today's world.",
    duration: "3 hours",
    order_index: 2,
    lessons: [
      { 
        title: "Daily Devotions", 
        content_type: "video", 
        order_index: 1,
        content: "Establishing a daily routine of Bible study and prayer to grow closer to God.",
        description: "Building a consistent daily devotional practice."
      },
      { 
        title: "Fellowship and Community", 
        content_type: "text", 
        order_index: 2,
        content: "The importance of being part of a Christian community and building relationships with other believers.",
        description: "Understanding the value of Christian fellowship."
      },
      { 
        title: "Sharing Your Faith", 
        content_type: "video", 
        order_index: 3,
        content: "Learn how to effectively share your faith with others in a loving and respectful way.",
        description: "Practical approaches to evangelism and witnessing."
      },
      { 
        title: "Spiritual Disciplines", 
        content_type: "text", 
        order_index: 4,
        content: "Explore various spiritual disciplines including fasting, meditation, and service to others.",
        description: "Developing spiritual disciplines for growth."
      }
    ]
  },
  {
    title: "Understanding God's Love",
    description: "Deep dive into the nature of God's love and how it transforms our lives.",
    duration: "2.5 hours",
    order_index: 3,
    lessons: [
      { 
        title: "God's Unconditional Love", 
        content_type: "video", 
        order_index: 1,
        content: "Understanding that God's love is unconditional and not based on our performance or worthiness.",
        description: "Exploring the unconditional nature of God's love."
      },
      { 
        title: "Loving Others", 
        content_type: "text", 
        order_index: 2,
        content: "How God's love for us enables us to love others with the same unconditional love.",
        description: "Learning to love others as God loves us."
      },
      { 
        title: "Forgiveness and Grace", 
        content_type: "video", 
        order_index: 3,
        content: "Understanding forgiveness and grace as expressions of God's love in our lives.",
        description: "Embracing forgiveness and grace in our relationships."
      }
    ]
  },
  {
    title: "Living with Purpose",
    description: "Discovering your God-given purpose and living a life of meaning and impact.",
    duration: "3.5 hours",
    order_index: 4,
    lessons: [
      { 
        title: "Discovering Your Gifts", 
        content_type: "text", 
        order_index: 1,
        content: "Identifying and developing the spiritual gifts God has given you for His service.",
        description: "Finding and using your spiritual gifts."
      },
      { 
        title: "Serving Others", 
        content_type: "video", 
        order_index: 2,
        content: "How serving others brings fulfillment and aligns with God's purpose for our lives.",
        description: "The joy and importance of serving others."
      },
      { 
        title: "Stewardship", 
        content_type: "text", 
        order_index: 3,
        content: "Being good stewards of our time, talents, and resources for God's kingdom.",
        description: "Managing God's gifts responsibly."
      },
      { 
        title: "Making a Difference", 
        content_type: "video", 
        order_index: 4,
        content: "How to make a positive impact in your community and the world through your faith.",
        description: "Creating positive change through your faith."
      },
      { 
        title: "Legacy Building", 
        content_type: "text", 
        order_index: 5,
        content: "Building a lasting legacy that honors God and blesses future generations.",
        description: "Creating a meaningful legacy for God's glory."
      }
    ]
  },
  {
    title: "Overcoming Challenges",
    description: "Biblical wisdom for facing life's challenges with faith and resilience.",
    duration: "2 hours",
    order_index: 5,
    lessons: [
      { 
        title: "Trusting God in Trials", 
        content_type: "video", 
        order_index: 1,
        content: "How to maintain trust in God during difficult times and trials.",
        description: "Building trust in God during challenging seasons."
      },
      { 
        title: "Finding Strength in Weakness", 
        content_type: "text", 
        order_index: 2,
        content: "Understanding how God's strength is made perfect in our weakness.",
        description: "Embracing weakness as an opportunity for God's strength."
      },
      { 
        title: "Hope in Difficult Times", 
        content_type: "video", 
        order_index: 3,
        content: "Maintaining hope and joy even in the midst of life's most difficult circumstances.",
        description: "Cultivating hope and joy in challenging times."
      }
    ]
  }
]

chapters_data.each do |chapter_data|
  chapter = Chapter.create!(
    title: chapter_data[:title],
    description: chapter_data[:description],
    duration: chapter_data[:duration],
    order_index: chapter_data[:order_index],
    published: true
  )
  
  puts "Created chapter: #{chapter.title}"
  
  chapter_data[:lessons].each do |lesson_data|
    lesson = chapter.lessons.create!(
      title: lesson_data[:title],
      content_type: lesson_data[:content_type],
      order_index: lesson_data[:order_index],
      content: lesson_data[:content],
      description: lesson_data[:description],
      published: true
    )
    puts "  - Created lesson: #{lesson.title}"
  end
end

# Create sample user progress
puts "Creating sample user progress..."
users.each_with_index do |user, index|
  # Randomly complete some chapters and lessons
  Chapter.all.each_with_index do |chapter, chapter_index|
    if chapter_index <= index # Progressive completion
      progress = user.user_progress.create!(
        chapter: chapter,
        completed: true,
        completed_at: Faker::Time.between(from: 30.days.ago, to: Time.current)
      )
      
      # Complete some lessons in each chapter
      chapter.lessons.each_with_index do |lesson, lesson_index|
        if lesson_index <= index # Progressive completion
          lesson_progress = user.lesson_progress.create!(
            lesson: lesson,
            completed: true,
            completed_at: Faker::Time.between(from: 30.days.ago, to: Time.current)
          )
        end
      end
    end
  end
end

# Create sample user notes
puts "Creating sample user notes..."
users.each do |user|
  Chapter.all.sample(3).each do |chapter|
    user.user_notes.create!(
      chapter: chapter,
      content: Faker::Lorem.paragraph(sentence_count: 3)
    )
  end
end

# Create sample user highlights
puts "Creating sample user highlights..."
users.each do |user|
  Chapter.all.sample(2).each do |chapter|
    user.user_highlights.create!(
      chapter: chapter,
      highlighted_text: Faker::Lorem.sentence
    )
  end
end

puts "Seed data created successfully!"
puts "Total users: #{User.count}"
puts "Total chapters: #{Chapter.count}"
puts "Total lessons: #{Lesson.count}"
puts "Total user progress records: #{UserProgress.count}"
puts "Total lesson progress records: #{LessonProgress.count}"
puts "Total user notes: #{UserNote.count}"
puts "Total user highlights: #{UserHighlight.count}"
