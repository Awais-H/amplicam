module Mutations
  class UpdateOrganizationPolicies < Types::BaseMutation
    argument :tax_policy, Types::Scalars::JsonType, required: false
    argument :category_policy, Types::Scalars::JsonType, required: false
    argument :posting_mode, String, required: false
    argument :auto_post_threshold, Types::Scalars::DecimalType, required: false

    field :organization, Types::OrganizationType, null: false

    def resolve(tax_policy: nil, category_policy: nil, posting_mode: nil, auto_post_threshold: nil)
      authorize_record!(current_organization, :update?)

      attrs = {}
      attrs[:tax_policy_jsonb] = tax_policy if tax_policy
      attrs[:category_policy_jsonb] = category_policy if category_policy
      attrs[:posting_mode] = posting_mode if posting_mode
      attrs[:auto_post_threshold] = auto_post_threshold if auto_post_threshold

      current_organization.update!(attrs)
      { organization: current_organization }
    end
  end
end

