# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using model:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150811164526) do

  create_table "harvest_jobs", force: :cascade do |t|
    t.datetime "from_time"
    t.datetime "until_time"
    t.text     "query_url"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "status",     default: 0
  end

  create_table "harvested_records", force: :cascade do |t|
    t.text     "identifier"
    t.datetime "timestamp"
    t.boolean  "deleted"
    t.text     "content_path"
    t.integer  "harvest_job_id"
  end

  create_table "index_jobs", force: :cascade do |t|
    t.integer  "harvest_job_id"
    t.text     "solr_url"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "status",         default: 0
  end

  create_table "indexed_records", force: :cascade do |t|
    t.integer  "index_job_id"
    t.integer  "harvested_record_id"
    t.datetime "submitted_time"
    t.integer  "status",              default: 0
  end

end
