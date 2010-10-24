class ApplicationController < ActionController::Base
  protect_from_forgery
  
  protected
    def close_players(options = {})
      if options[:except]
        [100, 101, 102, 103].each do |channel|
          unless channel == options[:except]
            Haivision::Cli.close_instream_by_channel(channel) 
            logger.debug("closing channel: #{channel}")
          end
        end
      elsif options[:only]
        Haivision::Cli.close_instream_by_channel(options[:only]) 
      else
        ip = request.ip == '127.0.0.1' ? '10.1.50.103' : request.ip
        Haivision::Cli.close_instream_by_ip(ip)
      end
    end
end
