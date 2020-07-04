Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    allows = ENV['RENT_ALLOWED_ORIGINS'].split(',')
    origins allows
    resource '*',
      credentials: true,
      headers: :any,
      methods: %i(get post put patch delete options head)
  end
end

