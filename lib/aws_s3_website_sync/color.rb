module AwsS3WebsiteList
  class Color
    def self.cyan str
      "\e[36m#{str}\e[0m"
    end

    def self.red str
      "\e[31m#{str}\e[0m"
    end

    def self.green str
      "\e[32m#{str}\e[0m"
    end

    def self.yellow str
      "\e[33m#{str}\e[0m"
    end

    def self.grey str
      "\e[37m#{str}\e[0m"
    end
  end
end
