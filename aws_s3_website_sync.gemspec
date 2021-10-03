$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "aws_s3_website_sync/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "aws_s3_website_sync"
  s.version     = AwsS3WebsiteSync::VERSION
  s.authors     = ["TeacherSeat"]
  s.email       = ["andrew@teachersaet.co"]
  s.homepage    = "https://www.teacherseat.com"
  s.summary     = 'AWS S3 Website Sync'
  s.description = 'AWS S3 Website Sync'
  s.license     = "MIT"

  s.add_dependency 'aws-sdk-cloudfront'
  s.add_dependency 'aws-sdk-s3'
  s.files = Dir["{app,config,db,lib}/**/*", "README.md"]
  s.test_files = Dir["spec/**/*"]
end

