module Types
  class OrganizationType < BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :slug, String, null: false
    field :base_currency, String, null: false
    field :timezone, String, null: false
    field :posting_mode, String, null: false
    field :auto_post_threshold, Float, null: false
  end
end

