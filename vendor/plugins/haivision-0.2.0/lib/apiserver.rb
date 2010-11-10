$:.unshift File.dirname(__FILE__)
require 'apiserver/simple_logger'
require 'apiserver/logger'
require 'apiserver/cli/version'
# App wide logging system
LOG = Apiserver::Logger.new
module Apiserver
  VERSION = '0.1.0'
  LOG_BUFFER_SIZE_DEFAULT = 100
  PID_FILE_DIRECTORY_DEFAULTS = ['/var/run/apiserver', '~/.apiserver/pids']
  SERVER_PORT_DEFAULT = 3010
  LOG_LEVEL_DEFAULT = :info
  TERMINATE_TIMEOUT_DEFAULT = 10
  STOP_TIMEOUT_DEFAULT = 10
  STOP_SIGNAL_DEFAULT = 'TERM'
  
  class << self
    # user configurable
    attr_accessor  :pid,
                   :host,
                   :port,
                   :address,
                   :url,
                   :log_buffer_size,
                   :pid_file_directory,
                   :log_file,
                   :log_level,
                   :test
                       
 end
 
  # initialize class instance variables
  self.pid = nil
  self.host = nil
  self.port = nil
  self.address = nil
  self.url = nil
  self.log_buffer_size = nil
  self.pid_file_directory = nil
  self.log_level = nil
  self.test = nil
  
  # Initialize internal data.
  #
  # Returns nothing
  def self.internal_init
    # only do this once
    return if self.inited
    
    # set defaults
    self.log_buffer_size ||= LOG_BUFFER_SIZE_DEFAULT
    self.port ||= DRB_PORT_DEFAULT
    self.log_level ||= LOG_LEVEL_DEFAULT
    
    # additional setup
    self.setup
    
    # log level
    log_level_map = {:debug => Logger::DEBUG,
                     :info => Logger::INFO,
                     :warn => Logger::WARN,
                     :error => Logger::ERROR,
                     :fatal => Logger::FATAL}
    LOG.level = log_level_map[self.log_level]
    
    # init has been executed
    self.inited = true
    
    # not yet running
    self.running = false
  end
  
  def self.setup
    if self.pid_file_directory
      # pid file dir was specified, ensure it is created and writable
      unless File.exist?(self.pid_file_directory)
        begin
          FileUtils.mkdir_p(self.pid_file_directory)
        rescue Errno::EACCES => e
          abort "Failed to create pid file directory: #{e.message}"
        end
      end
      
      unless File.writable?(self.pid_file_directory)
        abort "The pid file directory (#{self.pid_file_directory}) is not writable by #{Etc.getlogin}"
      end
    else
      # no pid file dir specified, try defaults
      PID_FILE_DIRECTORY_DEFAULTS.each do |idir|
        dir = File.expand_path(idir)
        begin
          FileUtils.mkdir_p(dir)
          if File.writable?(dir)
            self.pid_file_directory = dir
            break
          end
        rescue Errno::EACCES => e
        end
      end
      
      unless self.pid_file_directory
        dirs = PID_FILE_DIRECTORY_DEFAULTS.map { |x| File.expand_path(x) }
        abort "No pid file directory exists, could be created, or is writable at any of #{dirs.join(', ')}"
      end
    end
    
    if Apiserver::Logger.syslog
      LOG.info("Syslog enabled.")
    else
      LOG.info("Syslog disabled.")
    end
    
    applog(nil, :info, "Using pid file directory: #{self.pid_file_directory}")
  end
  
    # Initialize and startup the machinery that makes apiserver work.
  #
  # Returns nothing
  def self.start
    self.internal_init
    
    # mark as running
    self.running = true
    
  end  
  
  def self.version
    Apiserver::VERSION
  end
  
  # To be called on program exit to start apiserver
  #
  # Returns nothing
  def self.at_exit
    self.start
  end
end

# Runs immediately before the program exits. If $run is true,
# start apiserver, if $run is false, exit normally.
#
# Returns nothing
at_exit do
  Apiserver.at_exit if $run
end