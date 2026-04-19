module Types
  class UserType < BaseObject
    field :id, ID, null: false
    field :email, String, null: false
    field :display_name, String, null: false
    field :avatar_url, String, null: true
  end
end

