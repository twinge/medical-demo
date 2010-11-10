module Apiserver
  module CLI
    class Version
      def self.version
        require 'apiserver'
        # print version
        puts "Version #{Apiserver.version}"
        exit
      end
    end
  end
end