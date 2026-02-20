class NotificationServiceClient
  BASE_URL = ENV.fetch('NOTIFICATION_SERVICE_URL') { 'http://notification-service:3000' }

  def self.send_notification(notification_data)
    response = ExternalServiceClient.connection(BASE_URL).post('/notifications') do |req|
      req.body = notification_data
      req.options.timeout = 60         # Timeout aqui
      req.options.open_timeout = 10    # Open timeout aqui
    end
    response.body
  rescue Faraday::Error => e
    { error: "Notification Service unavailable", details: e.message }
  end
end