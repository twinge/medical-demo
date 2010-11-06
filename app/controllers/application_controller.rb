class ApplicationController < ActionController::Base
  before_filter :check_active_recording
  protect_from_forgery
  
  protected
    def open_channel(channel)
      if session[:active_channel] != channel || params[:force] == 'true'
        @open_player = true
        close_players(:except => channel)
      end
    end
    def close_players(options = {})
      begin
        if options[:only]
          Haivision::Cli.close_instream_by_channel(options[:only]) 
        else
          [100, 101, 102, 103].each do |channel|
            unless channel == options[:except]
              Haivision::Cli.close_instream_by_channel(channel) 
              logger.debug("closing channel: #{channel}")
            end
          end
          session[:active_channel] = options[:except]
          # ip = request.ip == '127.0.0.1' ? '10.1.50.103' : request.ip
          # Haivision::Cli.close_instream_by_ip(ip)
        end
      # rescue
      end
    end
    
    def check_active_recording
      if session[:active_recording]
        recording = Haivision::Recording.find(session[:active_recording])
        if recording.nil? || !recording.recording?
          session[:active_recording] = nil 
        end
      end
    end
end
