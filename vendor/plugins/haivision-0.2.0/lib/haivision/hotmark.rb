require 'nokogiri'
require 'rest_client'
module Haivision
  class Hotmark
    attr_accessor :id, :time, :title, :type, :links
    
    def initialize(xml)
      @id = xml.xpath('//id').text
      @time = xml.xpath('//time').text
      @title = xml.xpath('//title').text
      @type = xml.xpath('//type').text
      @links = {:self => xml.xpath('//link[@rel = "self"]').attr('href').value,
                :recorder => xml.xpath('//link[@rel = "self"]').attr('href').value,
                :hotmarks => xml.xpath('//link[@rel = "self"]').attr('href').value,
                :publishes => xml.xpath('//link[@rel = "self"]').attr('href').value,
                :reviews => xml.xpath('//link[@rel = "self"]').attr('href').value}
    end
    
    def self.create(link, title, type = 'TAG', time = nil)
      max_duration ||= 86399
      endpoint = link + '/hotmarks'
      puts "Calling: " + endpoint
      xml = "<hotmark>"
      xml += "<time>#{time}</time>" if time
      xml += "<title>#{title}</title><type>#{type}</type></hotmark>"
      puts xml
      response = RestClient.post(endpoint, xml, :content_type => 'application/xml')
      puts "Response:"
      puts response.body
      begin
        raise '' unless response.code == 201
          [true, Nokogiri::XML(response.body).xpath('//link[@rel = "recording"]').attr('href')] # link
      rescue => e
        Error.create(response, e)
      end
    end
    
  end
  
end