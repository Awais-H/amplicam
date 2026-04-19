module Types
  class MutationType < BaseObject
    field :noop, String, null: false,
      description: "Placeholder mutation until workflow mutations are added."

    def noop
      "ok"
    end
  end
end

