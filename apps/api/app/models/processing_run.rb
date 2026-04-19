class ProcessingRun < ApplicationRecord
  belongs_to :receipt

  enum :run_kind, {
    initial: "initial",
    retry: "retry",
    reprocess: "reprocess"
  }, default: :initial

  enum :status, {
    queued: "queued",
    running: "running",
    succeeded: "succeeded",
    failed: "failed"
  }, default: :queued

  validates :run_kind, :status, :job_id, presence: true
end

