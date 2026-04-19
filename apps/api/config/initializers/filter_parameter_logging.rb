Rails.application.config.filter_parameters += [
  :password,
  :token,
  :authorization,
  :cookie,
  :signed_id,
  :id_token,
  :access_token
]

