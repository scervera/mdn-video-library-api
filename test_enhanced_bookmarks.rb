#!/usr/bin/env ruby

# Test script for enhanced bookmarks functionality
require_relative 'config/environment'

puts "🧪 Testing Enhanced Bookmarks Functionality"
puts "=" * 50

# Find a test user and lesson
user = User.first
lesson = Lesson.first

unless user && lesson
  puts "❌ No users or lessons found. Please run seeds first."
  exit 1
end

puts "👤 Test User: #{user.email}"
puts "📚 Test Lesson: #{lesson.title}"
puts "🏢 Tenant: #{user.tenant.slug}"
puts ""

# Clean up any existing test data
Bookmark.where(user: user, lesson: lesson).destroy_all
puts "🧹 Cleaned up existing test data"
puts ""

# Test 1: Create a bookmark
puts "1️⃣ Testing Bookmark Creation..."
bookmark = Bookmark.create!(
  user: user,
  lesson: lesson,
  tenant: user.tenant,
  title: "Test Bookmark",
  notes: "This is a test bookmark",
  content_type: "bookmark",
  timestamp: 15.5,
  privacy_level: "private"
)

puts "✅ Bookmark created: #{bookmark.title} (ID: #{bookmark.id})"
puts "   Type: #{bookmark.content_type}"
puts "   Timestamp: #{bookmark.timestamp}"
puts "   Privacy: #{bookmark.privacy_level}"
puts ""

# Test 2: Create a clip
puts "2️⃣ Testing Clip Creation..."
clip = Bookmark.create!(
  user: user,
  lesson: lesson,
  tenant: user.tenant,
  title: "Test Clip",
  notes: "This is a test clip",
  content_type: "clip",
  in_sec: 10,
  out_sec: 25,
  privacy_level: "public"
)

puts "✅ Clip created: #{clip.title} (ID: #{clip.id})"
puts "   Type: #{clip.content_type}"
puts "   Duration: #{clip.duration} seconds"
puts "   Privacy: #{clip.privacy_level}"
puts ""

# Test 3: Create a note
puts "3️⃣ Testing Note Creation..."
note = Bookmark.create!(
  user: user,
  lesson: lesson,
  tenant: user.tenant,
  title: "Test Note",
  notes: "This is a test note with important information",
  content_type: "note",
  privacy_level: "shared",
  shared_with: ["user_2", "user_3"]
)

puts "✅ Note created: #{note.title} (ID: #{note.id})"
puts "   Type: #{note.content_type}"
puts "   Privacy: #{note.privacy_level}"
puts "   Shared with: #{note.shared_with}"
puts ""

# Test 4: Test access control
puts "4️⃣ Testing Access Control..."
other_user = User.where.not(id: user.id).first

if other_user
  puts "   Can owner access bookmark? #{bookmark.can_be_accessed_by?(user)}"
  puts "   Can other user access private bookmark? #{bookmark.can_be_accessed_by?(other_user)}"
  puts "   Can other user access public clip? #{clip.can_be_accessed_by?(other_user)}"
  puts "   Can other user access shared note? #{note.can_be_accessed_by?(other_user)}"
else
  puts "   No other users found for access control test"
end
puts ""

# Test 5: Test scopes
puts "5️⃣ Testing Scopes..."
puts "   Total bookmarks: #{Bookmark.count}"
puts "   Bookmarks: #{Bookmark.bookmarks.count}"
puts "   Clips: #{Bookmark.clips.count}"
puts "   Notes: #{Bookmark.notes.count}"
puts "   Public content: #{Bookmark.public_content.count}"
puts "   Shared content: #{Bookmark.shared_content.count}"
puts ""

# Test 6: Test validations
puts "6️⃣ Testing Validations..."
invalid_bookmark = Bookmark.new(
  user: user,
  lesson: lesson,
  tenant: user.tenant,
  title: "Invalid Bookmark",
  content_type: "bookmark"
  # Missing timestamp
)

puts "   Invalid bookmark valid? #{invalid_bookmark.valid?}"
puts "   Errors: #{invalid_bookmark.errors.full_messages.join(', ')}"

invalid_clip = Bookmark.new(
  user: user,
  lesson: lesson,
  tenant: user.tenant,
  title: "Invalid Clip",
  content_type: "clip",
  in_sec: 20,
  out_sec: 10  # out_sec < in_sec
)

puts "   Invalid clip valid? #{invalid_clip.valid?}"
puts "   Errors: #{invalid_clip.errors.full_messages.join(', ')}"
puts ""

# Test 7: Test helper methods
puts "7️⃣ Testing Helper Methods..."
puts "   Bookmark is_bookmark? #{bookmark.is_bookmark?}"
puts "   Clip is_clip? #{clip.is_clip?}"
puts "   Note is_note? #{note.is_note?}"
puts "   Clip duration: #{clip.duration} seconds"
puts "   Bookmark formatted timestamp: #{bookmark.formatted_timestamp}"
puts ""

puts "🎉 Enhanced Bookmarks Testing Complete!"
puts "=" * 50

# Cleanup test data
puts "🧹 Cleaning up test data..."
[bookmark, clip, note].each(&:destroy)
puts "✅ Test data cleaned up"
