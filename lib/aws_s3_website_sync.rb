require 'aws-sdk-cloudfront'
require 'aws-sdk-s3'
require 'digest/md5'
require 'logger'
require 'fileutils'

require_relative 'aws_s3_website_sync/runner'
require_relative 'aws_s3_website_sync/list'
require_relative 'aws_s3_website_sync/preview'
require_relative 'aws_s3_website_sync/color'
require_relative 'aws_s3_website_sync/plan'
require_relative 'aws_s3_website_sync/apply'

$logger = Logger.new(STDOUT)
