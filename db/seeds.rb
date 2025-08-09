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
          }
        ]
      }
    ]
  },
  {
    title: "Advanced Discipleship",
    description: "Deep dive into advanced Christian concepts and spiritual growth for mature believers.",
    order_index: 2,
    chapters: [
      {
        title: "Understanding God's Love",
        description: "Deep dive into the nature of God's love and how it transforms our lives.",
        duration: "2.5 hours",
        order_index: 1,
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
        order_index: 2,
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
          }
        ]
      }
    ]
  },
  {
    title: "Leadership & Ministry",
    description: "Training for Christian leadership and ministry roles in the church and community.",
    order_index: 3,
    chapters: [
      {
        title: "Spiritual Leadership",
        description: "Principles of effective spiritual leadership in the church and community.",
        duration: "3 hours",
        order_index: 1,
        lessons: [
          { 
            title: "Leading by Example", 
            content_type: "video", 
            order_index: 1,
            content: "How to lead others through your own spiritual example and character.",
            description: "Understanding the importance of leading by example."
          },
          { 
            title: "Servant Leadership", 
            content_type: "text", 
            order_index: 2,
            content: "Jesus' model of servant leadership and how to apply it in ministry.",
            description: "Learning to lead through service to others."
          },
          { 
            title: "Team Building", 
            content_type: "video", 
            order_index: 3,
            content: "Building and leading effective ministry teams in the church.",
            description: "Creating and managing ministry teams."
          }
        ]
      },
      {
        title: "Ministry Skills",
        description: "Practical skills for effective ministry and outreach.",
        duration: "2.5 hours",
        order_index: 2,
        lessons: [
          { 
            title: "Teaching and Preaching", 
            content_type: "text", 
            order_index: 1,
            content: "Effective methods for teaching and preaching the Word of God.",
            description: "Developing teaching and preaching skills."
          },
          { 
            title: "Counseling and Care", 
            content_type: "video", 
            order_index: 2,
            content: "Biblical counseling principles and pastoral care techniques.",
            description: "Learning to provide spiritual care and counseling."
          },
          { 
            title: "Outreach and Evangelism", 
            content_type: "text", 
            order_index: 3,
            content: "Strategies for effective outreach and evangelism in the community.",
            description: "Developing outreach and evangelism strategies."
          }
        ]
      }
    ]
  }
]

# Create the original curricula first
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
        published: true
      )
      puts "    - Created lesson: #{lesson.title}"
    end
  end
end

# Create additional curricula that won't be assigned to any users
additional_curricula_data = [
  {
    title: "Biblical Studies",
    description: "In-depth study of biblical texts, theology, and historical context for serious students of Scripture.",
    order_index: 4,
    chapters: [
      {
        title: "Old Testament Survey",
        description: "Comprehensive overview of the Old Testament books and their historical context.",
        duration: "4 hours",
        order_index: 1,
        lessons: [
          { 
            title: "The Pentateuch", 
            content_type: "video", 
            order_index: 1,
            content: "Study of the first five books of the Bible: Genesis, Exodus, Leviticus, Numbers, and Deuteronomy.",
            description: "Understanding the foundational books of the Old Testament."
          },
          { 
            title: "Historical Books", 
            content_type: "text", 
            order_index: 2,
            content: "Exploring the historical narrative from Joshua through Esther and the story of God's people.",
            description: "Journey through Israel's history and God's faithfulness."
          },
          { 
            title: "Wisdom Literature", 
            content_type: "video", 
            order_index: 3,
            content: "Study of Job, Psalms, Proverbs, Ecclesiastes, and Song of Solomon.",
            description: "Understanding biblical wisdom and poetry."
          }
        ]
      },
      {
        title: "New Testament Survey",
        description: "Comprehensive study of the New Testament and the early church.",
        duration: "4.5 hours",
        order_index: 2,
        lessons: [
          { 
            title: "The Gospels", 
            content_type: "video", 
            order_index: 1,
            content: "In-depth study of Matthew, Mark, Luke, and John and their unique perspectives on Jesus.",
            description: "Understanding the four Gospel accounts of Jesus' life and ministry."
          },
          { 
            title: "Acts and the Early Church", 
            content_type: "text", 
            order_index: 2,
            content: "The birth and growth of the early Christian church as recorded in Acts.",
            description: "Following the spread of the Gospel and the early church's development."
          },
          { 
            title: "Pauline Epistles", 
            content_type: "video", 
            order_index: 3,
            content: "Study of Paul's letters and their theological significance for the church.",
            description: "Understanding Paul's teachings and their application today."
          }
        ]
      }
    ]
  },
  {
    title: "Family & Relationships",
    description: "Biblical guidance for building strong families and healthy relationships in today's world.",
    order_index: 5,
    chapters: [
      {
        title: "Marriage & Family",
        description: "Biblical principles for building strong marriages and families.",
        duration: "3.5 hours",
        order_index: 1,
        lessons: [
          { 
            title: "Biblical Marriage", 
            content_type: "video", 
            order_index: 1,
            content: "Understanding God's design for marriage and the biblical foundation for strong relationships.",
            description: "Exploring God's plan for marriage and family life."
          },
          { 
            title: "Communication in Marriage", 
            content_type: "text", 
            order_index: 2,
            content: "Practical strategies for effective communication and conflict resolution in marriage.",
            description: "Building healthy communication patterns in marriage."
          },
          { 
            title: "Parenting with Purpose", 
            content_type: "video", 
            order_index: 3,
            content: "Biblical principles for raising children in the faith and preparing them for life.",
            description: "Understanding your role as a parent and spiritual leader."
          }
        ]
      },
      {
        title: "Building Healthy Relationships",
        description: "Developing strong, Christ-centered relationships in all areas of life.",
        duration: "3 hours",
        order_index: 2,
        lessons: [
          { 
            title: "Friendship and Community", 
            content_type: "text", 
            order_index: 1,
            content: "Building meaningful friendships and being part of a supportive Christian community.",
            description: "The importance of friendship and community in the Christian life."
          },
          { 
            title: "Conflict Resolution", 
            content_type: "video", 
            order_index: 2,
            content: "Biblical approaches to resolving conflicts and maintaining healthy relationships.",
            description: "Learning to handle conflicts in a Christ-like manner."
          },
          { 
            title: "Boundaries and Self-Care", 
            content_type: "text", 
            order_index: 3,
            content: "Setting healthy boundaries and practicing self-care while serving others.",
            description: "Balancing service to others with personal well-being."
          }
        ]
      }
    ]
  }
]

# Create the additional curricula (these won't be assigned to any users)
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
        published: true
      )
      puts "    - Created lesson: #{lesson.title}"
    end
  end
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
