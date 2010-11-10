require 'nokogiri'
require 'rest_client'
module Haivision
  class Recorder
    attr_accessor :id, :service, :is_recording
    
    def initialize(xml)
      @id = xml.xpath('//id').text
      @service = xml.xpath('//service').text
      @is_recording = xml.xpath('//isRecording').text
      @links = {:self => xml.xpath('//link[@rel = "self"]').attr('href').value,
                :publishes => xml.xpath('//link[@rel = "publishes"]').attr('href').value,
                :reviews => xml.xpath('//link[@rel = "reviews"]').attr('href').value}
    end
    
    def self.is_recording?(id)
      endpoint = Haivision::API + "/recorders/recorder-#{id}"
      response = RestClient.get(endpoint, :content_type => 'application/xml')
      puts "Response:"
      puts response.body
      begin
        raise '' unless response.code == 200
        r = self.new(Nokogiri::XML(response.body))
        return r.is_recording?
      rescue => e
        Error.create(response, e)
      end
    end
    
    def is_recording?
      is_recording.to_i == 1
    end
    
    def self.all
      endpoint = Haivision::API + "/recorders"
      response = RestClient.get(endpoint, :content_type => 'application/xml')
      puts "Response:"
      puts response.body
      doc = Nokogiri::XML(response.body)
      recordings = doc.xpath('//recorder').collect {|r| self.new(r)}
    end
    
    def self.first_available
      all.each do |recorder|
        return recorder unless recorder.is_recording?
      end
      return nil
    end
    
  end
  
end