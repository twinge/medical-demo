require 'nokogiri'
require 'rest_client'
module Haivision
  class Review
    attr_accessor :id, :output_url, :links
        
    def initialize(xml = nil)
      if xml
        @id = xml.xpath('//id').text
        @output_url = xml.xpath('//outputUrl').text
        begin
          @links = {:self => xml.xpath('//link[@rel = "self"]').attr('href').value,
                    :review => xml.xpath('//link[@rel = "recording"]').attr('href').value}
        rescue
          @links = {:review => xml.xpath('//link[@rel = "recording"]').attr('href').value}
        end
      else
        @links = {}
      end
    end
  
    def self.all(link)
      response = RestClient.get(link + "/reviews", :content_type => 'application/xml')
      begin
        raise '' unless response.code == 200
        xml_doc = Nokogiri::XML(response.body)
        reviews_xml = xml_doc.root.children.first
        reviews = reviews_xml.children.collect do |review_xml|
          Review.new(review_xml)
        end
        reviews
      rescue => e
        Error.create(response, e)
      end
    end

    def stop
      response = RestClient.post(link, :content_type => 'application/xml')
      response.code == 200 ? true : Error.create(response)
    end
  end
end