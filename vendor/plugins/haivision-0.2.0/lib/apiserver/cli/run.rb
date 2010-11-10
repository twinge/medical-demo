module Apiserver
  module CLI
    
    class Run
      def initialize(options)
        @options = options
        
        dispatch
      end
      
      def dispatch
        # have at_exit start apiserver
        $run = true
        
        if @options[:syslog]
          require 'apiserver/sys_logger'
        end
        
        # run
        if @options[:daemonize]
          run_daemonized
        else
          run_in_front
        end
      end
      
      def default_run
        # make sure we have STDIN/STDOUT redirected immediately
        setup_logging
        
        Apiserver.port = @options[:port] if @options[:port]
        Apiserver.url = @options[:url] if @options[:url]
        Apiserver.test = @options[:test]
        Apiserver.address = @options[:address]
        
        # set log level, defaults to WARN
        if @options[:log_level]
          Apiserver.log_level = @options[:log_level]
        else
          Apiserver.log_level = @options[:daemonize] ? :warn : :info
        end
        
        if @options[:config]
          if !@options[:config].include?('*') && !File.exist?(@options[:config])
            abort "File not found: #{@options[:config]}"
          end
          
          # start the event handler
          Apiserver::EventHandler.start if Apiserver::EventHandler.loaded?
          
          load_config @options[:config]
        end
        setup_logging
        require 'hai_server'
        require 'eventmachine'
        LOG.info("Running on port #{Apiserver.port}")
        LOG.info("Bound to #{Apiserver.address}")
        EventMachine::run {
          EventMachine::start_server Apiserver.address, Apiserver.port, HaiServer
        }
      end
      
      def run_in_front
        require 'apiserver'
        
        default_run
      end
      
      def run_daemonized
        # trap and ignore SIGHUP
        Signal.trap('HUP') {}
        
        pid = fork do
          begin
            require 'apiserver'
            
            # set pid if requested
            if @options[:pid] # and as deamon
              Apiserver.pid = @options[:pid] 
            end
            
            default_run
            
          rescue => e
            puts e.message
            puts e.backtrace.join("\n")
            abort "There was a fatal system error while starting apiserver (see above)"
          end
        end
        
        if @options[:pid]
          File.open(@options[:pid], 'w') { |f| f.write pid }
        end
        
        ::Process.detach pid
        
        exit
      end
      
      def setup_logging
        log_file = Apiserver.log_file
        log_file = File.expand_path(@options[:log]) if @options[:log]
        log_file = "/dev/null" if !log_file && @options[:daemonize]
        if log_file
          puts "Sending output to log file: #{log_file}" unless @options[:daemonize]
          
          # reset file descriptors
          STDIN.reopen "/dev/null"
          STDOUT.reopen(log_file, "a")
          STDERR.reopen STDOUT
          STDOUT.sync = true
        end
      end
      
      def load_config(config)
        files = File.directory?(config) ? Dir['**/*.apiserver'] : Dir[config]
        abort "No files could be found" if files.empty?
        files.each do |apiserver_file|
          unless load_apiserver_file(apiserver_file)
            abort "File '#{apiserver_file}' could not be loaded"
          end
        end
      end
      
      def load_apiserver_file(apiserver_file)
        applog(nil, :info, "Loading #{apiserver_file}")
        load File.expand_path(apiserver_file)
        true
      rescue Exception => e
        if e.instance_of?(SystemExit)
          raise
        else
          puts "There was an error in #{apiserver_file}"
          puts "\t" + e.message
          puts "\t" + e.backtrace.join("\n\t")
          false
        end
      end
      
    end # Run
    
  end
end