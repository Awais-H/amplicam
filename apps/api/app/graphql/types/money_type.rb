module Types
  class MoneyType < BaseObject
    field :amount, Types::Scalars::DecimalType, null: false
    field :currency, String, null: false
  end
end

