class CreateBookkeeperCore < ActiveRecord::Migration[8.0]
  def change
    enable_extension "pgcrypto"
    enable_extension "citext"

    create_table :organizations, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :base_currency, null: false
      t.string :timezone, null: false
      t.string :posting_mode, null: false, default: "review_only"
      t.decimal :auto_post_threshold, null: false, precision: 4, scale: 3, default: "0.900"
      t.jsonb :tax_policy_jsonb, null: false, default: {}
      t.jsonb :category_policy_jsonb, null: false, default: {}
      t.timestamps
    end
    add_index :organizations, :slug, unique: true

    create_table :users, id: :uuid do |t|
      t.citext :email, null: false
      t.string :display_name, null: false
      t.string :avatar_url
      t.datetime :last_seen_at
      t.timestamps
    end
    add_index :users, :email, unique: true

    create_table :memberships, id: :uuid do |t|
      t.references :organization, null: false, type: :uuid, foreign_key: true
      t.references :user, null: false, type: :uuid, foreign_key: true
      t.string :role, null: false, default: "submitter"
      t.timestamps
    end
    add_index :memberships, %i[organization_id user_id], unique: true

    create_table :oauth_identities, id: :uuid do |t|
      t.references :user, null: false, type: :uuid, foreign_key: true
      t.string :provider, null: false
      t.string :provider_uid, null: false
      t.citext :email
      t.jsonb :token_metadata_jsonb, null: false, default: {}
      t.timestamps
    end
    add_index :oauth_identities, %i[provider provider_uid], unique: true

    create_table :receipts, id: :uuid do |t|
      t.references :organization, null: false, type: :uuid, foreign_key: true
      t.references :uploaded_by, null: false, type: :uuid, foreign_key: { to_table: :users }
      t.references :duplicate_of_receipt, type: :uuid, foreign_key: { to_table: :receipts }
      t.uuid :current_processing_run_id
      t.uuid :current_extraction_id
      t.uuid :current_normalization_id
      t.string :status, null: false, default: "uploaded"
      t.string :mime_type
      t.integer :page_count
      t.string :file_checksum
      t.datetime :received_at
      t.timestamps
    end

    create_table :processing_runs, id: :uuid do |t|
      t.references :receipt, null: false, type: :uuid, foreign_key: true
      t.string :run_kind, null: false, default: "initial"
      t.string :status, null: false, default: "queued"
      t.string :job_id, null: false
      t.integer :retry_count, null: false, default: 0
      t.string :error_class
      t.text :error_message
      t.datetime :started_at
      t.datetime :finished_at
      t.timestamps
    end

    add_foreign_key :receipts, :processing_runs, column: :current_processing_run_id

    create_table :receipt_extractions, id: :uuid do |t|
      t.references :receipt, null: false, type: :uuid, foreign_key: true
      t.references :processing_run, null: false, type: :uuid, foreign_key: true
      t.string :model_name, null: false
      t.string :prompt_version, null: false
      t.jsonb :raw_model_output, null: false, default: {}
      t.jsonb :parsed_fields, null: false, default: {}
      t.text :reasoning_summary
      t.decimal :model_confidence, precision: 4, scale: 3
      t.decimal :image_quality_score, precision: 4, scale: 3
      t.jsonb :token_usage_jsonb, null: false, default: {}
      t.timestamps
    end

    add_foreign_key :receipts, :receipt_extractions, column: :current_extraction_id

    create_table :receipt_normalizations, id: :uuid do |t|
      t.references :receipt, null: false, type: :uuid, foreign_key: true
      t.references :processing_run, null: false, type: :uuid, foreign_key: true
      t.string :merchant_name
      t.string :merchant_normalized
      t.date :receipt_date
      t.string :currency, null: false
      t.bigint :subtotal_amount_cents
      t.bigint :tax_amount_cents
      t.bigint :tip_amount_cents
      t.bigint :service_charge_amount_cents
      t.bigint :total_amount_cents
      t.string :payment_method_last4
      t.jsonb :location_jsonb, null: false, default: {}
      t.jsonb :line_items_jsonb, null: false, default: []
      t.string :reconciliation_status, null: false, default: "pending"
      t.bigint :reconciliation_delta_cents
      t.jsonb :confidence_breakdown_jsonb, null: false, default: {}
      t.timestamps
    end

    add_foreign_key :receipts, :receipt_normalizations, column: :current_normalization_id

    create_table :category_decisions, id: :uuid do |t|
      t.references :receipt, null: false, type: :uuid, foreign_key: true
      t.string :category_code, null: false
      t.string :subcategory_code
      t.string :decision_source, null: false
      t.decimal :confidence_score, null: false, precision: 4, scale: 3
      t.text :category_reason
      t.jsonb :reason_codes_jsonb, null: false, default: []
      t.timestamps
    end

    create_table :duplicate_fingerprints, id: :uuid do |t|
      t.references :receipt, null: false, type: :uuid, foreign_key: true
      t.string :exact_checksum
      t.string :perceptual_hash
      t.string :merchant_total_date_fingerprint
      t.references :matched_receipt, type: :uuid, foreign_key: { to_table: :receipts }
      t.decimal :match_score, precision: 4, scale: 3
      t.string :match_type, null: false, default: "none"
      t.timestamps
    end

    create_table :review_queue_items, id: :uuid do |t|
      t.references :organization, null: false, type: :uuid, foreign_key: true
      t.references :receipt, null: false, type: :uuid, foreign_key: true
      t.references :assigned_to, type: :uuid, foreign_key: { to_table: :users }
      t.string :state, null: false, default: "pending"
      t.integer :priority, null: false, default: 50
      t.datetime :locked_at
      t.datetime :resolved_at
      t.jsonb :reason_codes_jsonb, null: false, default: []
      t.timestamps
    end
    add_index :review_queue_items, :receipt_id, unique: true

    create_table :user_corrections, id: :uuid do |t|
      t.references :receipt, null: false, type: :uuid, foreign_key: true
      t.references :actor, null: false, type: :uuid, foreign_key: { to_table: :users }
      t.references :supersedes_correction, type: :uuid, foreign_key: { to_table: :user_corrections }
      t.jsonb :corrected_fields_jsonb, null: false, default: {}
      t.text :comment
      t.timestamps
    end

    create_table :accounting_entries, id: :uuid do |t|
      t.references :organization, null: false, type: :uuid, foreign_key: true
      t.references :receipt, null: false, type: :uuid, foreign_key: true
      t.string :status, null: false, default: "draft"
      t.date :transaction_date, null: false
      t.string :currency, null: false
      t.bigint :gross_amount_cents, null: false
      t.bigint :subtotal_amount_cents
      t.bigint :tax_amount_cents
      t.bigint :tip_amount_cents
      t.bigint :service_charge_amount_cents
      t.string :merchant_name
      t.string :vendor_ref
      t.string :category_code
      t.text :notes
      t.string :export_state
      t.jsonb :export_payload_jsonb, null: false, default: {}
      t.jsonb :source_provenance_jsonb, null: false, default: {}
      t.timestamps
    end
    add_index :accounting_entries, :receipt_id, unique: true

    create_table :accounting_entry_lines, id: :uuid do |t|
      t.references :accounting_entry, null: false, type: :uuid, foreign_key: true
      t.string :line_type, null: false
      t.string :account_code, null: false
      t.bigint :amount_cents, null: false
      t.jsonb :metadata_jsonb, null: false, default: {}
      t.timestamps
    end

    create_table :audit_events, id: :uuid do |t|
      t.references :organization, null: false, type: :uuid, foreign_key: true
      t.string :auditable_type, null: false
      t.uuid :auditable_id, null: false
      t.references :actor, type: :uuid, foreign_key: { to_table: :users }
      t.string :event_type, null: false
      t.string :action_source, null: false
      t.string :request_id
      t.string :idempotency_key
      t.jsonb :before_jsonb
      t.jsonb :after_jsonb, null: false, default: {}
      t.jsonb :metadata_jsonb, null: false, default: {}
      t.timestamps
    end
    add_index :audit_events, %i[auditable_type auditable_id]
  end
end

