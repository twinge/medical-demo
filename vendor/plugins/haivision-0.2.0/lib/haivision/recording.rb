require 'nokogiri'
require 'rest_client'
module Haivision
  class Recording
    attr_accessor :id, :source_url, :state, :duration, :max_duration, :progress, :metadata, :links
    
    def initialize(xml = nil)
      if xml
        @id = xml.xpath('//id').text
        @source_url = xml.xpath('//sourceUrl').text
        @state = xml.xpath('//state').text
        @duration = xml.xpath('//duration').text
        @max_duration = xml.xpath('//maxDuration').text
        @progress = xml.xpath('//progress').text
        @metadata = Metadata.new(xml.xpath('//metadata'))
        @links = {:self => xml.xpath('//link[@rel = "self"]').attr('href').value,
                  :recorder => xml.xpath('//link[@rel = "recorder"]').attr('href').value,
                  :hotmarks => xml.xpath('//link[@rel = "hotmarks"]').attr('href').value,
                  :publishes => xml.xpath('//link[@rel = "publishes"]').attr('href').value,
                  :reviews => xml.xpath('//link[@rel = "reviews"]').attr('href').value}
      else
        @metadata = Metadata.new
        @links = {}
      end
    end
    
    def self.start(source_url, title = nil, description = nil, recorder_id = nil, max_duration = nil)
      if recorder_id && Recorder.is_recording?(recorder_id)
        return Error.create(nil, 'There is already a recording in progress.')
      end
      
      # if no recorder id was passed in, pick the first available recorder
      if recorder_id.nil? && recorder = Recorder.first_available
        recorder_id = recorder.id
      else
        return Error.create(nil, 'There are no recorders available. Please stop one of your other active recordings.')
      end
      
      max_duration ||= 86399
      title ||= "Recording Started " + Time.now.to_s(:long)
      description ||= title.dup
      endpoint = Haivision::API + "/recorders/recorder-#{recorder_id}/recordings"
      puts "Calling: " + endpoint
      xml = "<recording><sourceUrl>#{source_url}</sourceUrl><maxDuration>#{max_duration}</maxDuration><metadata><title>#{title}</title><description>#{description}</description></metadata></recording>"
      puts xml
      response = RestClient.post(endpoint, xml, :content_type => 'application/xml')
      puts "Response:"
      puts response.body
      begin
        raise '' unless response.code == 201
        [true, Nokogiri::XML(response.body).xpath('//link[@rel = "recording"]').attr('href').value] # link
      rescue => e
        Error.create(response, e)
      end
    end
    
    def self.update(link, attributes = {})
      attributes[:max_duration] ||= 86399
      xml = "<recording>"
      xml += "<maxDuration>#{attributes[:max_duration]}</maxDuration>" #if attributes[:max_duration]
      if attributes[:title] || attributes[:description]
        xml += '<metadata>'
        xml += "<title>#{attributes[:title]}</title>" if attributes[:title]
        xml += "<description>#{attributes[:description]}</description>" if attributes[:description]
        xml += '</metadata>'
      end
      xml += "</recording>"
      puts xml
      puts link
      response = RestClient.put(link, xml, :content_type => 'application/xml')
      puts "Response:"
      puts response.body
      begin
        raise '' unless response.code == 200
        [true, Nokogiri::XML(response.body).xpath('//link[@rel = "recording"]').attr('href').value] # link
      rescue => e
        Error.create(response, e)
      end
    end
    
    def self.stop(link)
      response = RestClient.delete(link, :content_type => 'application/xml')
      response.code == 200 ? true : Error.create(response)
    end
    
    def self.publish(link)
      puts "Calling: " + link + '/publishes'
      tries = 3
      response = nil
      begin
        tries -= 1
        response = RestClient.post(link + '/publishes', '', :content_type => 'application/xml')
      rescue
        sleep(1)
        retry if tries > 0
      end
      if response
        puts "Response:"
        puts response.body
        begin
          raise '' unless response.code == 202
          [true, Nokogiri::XML(response.body).xpath('//link[@rel = "recording"]').attr('href').value] # link
        rescue => e
          Error.create(response, e)
        end
      else
        Error.create(nil, 'Publish failed')
      end
    end
    
    def self.review(link)
      puts "Calling: " + link + '/reviews'
      tries = 3
      response = nil
      begin
        tries -= 1
        response = RestClient.post(link + '/reviews', '', :content_type => 'application/xml')
        puts response.inspect
      # rescue
      #   sleep(1)
      #   retry if tries > 0
      end
      if response
        puts "Response:"
        puts response.body
        begin
          raise '' unless response.code == 201
          @review = Review.new(Nokogiri::XML(response.body))
          [true, @review.output_url] # link
        # rescue => e
        #   Error.create(response, e)
        end
      else
        Error.create(nil, 'Review failed')
      end
    end
    
    def reviews
      Review.all(links[:self])
    end
    
    def self.all(recorder_id)
      response = RestClient.get(Haivision::API + "/recorders/recorder-#{recorder_id}/recordings", :content_type => 'application/xml')
      begin
        raise '' unless response.code == 200
        xml_doc = Nokogiri::XML(response.body)
        recordings_xml = xml_doc.root.children.first
        recordings = recordings_xml.children.collect do |recording_xml|
          Recording.new(recording_xml)
        end
        [true, recordings]
      rescue => e
        Error.create(response, e)
      end
    end
    
    def self.find(id)
      begin
        response = RestClient.get(Haivision::API + "/recorders/recorder-00018079c78d-4909-0/recordings/recording-#{id}", :content_type => 'application/xml')
        xml = Nokogiri::XML(response.body)
        self.new(xml.xpath('//recording'))
      rescue => e
        return nil
      end
    end
    
    def self.find_by_link(link)
      response = RestClient.get(link, :content_type => 'application/xml')
      xml = Nokogiri::XML(response.body)
      self.new(xml.xpath('//recording'))
    end
    
    def title() metadata ? metadata.title : ''; end
    def description() metadata ? metadata.description : ''; end
    
    def recording?
      state == 'RECORDING'
    end
    
    def recorded?
      state == 'RECORDED'
    end
    
    def stop!
      Recording.stop(self.links[:self])
    end
    
    def publish!
      Recording.publish(self.links[:self])
    end
    
    def review
      Recording.review(self.links[:self])
    end
    
    def update!(attribs)
      Recording.update(self.links[:self], attribs)
    end
  end
  
end