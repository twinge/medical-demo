#!/usr/bin/env ruby
require 'haivision'
require 'rubygems'
require 'json'
require 'eventmachine'
require 'apiserver'

module HaiServer# < EventMachine::Connection
  def post_init
    puts "-- someone connected to the server"
  end


  def unbind
    puts "-- someone disconnected from the server"
  end
 
  def receive_data(data)
    command = data.strip
    close_connection if command =~ /quit/i
    begin
      puts command
      send_data call_api(command) unless command == ''
    rescue Exception => e
      # The server blew up... handle it here
      puts e.message
      puts e.backtrace.join("\n")
      send_data "{\"response\": \"error\", \"message\": \"#{e}\"}"
    end
  end
  
  def call_api(input)
    raise 'quit' if input == 'quit'
    # input = input.gsub(/[']/, '\\\\\'')
    # input = input.gsub(/'/,'').inspect
    command = JSON.parse(input)
    command_array = command.is_a?(Array) ? command : [command]
    response = command_array.collect do |command|
                  case command['action']
                  when 'start'
                    if Apiserver.test
                      '{"response":"success","link":"http://192.168.59.240/apis/recorders/recorder-' + command['recorder_id'].to_s + '/recordings/recording-99fe1d68-9ed6-4813-883b-1044f77a6b63"}'
                    else
                      success, link = Haivision::Recording.start(command['source_url'], command['title'], command['description'], command['recorder_id'], command['max_duration'])
                      success ? '{"response":"success","link":"' + link + '"}' : '{"response":"error","message":"' + link.message + '"}'
                    end
                  when 'stop'
                    if Apiserver.test
                      '{"response":"success"}' 
                    else
                      success, message = Haivision::Recording.stop(command['link'])
                      success ? '{"response":"success"}' : '{"response":"error","message":"' + message + '"}'
                    end
                  when 'publish'
                    if Apiserver.test
                      '{"response":"success","link":"http://192.168.59.240/apis/recorders/recorder-' + command['recorder_id'].to_s + '/recordings/recording-99fe1d68-9ed6-4813-883b-1044f77a6b63"}'
                    else
                      success, link = Haivision::Recording.publish(command['link'])
                      success ? '{"response":"success","link": "' + link + '"}' : '{"response":"error", "message":"' + link + '"}'
                    end
                  when 'hotmark'
                    if Apiserver.test
                      '{"response":"success","link":"http://192.168.59.240/apis/recorders/recorder-' + command['recorder_id'].to_s + '/recordings/recording-99fe1d68-9ed6-4813-883b-1044f77a6b63"}'
                    else
                      success, link = Haivision::Hotmark.create(command['link'], command['title'], command['type'], command['time'])
                      success ? '{"response":"success","link":"' + link + '"}' : '{"response":"error","message": "' + link + '"}'
                    end
                  else
                    '{"response":"error","message":"Invalid action"}'
                  end
                end
    # only return an array if an array of commands was sent
    if response.length > 1
      '[' + response.join(',') + ']'
    else
      response[0]
    end
  end
  
end

