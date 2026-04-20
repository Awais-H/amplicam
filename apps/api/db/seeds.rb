pwd = ENV.fetch("DEMO_USER_PASSWORD", "password123")

organization = Organization.find_or_create_by!(slug: "demo-org") do |org|
  org.name = "Demo Organization"
  org.base_currency = "USD"
  org.timezone = "America/Toronto"
  org.posting_mode = "review_only"
end

user = User.find_or_initialize_by(email: "demo@example.com")
user.display_name = "Demo User"
if user.new_record?
  user.registering_with_password = true
  user.password = pwd
  user.password_confirmation = pwd
  user.save!
elsif user.password_digest.blank?
  user.password = pwd
  user.password_confirmation = pwd
  user.save!(validate: false)
else
  user.save! if user.changed?
end

Membership.find_or_create_by!(organization:, user:) do |membership|
  membership.role = :admin
end
