module Haivision
  class Error
    attr_accessor :response, :message
    
    def initialize(response, message = nil)
      @response = response
      @message = message
      if response
        xml = Nokogiri::XML(response.body)
        @message = response.body if @message.nil? || @message == ''
      end
    end
    
    def self.create(response, e = nil)
      message = e ? (e.is_a?(String) ? e : e.message) : ''
      [false, Error.new(response, message)]
    end
  end
  
end