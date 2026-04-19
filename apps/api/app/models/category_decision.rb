class CategoryDecision < ApplicationRecord
  belongs_to :receipt

  validates :category_code, :decision_source, :confidence_score, presence: true
  validates :confidence_score, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0 }
end

