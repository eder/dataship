Datadog.configure do |c|
  c.env     = ENV.fetch("DD_ENV", "development")
  c.service = ENV.fetch("DD_SERVICE", "dataship_backend")

  c.tracing.enabled = true
  c.tracing.instrument :rails
  c.tracing.instrument :sidekiq
end
