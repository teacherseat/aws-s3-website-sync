module AwsS3WebsiteList
  class Preview
    def self.run changeset_path:, silent:
      silent_actions = silent.split(',')
      json = File.read changeset_path
      data = JSON.parse json
      puts "---[ Plan ]------------------------------------------------------------"
      puts "ChangeSet: #{File.basename(changeset_path,'.json')}"
      puts ""
      puts "WebSync will perform the following operations:"
      puts ""
      data = data.sort_by { |t| t["path"] }

      summary = {
        ignore: 0,
        delete: 0,
        create: 0,
        update: 0,
        no_change: 0
      }
      data.each do |item|
        action =
        case item['action']
        when 'ignore'
          summary[:ignore] += 1
          AsciiColor.grey item['action']
        when 'delete'
          summary[:delete] += 1
          AsciiColor.red item['action']
        when 'create'
          summary[:create] += 1
          AsciiColor.green item['action']
        when 'update'
          summary[:update] += 1
          AsciiColor.cyan item['action']
        when 'no_change'
          summary[:no_change] += 1
          AsciiColor.yellow item['action']
        end

        unless silent_actions.include?(item["action"])
          puts "\t#{action} #{item["path"]}"
        end
      end # data.each
      puts "--------------------------------------------------------------------"
      puts [
        AsciiColor.grey("ignore: #{summary[:ignore]}"),
        AsciiColor.red("delete: #{summary[:delete]}"),
        AsciiColor.green("create: #{summary[:create]}"),
        AsciiColor.cyan("update: #{summary[:update]}"),
        AsciiColor.yellow("no_change: #{summary[:no_change]}")
      ].join('   ')
      puts ""
    end
  end
end
