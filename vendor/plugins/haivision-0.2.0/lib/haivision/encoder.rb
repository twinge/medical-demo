require 'net/ssh'
require 'net/scp'
module Haivision
  class Encoder
    USER = 'root'
    PASSWORD = 'hairoot'
    attr_accessor :ip, :user, :password
    
    def initialize(ip, user = nil, password = nil)
      @ip = ip
      @user = user || USER
      @password = password || PASSWORD
    end
    
    def take_snapshot(target_path)
      result = send_command('snapshot take')
      filename = result.match(/"(.*)"/)[1]
      basename = File.basename(filename)
      Net::SCP.start(ip, user, :password => password ) do |scp|
        scp.download!(filename, target_path + '/' + basename, :verbose => true)
      end
      basename
    end
    
    def self.close_instream_by_channel(channel)
      send_command('vfepg-command -c "quit" -n ' + channel.to_s)
    end
    
    def self.change_channel(from_channel, to_channel)
      send_command('vfepg-command -n ' + from_channel.to_s + ' -c "channel ' + to_channel.to_s + '"')
    end
    
    private
      def send_command(command)
        result = nil
        Net::SSH.start( ip, user, :password => password ) do |ssh|
          result = ssh.exec!(command)
        end
        result
      end
  end
  
end