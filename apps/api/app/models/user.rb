class User < ApplicationRecord
  has_secure_password validations: false

  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships
  has_many :oauth_identities, dependent: :destroy
  has_many :uploaded_receipts, class_name: "Receipt", foreign_key: :uploaded_by_id, dependent: :nullify
  has_many :review_queue_items, foreign_key: :assigned_to_id, dependent: :nullify
  has_many :user_corrections, foreign_key: :actor_id, dependent: :nullify

  validates :email, :display_name, presence: true
  validates :email, uniqueness: true
  validates :password, presence: true, length: { minimum: 8 }, if: -> { registering_with_password }

  attr_accessor :registering_with_password
end

