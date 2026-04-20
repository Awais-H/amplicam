class RenameReceiptExtractionsModelNameToExtractionModel < ActiveRecord::Migration[8.0]
  def change
    rename_column :receipt_extractions, :model_name, :extraction_model
  end
end
