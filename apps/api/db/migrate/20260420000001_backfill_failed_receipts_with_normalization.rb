class BackfillFailedReceiptsWithNormalization < ActiveRecord::Migration[8.0]
  def up
    say_with_time "reopen failed receipts that still have normalization (retry rolled back)" do
      Receipt.where(status: :failed).where.not(current_normalization_id: nil).find_each do |receipt|
        receipt.review_queue_item&.update!(reason_codes_jsonb: ["extraction_attempt_failed"])
        receipt.update!(status: :needs_review)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
