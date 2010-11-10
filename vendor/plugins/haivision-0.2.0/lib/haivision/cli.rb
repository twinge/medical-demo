require 'net/ssh'
module Haivision
  class Cli
    HOST = '10.1.50.51'
    USER = 'root'
    PASS = 'vfurnace'
    
    def self.close_instream_by_ip(ip)
      send_command('vfepg-command -c "quit" -i ' + ip.to_s)
    end
    
    def self.close_instream_by_channel(channel)
      send_command('vfepg-command -c "quit" -n ' + channel.to_s)
    end
    
    private
      def self.send_command(command)
       Net::SSH.start( HOST, USER, :password => PASS ) do|ssh|
         result = ssh.exec!(command)
       end
    end
  end
  
end