module AwsS3WebsiteSync
  class Apply
    # path to changeset file
    def self.run(
      changeset_path:,
      aws_access_key_id:,
      aws_secret_access_key:,
      s3_bucket:,
      distribution_id:,
      caller_reference:,
      aws_default_region:,
      build_dir:
    )
      json = File.read(changeset_path)
      data = JSON.parse(json)

      puts "---[ Apply ]------------------------------------------------------------"
      puts "ChangeSet: #{File.basename(changeset_path,'.json')}"
      puts ""
      puts "WebSync is performing operations:"

      items_delete = data.select{|t| t["action"] == "delete" }
      keys_delete  = items_delete.map{|t|t["path"]}

      items_create_or_update = data.select{|t| %{create update}.include?(t["action"]) }

      s3 = Aws::S3::Resource.new({
       region: aws_default_region,
       credentials: Aws::Credentials.new(
         aws_access_key_id,
         aws_secret_access_key
        )
      })
      bucket = s3.bucket s3_bucket
      AwsS3WebsiteSync::Apply.delete bucket, keys_delete
      AwsS3WebsiteSync::Apply.create_or_update bucket, items_create_or_update, build_dir
      AwsS3WebsiteSync::Apply.invalidate aws_access_key_id, aws_secret_access_key, aws_default_region, distribution_id, caller_reference, data
    end

    def self.delete bucket, keys
      $logger.info "Apply.delete"
      return if keys.empty?
      puts "\t#{keys}"
      bucket.delete_objects({
        delete: { # required
          objects: keys.map{|t|{key: t}},
          quiet: false,
        }
      })
    end

    # files: [{key: '', path: ''}]
    def self.create_or_update bucket, files, build_dir
      files.each do |data|
        puts "\t#{data["path"]}"

        file_path = build_dir + "/" + data["path"]
        file_path = file_path + ".html" if !!(data["path"] =~ /\./) == false

        file = File.open file_path
        md5 = Digest::MD5.hexdigest file.read
        md5 = Base64.encode64([md5].pack("H*")).strip

        attrs = {
          key: data["path"],
          body: IO.read(file),
          content_md5: md5
        }
        # If it doee not have an extension assume its an html file
        # and explicty set content type to html.
        if !!(data["path"] =~ /\./) == false
          attrs[:content_type] = 'text/html'
        elsif !!data["path"] =~ /\.svg/
          attrs[:content_type] = "image/svg+xml"
        end
        # TEMP
        resp = bucket.put_object(attrs)
      end
    end

    def self.invalidate aws_access_key_id, aws_secret_access_key, aws_default_region, distribution_id, caller_reference, files
      $logger.info "Apply.invalidate"
      items = files.select{|t| %w{create update delete}.include?(t["action"]) }
      items.map!{|t| "/" + t["path"] }

      cloudfront = Aws::CloudFront::Client.new(
       region: aws_default_region,
       credentials: Aws::Credentials.new(
         aws_access_key_id,
         aws_secret_access_key
        )
      )
      resp = cloudfront.create_invalidation({
        distribution_id: distribution_id, # required
        invalidation_batch: { # required
          paths: { # required
            quantity: items.count, # required
            items: items
          },
          caller_reference: caller_reference # required
        }
      })
    end
  end
end
