Devise.setup do |config|
  config.mailer_sender = 'noreply@mydownbeat.co'
  
  # JWT configuration
  config.jwt do |jwt|
    jwt.secret = Rails.application.credentials.devise_jwt_secret_key
    jwt.dispatch_requests = [
      ['POST', %r{^/login$}]
    ]
    jwt.revocation_requests = [
      ['DELETE', %r{^/logout$}]
    ]
    jwt.expiration_time = 30.days.to_i
  end
  
  # ... rest of devise config
end