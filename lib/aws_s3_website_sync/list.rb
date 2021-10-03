module AwsS3WebsiteSync
  class List
    def self.local build_dir
      $logger.info "List.local"
      paths = Dir.glob build_dir +  "/**/*"
      paths = paths.reject { |f| File.directory?(f) }
      paths.map! do |path|
        md5  = Digest::MD5.hexdigest File.read(path)
        path = path.sub build_dir + '/', ''
        path =
        if path == 'index.html'
          path
        else
          path.sub('.html','')
        end
        {path: path, md5: md5}
      end
      paths
    end

    def self.remote aws_access_key_id, aws_secret_access_key, s3_bucket, aws_default_region
      $logger.info "List.remote"
      s3 ||= Aws::S3::Resource.new({
       region: aws_default_region,
       credentials: Aws::Credentials.new(
         aws_access_key_id,
         aws_secret_access_key
        )
      })
      bucket = s3.bucket s3_bucket
      keys = bucket.objects.map do |object_summary|
        {path: object_summary.key, md5: object_summary.etag.gsub('"','')}
      end
      keys
    end
  end
end
