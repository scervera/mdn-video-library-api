# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_19_182855) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bookmarks", force: :cascade do |t|
    t.string "title", null: false
    t.text "notes"
    t.decimal "timestamp", precision: 10, scale: 2, null: false
    t.bigint "lesson_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tenant_id", null: false
    t.index ["lesson_id", "timestamp"], name: "index_bookmarks_on_lesson_id_and_timestamp"
    t.index ["lesson_id"], name: "index_bookmarks_on_lesson_id"
    t.index ["tenant_id"], name: "index_bookmarks_on_tenant_id"
    t.index ["user_id", "lesson_id", "timestamp"], name: "index_bookmarks_on_user_lesson_timestamp_unique", unique: true
    t.index ["user_id", "lesson_id"], name: "index_bookmarks_on_user_id_and_lesson_id"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "chapters", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "duration"
    t.integer "order_index"
    t.boolean "published"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "curriculum_id", null: false
    t.bigint "tenant_id", null: false
    t.index ["curriculum_id"], name: "index_chapters_on_curriculum_id"
    t.index ["tenant_id"], name: "index_chapters_on_tenant_id"
  end

  create_table "curriculums", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.boolean "published"
    t.integer "order_index"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tenant_id", null: false
    t.index ["tenant_id"], name: "index_curriculums_on_tenant_id"
  end

  create_table "lesson_progresses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "lesson_id", null: false
    t.boolean "completed"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tenant_id", null: false
    t.index ["lesson_id"], name: "index_lesson_progresses_on_lesson_id"
    t.index ["tenant_id"], name: "index_lesson_progresses_on_tenant_id"
    t.index ["user_id"], name: "index_lesson_progresses_on_user_id"
  end

  create_table "lessons", force: :cascade do |t|
    t.bigint "chapter_id", null: false
    t.string "title"
    t.text "description"
    t.string "content_type"
    t.text "content"
    t.string "media_url"
    t.integer "order_index"
    t.boolean "published"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cloudflare_stream_id"
    t.string "cloudflare_stream_thumbnail"
    t.integer "cloudflare_stream_duration"
    t.string "cloudflare_stream_status", default: "ready"
    t.bigint "tenant_id", null: false
    t.index ["chapter_id"], name: "index_lessons_on_chapter_id"
    t.index ["cloudflare_stream_id"], name: "index_lessons_on_cloudflare_stream_id"
    t.index ["content_type"], name: "index_lessons_on_content_type"
    t.index ["tenant_id"], name: "index_lessons_on_tenant_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "domain"
    t.jsonb "branding_settings", default: {}
    t.jsonb "subscription_settings", default: {}
    t.string "stripe_customer_id"
    t.string "subscription_status", default: "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "dns_record_id"
    t.index ["slug"], name: "index_tenants_on_slug", unique: true
    t.index ["stripe_customer_id"], name: "index_tenants_on_stripe_customer_id"
  end

  create_table "user_highlights", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "chapter_id", null: false
    t.string "highlighted_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "curriculum_id", null: false
    t.bigint "tenant_id", null: false
    t.index ["chapter_id"], name: "index_user_highlights_on_chapter_id"
    t.index ["curriculum_id"], name: "index_user_highlights_on_curriculum_id"
    t.index ["tenant_id"], name: "index_user_highlights_on_tenant_id"
    t.index ["user_id"], name: "index_user_highlights_on_user_id"
  end

  create_table "user_notes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "chapter_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "curriculum_id", null: false
    t.bigint "tenant_id", null: false
    t.index ["chapter_id"], name: "index_user_notes_on_chapter_id"
    t.index ["curriculum_id"], name: "index_user_notes_on_curriculum_id"
    t.index ["tenant_id"], name: "index_user_notes_on_tenant_id"
    t.index ["user_id"], name: "index_user_notes_on_user_id"
  end

  create_table "user_progresses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "chapter_id", null: false
    t.boolean "completed"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "curriculum_id", null: false
    t.bigint "tenant_id", null: false
    t.index ["chapter_id"], name: "index_user_progresses_on_chapter_id"
    t.index ["curriculum_id"], name: "index_user_progresses_on_curriculum_id"
    t.index ["tenant_id"], name: "index_user_progresses_on_tenant_id"
    t.index ["user_id"], name: "index_user_progresses_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "username"
    t.string "first_name"
    t.string "last_name"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tenant_id", null: false
    t.string "role", default: "user"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
  end

  add_foreign_key "bookmarks", "lessons"
  add_foreign_key "bookmarks", "tenants"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "chapters", "curriculums"
  add_foreign_key "chapters", "tenants"
  add_foreign_key "curriculums", "tenants"
  add_foreign_key "lesson_progresses", "lessons"
  add_foreign_key "lesson_progresses", "tenants"
  add_foreign_key "lesson_progresses", "users"
  add_foreign_key "lessons", "chapters"
  add_foreign_key "lessons", "tenants"
  add_foreign_key "user_highlights", "chapters"
  add_foreign_key "user_highlights", "curriculums"
  add_foreign_key "user_highlights", "tenants"
  add_foreign_key "user_highlights", "users"
  add_foreign_key "user_notes", "chapters"
  add_foreign_key "user_notes", "curriculums"
  add_foreign_key "user_notes", "tenants"
  add_foreign_key "user_notes", "users"
  add_foreign_key "user_progresses", "chapters"
  add_foreign_key "user_progresses", "curriculums"
  add_foreign_key "user_progresses", "tenants"
  add_foreign_key "user_progresses", "users"
  add_foreign_key "users", "tenants"
end
