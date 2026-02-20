require 'vcr'
require 'webmock/rspec'

VCR.configure do |config|
  # Directory where VCR cassettes will be saved
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  # Hook into webmock to intercept HTTP requests
  config.hook_into :webmock
  # Allow real HTTP connections when no cassette is being used
  config.configure_rspec_metadata!
  # Ignore localhost requests to allow testing against local servers without recording them
  config.ignore_localhost = true
end