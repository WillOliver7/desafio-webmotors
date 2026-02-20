class AuthServiceClient
  BASE_URL = ENV.fetch('AUTH_SERVICE_URL') { 'http://auth-service:3000' }

  def self.verify_token(token)
    response = ExternalServiceClient.connection(BASE_URL).get('/validate') do |req|
      req.headers['Authorization'] = "Bearer #{token}"
    end
    response.body
  rescue Faraday::Error => e
    { error: "Auth Service unavailable", details: e.message }
  end
end