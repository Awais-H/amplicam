class CleanupOrphanUploadsJob < ApplicationJob
  queue_as :low

  def perform
    ActiveStorage::Blob.unattached.where(created_at: ..24.hours.ago).find_each(&:purge_later)
  end
end

