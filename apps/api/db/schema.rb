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

ActiveRecord::Schema[8.0].define(version: 2026_04_20_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "accounting_entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.uuid "receipt_id", null: false
    t.string "status", default: "draft", null: false
    t.date "transaction_date", null: false
    t.string "currency", null: false
    t.bigint "gross_amount_cents", null: false
    t.bigint "subtotal_amount_cents"
    t.bigint "tax_amount_cents"
    t.bigint "tip_amount_cents"
    t.bigint "service_charge_amount_cents"
    t.string "merchant_name"
    t.string "vendor_ref"
    t.string "category_code"
    t.text "notes"
    t.string "export_state"
    t.jsonb "export_payload_jsonb", default: {}, null: false
    t.jsonb "source_provenance_jsonb", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_accounting_entries_on_organization_id"
    t.index ["receipt_id"], name: "index_accounting_entries_on_receipt_id", unique: true
  end

  create_table "accounting_entry_lines", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "accounting_entry_id", null: false
    t.string "line_type", null: false
    t.string "account_code", null: false
    t.bigint "amount_cents", null: false
    t.jsonb "metadata_jsonb", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accounting_entry_id"], name: "index_accounting_entry_lines_on_accounting_entry_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "audit_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.string "auditable_type", null: false
    t.uuid "auditable_id", null: false
    t.uuid "actor_id"
    t.string "event_type", null: false
    t.string "action_source", null: false
    t.string "request_id"
    t.string "idempotency_key"
    t.jsonb "before_jsonb"
    t.jsonb "after_jsonb", default: {}, null: false
    t.jsonb "metadata_jsonb", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_audit_events_on_actor_id"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_events_on_auditable_type_and_auditable_id"
    t.index ["organization_id"], name: "index_audit_events_on_organization_id"
  end

  create_table "category_decisions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "receipt_id", null: false
    t.string "category_code", null: false
    t.string "subcategory_code"
    t.string "decision_source", null: false
    t.decimal "confidence_score", precision: 4, scale: 3, null: false
    t.text "category_reason"
    t.jsonb "reason_codes_jsonb", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["receipt_id"], name: "index_category_decisions_on_receipt_id"
  end

  create_table "duplicate_fingerprints", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "receipt_id", null: false
    t.string "exact_checksum"
    t.string "perceptual_hash"
    t.string "merchant_total_date_fingerprint"
    t.uuid "matched_receipt_id"
    t.decimal "match_score", precision: 4, scale: 3
    t.string "match_type", default: "none", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["matched_receipt_id"], name: "index_duplicate_fingerprints_on_matched_receipt_id"
    t.index ["receipt_id"], name: "index_duplicate_fingerprints_on_receipt_id"
  end

  create_table "memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.uuid "user_id", null: false
    t.string "role", default: "submitter", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "user_id"], name: "index_memberships_on_organization_id_and_user_id", unique: true
    t.index ["organization_id"], name: "index_memberships_on_organization_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "oauth_identities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "provider", null: false
    t.string "provider_uid", null: false
    t.citext "email"
    t.jsonb "token_metadata_jsonb", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "provider_uid"], name: "index_oauth_identities_on_provider_and_provider_uid", unique: true
    t.index ["user_id"], name: "index_oauth_identities_on_user_id"
  end

  create_table "organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "base_currency", null: false
    t.string "timezone", null: false
    t.string "posting_mode", default: "review_only", null: false
    t.decimal "auto_post_threshold", precision: 4, scale: 3, default: "0.9", null: false
    t.jsonb "tax_policy_jsonb", default: {}, null: false
    t.jsonb "category_policy_jsonb", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
  end

  create_table "processing_runs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "receipt_id", null: false
    t.string "run_kind", default: "initial", null: false
    t.string "status", default: "queued", null: false
    t.string "job_id", null: false
    t.integer "retry_count", default: 0, null: false
    t.string "error_class"
    t.text "error_message"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["receipt_id"], name: "index_processing_runs_on_receipt_id"
  end

  create_table "receipt_extractions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "receipt_id", null: false
    t.uuid "processing_run_id", null: false
    t.string "extraction_model", null: false
    t.string "prompt_version", null: false
    t.jsonb "raw_model_output", default: {}, null: false
    t.jsonb "parsed_fields", default: {}, null: false
    t.text "reasoning_summary"
    t.decimal "model_confidence", precision: 4, scale: 3
    t.decimal "image_quality_score", precision: 4, scale: 3
    t.jsonb "token_usage_jsonb", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["processing_run_id"], name: "index_receipt_extractions_on_processing_run_id"
    t.index ["receipt_id"], name: "index_receipt_extractions_on_receipt_id"
  end

  create_table "receipt_normalizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "receipt_id", null: false
    t.uuid "processing_run_id", null: false
    t.string "merchant_name"
    t.string "merchant_normalized"
    t.date "receipt_date"
    t.string "currency", null: false
    t.bigint "subtotal_amount_cents"
    t.bigint "tax_amount_cents"
    t.bigint "tip_amount_cents"
    t.bigint "service_charge_amount_cents"
    t.bigint "total_amount_cents"
    t.string "payment_method_last4"
    t.jsonb "location_jsonb", default: {}, null: false
    t.jsonb "line_items_jsonb", default: [], null: false
    t.string "reconciliation_status", default: "pending", null: false
    t.bigint "reconciliation_delta_cents"
    t.jsonb "confidence_breakdown_jsonb", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["processing_run_id"], name: "index_receipt_normalizations_on_processing_run_id"
    t.index ["receipt_id"], name: "index_receipt_normalizations_on_receipt_id"
  end

  create_table "receipts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.uuid "uploaded_by_id", null: false
    t.uuid "duplicate_of_receipt_id"
    t.uuid "current_processing_run_id"
    t.uuid "current_extraction_id"
    t.uuid "current_normalization_id"
    t.string "status", default: "uploaded", null: false
    t.string "mime_type"
    t.integer "page_count"
    t.string "file_checksum"
    t.datetime "received_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["duplicate_of_receipt_id"], name: "index_receipts_on_duplicate_of_receipt_id"
    t.index ["organization_id"], name: "index_receipts_on_organization_id"
    t.index ["uploaded_by_id"], name: "index_receipts_on_uploaded_by_id"
  end

  create_table "review_queue_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.uuid "receipt_id", null: false
    t.uuid "assigned_to_id"
    t.string "state", default: "pending", null: false
    t.integer "priority", default: 50, null: false
    t.datetime "locked_at"
    t.datetime "resolved_at"
    t.jsonb "reason_codes_jsonb", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_to_id"], name: "index_review_queue_items_on_assigned_to_id"
    t.index ["organization_id"], name: "index_review_queue_items_on_organization_id"
    t.index ["receipt_id"], name: "index_review_queue_items_on_receipt_id", unique: true
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key"], name: "index_solid_queue_blocked_executions_on_concurrency_key"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id"], name: "index_solid_queue_claimed_executions_on_process_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_on_queue_name_and_finished_at"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_on_scheduled_at_and_finished_at"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name"], name: "index_solid_queue_processes_on_name", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "user_corrections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "receipt_id", null: false
    t.uuid "actor_id", null: false
    t.uuid "supersedes_correction_id"
    t.jsonb "corrected_fields_jsonb", default: {}, null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_user_corrections_on_actor_id"
    t.index ["receipt_id"], name: "index_user_corrections_on_receipt_id"
    t.index ["supersedes_correction_id"], name: "index_user_corrections_on_supersedes_correction_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "email", null: false
    t.string "display_name", null: false
    t.string "avatar_url"
    t.datetime "last_seen_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "accounting_entries", "organizations"
  add_foreign_key "accounting_entries", "receipts"
  add_foreign_key "accounting_entry_lines", "accounting_entries"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "audit_events", "organizations"
  add_foreign_key "audit_events", "users", column: "actor_id"
  add_foreign_key "category_decisions", "receipts"
  add_foreign_key "duplicate_fingerprints", "receipts"
  add_foreign_key "duplicate_fingerprints", "receipts", column: "matched_receipt_id"
  add_foreign_key "memberships", "organizations"
  add_foreign_key "memberships", "users"
  add_foreign_key "oauth_identities", "users"
  add_foreign_key "processing_runs", "receipts"
  add_foreign_key "receipt_extractions", "processing_runs"
  add_foreign_key "receipt_extractions", "receipts"
  add_foreign_key "receipt_normalizations", "processing_runs"
  add_foreign_key "receipt_normalizations", "receipts"
  add_foreign_key "receipts", "organizations"
  add_foreign_key "receipts", "processing_runs", column: "current_processing_run_id"
  add_foreign_key "receipts", "receipt_extractions", column: "current_extraction_id"
  add_foreign_key "receipts", "receipt_normalizations", column: "current_normalization_id"
  add_foreign_key "receipts", "receipts", column: "duplicate_of_receipt_id"
  add_foreign_key "receipts", "users", column: "uploaded_by_id"
  add_foreign_key "review_queue_items", "organizations"
  add_foreign_key "review_queue_items", "receipts"
  add_foreign_key "review_queue_items", "users", column: "assigned_to_id"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id"
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id"
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id"
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id"
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id"
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id"
  add_foreign_key "user_corrections", "receipts"
  add_foreign_key "user_corrections", "user_corrections", column: "supersedes_correction_id"
  add_foreign_key "user_corrections", "users", column: "actor_id"
end
