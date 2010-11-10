module Haivision

  class Metadata
    attr_accessor :title, :description
    
    def initialize(xml = nil)
      if xml
        @title = xml.css('title').text
        @description = xml.css('description').text
      end
    end
  end
  
end