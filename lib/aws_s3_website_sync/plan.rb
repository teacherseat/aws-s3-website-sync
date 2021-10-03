module AwsS3WebsiteSync
  class Plan
    def self.run(
        output_changeset_path:,
        build_dir:,
        aws_access_key_id:,
        aws_secret_access_key:,
        s3_bucket:,
        aws_default_region:,
        ignore_files:
      )
      paths = WebSync::List.local build_dir
      keys  = WebSync::List.remote aws_access_key_id, aws_secret_access_key, s3_bucket, aws_default_region

      # Files we should delete
      diff_delete = WebSync::Plan.delete paths, keys

      # Ignore files we plan to delete for create_or_update
      create_or_update_keys = keys.reject{|t| diff_delete.any?(t[:path]) }

      # Files we should create or update
      diff_create_or_update = WebSync::Plan.create_or_update paths, create_or_update_keys

      WebSync::Plan.create_changeset output_changeset_path, diff_delete, diff_create_or_update, ignore_files
    end

    def self.create_changeset output_changeset_path, diff_delete_keys, diff_create_or_update, ignore_files
      diff_delete = diff_delete_keys.map{|t| {path: t, action: 'delete'} }
      data = diff_delete + diff_create_or_update

      data.each do |t|
        if ignore_files.include?(t[:path])
          t[:action] = 'ignore'
        end
      end

      formatted_data = JSON.pretty_generate data

      FileUtils.mkdir_p File.dirname(output_changeset_path)
      File.write output_changeset_path, formatted_data
    end

    # Get the differece between the local build directory and S3 bucket
    # return: [Array] a list of keys that should be deleted
    def self.delete paths, keys
      $logger.info "Diff.delete"
      keys.map{|t|t[:path]} - paths.map{|t|t[:path]}
    end

    # Get the difference of files changed
    def self.create_or_update paths, keys
      $logger.info "Diff.create_update"
      results = []
      paths.each do |p|
        if k = keys.find{|t|t[:path] == p[:path] }
          # existing entry
          if k[:md5] == p[:md5]
            results.push p.merge(action: 'no_change')
          else
            results.push p.merge(action: 'update')
          end
        else
          results.push p.merge(action: 'create')
        end
      end
      results
    end
  end
end
