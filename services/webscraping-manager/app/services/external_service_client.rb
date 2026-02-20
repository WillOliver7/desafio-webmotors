require 'faraday'
require 'faraday/typhoeus' rescue nil

class ExternalServiceClient
  def self.connection(base_url)
    Faraday.new(url: base_url) do |f|
      f.request :json
      f.response :json
      
      f.adapter :typhoeus
    end
  end
end