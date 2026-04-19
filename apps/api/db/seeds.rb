organization = Organization.find_or_create_by!(slug: "demo-org") do |org|
  org.name = "Demo Organization"
  org.base_currency = "USD"
  org.timezone = "America/Toronto"
  org.posting_mode = "review_only"
end

user = User.find_or_create_by!(email: "demo@example.com") do |record|
  record.display_name = "Demo User"
end

Membership.find_or_create_by!(organization:, user:) do |membership|
  membership.role = :admin
end
