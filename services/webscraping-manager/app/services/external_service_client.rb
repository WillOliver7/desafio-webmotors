require 'faraday'
require 'faraday/typhoeus'

class ExternalServiceClient
  def self.connection(base_url)
    Faraday.new(url: base_url) do |f|
      f.request :json
      f.response :json

      f.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
      f.headers['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8'
      f.headers['Accept-Language'] = 'pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7'
      f.headers['Cache-Control'] = 'no-cache'
      f.headers['Pragma'] = 'no-cache'
      
      f.adapter :typhoeus
    end
  end
end