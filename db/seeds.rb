# Clear existing data
puts "Clearing existing data..."
User.destroy_all
Curriculum.destroy_all
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

# Create curricula with chapters and lessons
puts "Creating curricula with chapters and lessons..."

curricula_data = [
  {
    title: "Christian Foundation",
    description: "A comprehensive curriculum covering the fundamentals of Christian faith and practice.",
    order_index: 1,
    chapters: [
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
            description: "Learn the basics of faith and its importance in the Christian life.",
            cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2"
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
            description: "Building a consistent daily devotional practice.",
            cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2"
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
            content_type: "text", 
            order_index: 3,
            content: "Learn how to effectively share your faith with others in a loving and respectful way.",
            description: "Developing confidence in sharing your Christian faith."
          }
        ]
      }
    ]
  },
  {
    title: "Advanced Discipleship",
    description: "Deepen your relationship with Christ and grow in spiritual maturity.",
    order_index: 2,
    chapters: [
      {
        title: "Understanding God's Love",
        description: "Explore the depth and breadth of God's love and how it transforms our lives.",
        duration: "2.5 hours",
        order_index: 1,
        lessons: [
          { 
            title: "God's Unconditional Love", 
            content_type: "video", 
            order_index: 1,
            content: "Understanding that God's love is unconditional and not based on our performance.",
            description: "Experiencing the depth of God's unconditional love.",
            cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2"
          },
          { 
            title: "Loving Others", 
            content_type: "text", 
            order_index: 2,
            content: "How to love others as God loves us, including those who are difficult to love.",
            description: "Learning to love others with God's love."
          },
          { 
            title: "Forgiveness and Grace", 
            content_type: "text", 
            order_index: 3,
            content: "The power of forgiveness and extending grace to others as we have received from God.",
            description: "Understanding forgiveness and grace in relationships."
          }
        ]
      },
      {
        title: "Living with Purpose",
        description: "Discover your unique purpose and calling in God's kingdom.",
        duration: "3 hours",
        order_index: 2,
        lessons: [
          { 
            title: "Discovering Your Gifts", 
            content_type: "video", 
            order_index: 1,
            content: "Identifying and developing the spiritual gifts God has given you.",
            description: "Discovering and developing your spiritual gifts.",
            cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2"
          },
          { 
            title: "Serving Others", 
            content_type: "text", 
            order_index: 2,
            content: "How to use your gifts and talents to serve others and build God's kingdom.",
            description: "Using your gifts to serve others effectively."
          },
          { 
            title: "Stewardship", 
            content_type: "text", 
            order_index: 3,
            content: "Being a good steward of all that God has entrusted to you - time, talents, and resources.",
            description: "Understanding biblical stewardship principles."
          }
        ]
      }
    ]
  },
  {
    title: "Leadership & Ministry",
    description: "Develop leadership skills and prepare for ministry opportunities.",
    order_index: 3,
    chapters: [
      {
        title: "Spiritual Leadership",
        description: "Learn what it means to be a spiritual leader and how to lead with integrity.",
        duration: "2.5 hours",
        order_index: 1,
        lessons: [
          { 
            title: "Leading by Example", 
            content_type: "video", 
            order_index: 1,
            content: "The importance of leading by example and living a life worthy of following.",
            description: "Developing leadership through personal example.",
            cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2"
          },
          { 
            title: "Servant Leadership", 
            content_type: "text", 
            order_index: 2,
            content: "Understanding servant leadership as modeled by Jesus Christ.",
            description: "Learning to lead through service to others."
          },
          { 
            title: "Team Building", 
            content_type: "text", 
            order_index: 3,
            content: "How to build and lead effective teams in ministry and other contexts.",
            description: "Building and leading effective ministry teams."
          }
        ]
      },
      {
        title: "Ministry Skills",
        description: "Develop practical skills for effective ministry and service.",
        duration: "3 hours",
        order_index: 2,
        lessons: [
          { 
            title: "Teaching and Preaching", 
            content_type: "video", 
            order_index: 1,
            content: "Learn effective methods for teaching and preaching God's Word.",
            description: "Developing skills in teaching and preaching.",
            cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2"
          },
          { 
            title: "Counseling and Care", 
            content_type: "text", 
            order_index: 2,
            content: "How to provide biblical counseling and pastoral care to those in need.",
            description: "Providing effective counseling and care."
          },
          { 
            title: "Outreach and Evangelism", 
            content_type: "text", 
            order_index: 3,
            content: "Strategies for reaching out to others and sharing the gospel effectively.",
            description: "Developing outreach and evangelism skills."
          }
        ]
      }
    ]
  }
]

# Create the original curricula
original_curricula = []
curricula_data.each do |curriculum_data|
  curriculum = Curriculum.create!(
    title: curriculum_data[:title],
    description: curriculum_data[:description],
    order_index: curriculum_data[:order_index],
    published: true
  )
  original_curricula << curriculum
  
  puts "Created curriculum: #{curriculum.title}"
  
  curriculum_data[:chapters].each do |chapter_data|
    chapter = curriculum.chapters.create!(
      title: chapter_data[:title],
      description: chapter_data[:description],
      duration: chapter_data[:duration],
      order_index: chapter_data[:order_index],
      published: true
    )
    
    puts "  - Created chapter: #{chapter.title}"
    
    chapter_data[:lessons].each do |lesson_data|
      lesson = chapter.lessons.create!(
        title: lesson_data[:title],
        content_type: lesson_data[:content_type],
        order_index: lesson_data[:order_index],
        content: lesson_data[:content],
        description: lesson_data[:description],
        cloudflare_stream_id: lesson_data[:cloudflare_stream_id],
        published: true
      )
      puts "    - Created lesson: #{lesson.title}"
    end
  end
end

# Create additional curricula
additional_curricula_data = [
  {
    title: "Biblical Studies",
    description: "In-depth study of the Bible and its historical context.",
    order_index: 4,
    chapters: [
      {
        title: "Old Testament Survey",
        description: "Overview of the Old Testament and its key themes.",
        duration: "4 hours",
        order_index: 1,
        lessons: [
          { 
            title: "The Pentateuch", 
            content_type: "video", 
            order_index: 1,
            content: "Study of the first five books of the Bible and their significance.",
            description: "Understanding the foundational books of the Old Testament.",
            cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2"
          },
          { 
            title: "Historical Books", 
            content_type: "text", 
            order_index: 2,
            content: "Exploring the historical narrative of God's people in the Old Testament.",
            description: "Learning from the historical accounts of God's people."
          },
          { 
            title: "Wisdom Literature", 
            content_type: "text", 
            order_index: 3,
            content: "Understanding the wisdom books and their practical application.",
            description: "Applying biblical wisdom to daily life."
          }
        ]
      },
      {
        title: "New Testament Survey",
        description: "Overview of the New Testament and the life of Christ.",
        duration: "4 hours",
        order_index: 2,
        lessons: [
          { 
            title: "The Gospels", 
            content_type: "video", 
            order_index: 1,
            content: "Study of the four Gospels and the life and teachings of Jesus.",
            description: "Understanding the life and ministry of Jesus Christ.",
            cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2"
          },
          { 
            title: "Acts and the Early Church", 
            content_type: "text", 
            order_index: 2,
            content: "The growth and development of the early Christian church.",
            description: "Learning from the early church's growth and challenges."
          },
          { 
            title: "Pauline Epistles", 
            content_type: "text", 
            order_index: 3,
            content: "Study of Paul's letters and their theological significance.",
            description: "Understanding Paul's teachings and their application."
          }
        ]
      }
    ]
  },
  {
    title: "Family & Relationships",
    description: "Biblical principles for building strong families and relationships.",
    order_index: 5,
    chapters: [
      {
        title: "Marriage & Family",
        description: "God's design for marriage and family life.",
        duration: "3 hours",
        order_index: 1,
        lessons: [
          { 
            title: "Biblical Marriage", 
            content_type: "video", 
            order_index: 1,
            content: "Understanding God's design and purpose for marriage.",
            description: "Building a marriage based on biblical principles.",
            cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2"
          },
          { 
            title: "Communication in Marriage", 
            content_type: "text", 
            order_index: 2,
            content: "Effective communication strategies for married couples.",
            description: "Developing healthy communication in marriage."
          },
          { 
            title: "Parenting with Purpose", 
            content_type: "text", 
            order_index: 3,
            content: "Raising children according to biblical principles and values.",
            description: "Parenting with purpose and biblical wisdom."
          }
        ]
      },
      {
        title: "Building Healthy Relationships",
        description: "Developing strong, healthy relationships in all areas of life.",
        duration: "2.5 hours",
        order_index: 2,
        lessons: [
          { 
            title: "Friendship and Community", 
            content_type: "video", 
            order_index: 1,
            content: "Building meaningful friendships and being part of a supportive community.",
            description: "Developing deep, meaningful friendships.",
            cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2"
          },
          { 
            title: "Conflict Resolution", 
            content_type: "text", 
            order_index: 2,
            content: "Biblical approaches to resolving conflicts and maintaining peace.",
            description: "Resolving conflicts in a biblical and healthy way."
          },
          { 
            title: "Boundaries and Self-Care", 
            content_type: "text", 
            order_index: 3,
            content: "Setting healthy boundaries and practicing self-care as a Christian.",
            description: "Maintaining healthy boundaries and self-care practices."
          }
        ]
      }
    ]
  }
]

# Create the additional curricula
additional_curricula_data.each do |curriculum_data|
  curriculum = Curriculum.create!(
    title: curriculum_data[:title],
    description: curriculum_data[:description],
    order_index: curriculum_data[:order_index],
    published: true
  )
  
  puts "Created additional curriculum: #{curriculum.title}"
  
  curriculum_data[:chapters].each do |chapter_data|
    chapter = curriculum.chapters.create!(
      title: chapter_data[:title],
      description: chapter_data[:description],
      duration: chapter_data[:duration],
      order_index: chapter_data[:order_index],
      published: true
    )
    
    puts "  - Created chapter: #{chapter.title}"
    
    chapter_data[:lessons].each do |lesson_data|
      lesson = chapter.lessons.create!(
        title: lesson_data[:title],
        content_type: lesson_data[:content_type],
        order_index: lesson_data[:order_index],
        content: lesson_data[:content],
        description: lesson_data[:description],
        cloudflare_stream_id: lesson_data[:cloudflare_stream_id],
        published: true
      )
      puts "    - Created lesson: #{lesson.title}"
    end
  end
end

# Create Cloudflare Stream test lesson
puts "Creating Cloudflare Stream test lesson..."
test_curriculum = Curriculum.find_by(title: "Christian Foundation")
test_chapter = test_curriculum.chapters.find_by(title: "Foundation of Faith")

cloudflare_lesson = test_chapter.lessons.create!(
  title: "Cloudflare Stream Test Video",
  description: "Test lesson using Cloudflare Stream video player",
  content_type: "video",
  content: "This is a test lesson using Cloudflare Stream for video playback.",
  cloudflare_stream_id: "73cb888469576ace114104f131e8c6c2",
  published: true,
  order_index: 4
)

puts "  - Created Cloudflare Stream test lesson: #{cloudflare_lesson.title}"
puts "    Video ID: #{cloudflare_lesson.cloudflare_stream_id}"

# Try to fetch metadata from Cloudflare Stream API
if ENV['CLOUDFLARE_API_TOKEN'].present?
  puts "Fetching Cloudflare Stream metadata..."
  if cloudflare_lesson.update_cloudflare_metadata
    puts "✅ Successfully updated lesson with Cloudflare Stream metadata"
    puts "   Duration: #{cloudflare_lesson.formatted_duration}"
    puts "   Status: #{cloudflare_lesson.cloudflare_stream_status}"
    puts "   Ready for playback: #{cloudflare_lesson.video_ready_for_playback?}"
  else
    puts "⚠️  Failed to fetch Cloudflare Stream metadata (check API token)"
  end
else
  puts "⚠️  CLOUDFLARE_API_TOKEN not set - skipping metadata fetch"
  puts "   Set CLOUDFLARE_API_TOKEN environment variable to fetch video metadata"
end

# Create sample user progress ONLY for the original curricula
puts "Creating sample user progress..."
users.each_with_index do |user, index|
  # Only assign progress to the original curricula (not the additional ones)
  original_curricula.each_with_index do |curriculum, curriculum_index|
    curriculum.chapters.each_with_index do |chapter, chapter_index|
      if chapter_index <= index % 2 # Progressive completion
        progress = user.user_progress.create!(
          chapter: chapter,
          curriculum: curriculum,
          completed: true,
          completed_at: Faker::Time.between(from: 30.days.ago, to: Time.current)
        )
        
        # Complete some lessons in each chapter
        chapter.lessons.each_with_index do |lesson, lesson_index|
          if lesson_index <= index % 3 # Progressive completion
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
end

# Create sample user notes ONLY for the original curricula
puts "Creating sample user notes..."
users.each do |user|
  # Only assign notes to the original curricula
  original_curricula.sample(2).each do |curriculum|
    curriculum.chapters.sample(2).each do |chapter|
      user.user_notes.create!(
        chapter: chapter,
        curriculum: curriculum,
        content: Faker::Lorem.paragraph(sentence_count: 3)
      )
    end
  end
end

# Create sample user highlights ONLY for the original curricula
puts "Creating sample user highlights..."
users.each do |user|
  # Only assign highlights to the original curricula
  original_curricula.sample(2).each do |curriculum|
    curriculum.chapters.sample(1).each do |chapter|
      user.user_highlights.create!(
        chapter: chapter,
        curriculum: curriculum,
        highlighted_text: Faker::Lorem.sentence
      )
    end
  end
end

puts "Seed data created successfully!"
puts "Total users: #{User.count}"
puts "Total curricula: #{Curriculum.count}"
puts "Total chapters: #{Chapter.count}"
puts "Total lessons: #{Lesson.count}"
puts "Total user progress records: #{UserProgress.count}"
puts "Total lesson progress records: #{LessonProgress.count}"
puts "Total user notes: #{UserNote.count}"
puts "Total user highlights: #{UserHighlight.count}"
puts "Cloudflare Stream test lesson: #{cloudflare_lesson.id} - #{cloudflare_lesson.title}"
puts "  API endpoint: /api/v1/lessons/#{cloudflare_lesson.id}"
puts "  Player URL: #{cloudflare_lesson.cloudflare_player_url}"
puts "  Thumbnail: #{cloudflare_lesson.cloudflare_thumbnail_url}"
puts "Total video lessons with Cloudflare Stream: #{Lesson.where.not(cloudflare_stream_id: nil).count}"
