namespace :cloudflare_stream do
  desc "Create a test lesson with Cloudflare Stream video"
  task create_test_lesson: :environment do
    puts "Creating Cloudflare Stream test lesson..."
    
    # Find or create a curriculum
    curriculum = Curriculum.find_or_create_by(title: "Cloudflare Stream Test Curriculum") do |c|
      c.description = "Test curriculum for Cloudflare Stream integration"
      c.published = true
      c.order_index = 1
    end
    
    # Ensure curriculum is saved
    curriculum.save! if curriculum.new_record?
    
    # Find or create a chapter
    chapter = curriculum.chapters.find_or_create_by(title: "Cloudflare Stream Test Chapter") do |ch|
      ch.description = "Test chapter for Cloudflare Stream integration"
      ch.published = true
      ch.order_index = 1
    end
    
    # Ensure chapter is saved
    chapter.save! if chapter.new_record?
    
    # Create test lesson with Cloudflare Stream video
    test_video_id = "73cb888469576ace114104f131e8c6c2"
    
    # Find existing lesson or create new one
    lesson = chapter.lessons.find_by(title: "Cloudflare Stream Test Video")
    
    if lesson.nil?
      lesson = chapter.lessons.create!(
        title: "Cloudflare Stream Test Video",
        description: "Test lesson using Cloudflare Stream video player",
        content_type: "video",
        content: "This is a test lesson using Cloudflare Stream for video playback.",
        cloudflare_stream_id: test_video_id,
        published: true,
        order_index: 1
      )
      puts "✅ Created new test lesson: #{lesson.title}"
    else
      lesson.update!(
        cloudflare_stream_id: test_video_id,
        content_type: "video",
        content: "This is a test lesson using Cloudflare Stream for video playback."
      )
      puts "✅ Updated existing test lesson: #{lesson.title}"
    end
    
    puts "   Video ID: #{lesson.cloudflare_stream_id}"
    puts "   Chapter: #{chapter.title}"
    puts "   Curriculum: #{curriculum.title}"
    
    # Try to fetch metadata from Cloudflare Stream API
    if ENV['CLOUDFLARE_API_TOKEN'].present?
      puts "\nFetching Cloudflare Stream metadata..."
      if lesson.update_cloudflare_metadata
        puts "✅ Successfully updated lesson with Cloudflare Stream metadata"
        puts "   Duration: #{lesson.formatted_duration}"
        puts "   Status: #{lesson.cloudflare_stream_status}"
        puts "   Ready for playback: #{lesson.video_ready_for_playback?}"
      else
        puts "⚠️  Failed to fetch Cloudflare Stream metadata (check API token)"
      end
    else
      puts "\n⚠️  CLOUDFLARE_API_TOKEN not set - skipping metadata fetch"
      puts "   Set CLOUDFLARE_API_TOKEN environment variable to fetch video metadata"
    end
    
    puts "\n🎥 Cloudflare Stream test lesson ready!"
    puts "   API endpoint: /api/v1/lessons/#{lesson.id}"
    puts "   Player URL: #{lesson.cloudflare_player_url}"
    puts "   Thumbnail: #{lesson.cloudflare_thumbnail_url}"
  end
end
