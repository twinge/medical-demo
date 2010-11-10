require 'rubygems'
require "test/unit"
require 'haivision'
require 'shoulda'
require 'mocha'
# require 'ruby-debug'
Haivision::API = 'http://1.2.3.4/apis'

class TestHaivision < Test::Unit::TestCase
  class MyAbstractResponse

    include RestClient::AbstractResponse

    attr_accessor :args, :body, :net_http_res

    def initialize net_http_res, args
      @net_http_res = net_http_res
      @args = args
    end

  end
  
  context "the haivision lib" do 
    setup do
      @api = 'https://test.haivision.fake'
      @net_http_res = mock('net http response')
      @response = MyAbstractResponse.new(@net_http_res, {})
      @recording_link = 'http://1.2.3.4/apis/recorders/recorder-003018aafe23-4909-0/recordings/recording-99fe1d68-9ed6-4813-883b-1044f77a6b63'
      @publish_link = 'http://1.2.3.4/apis/recorders/recorder-003018aafe23-4909-0/recordings/recording-99fe1d68-9ed6-4813-883b-1044f77a6b63'
    end
    
    context "when working with recordings" do
      should "return a list of recordings" do
        @response.body = fixture('responses.xml')
        RestClient.expects(:get).returns(@response)
        @response.expects(:code).returns(200)
        success, recordings = Haivision::Recording.all
        assert_equal(true, success)
        assert_equal(1, recordings.length)
      end
      
      should "start a recording" do
        @response.body = fixture('link.xml')
        RestClient.expects(:post).returns(@response)
        @response.expects(:code).returns(200)
        success, link = Haivision::Recording.start("tcp://10.1.3.112:4968", 1, 86399, 'Test Title', 'Test Description')
        assert_equal(true, success)
        assert_equal(@recording_link, link)
      end
      
      should "stop a recording" do
        RestClient.expects(:post).returns(@response)
        @response.expects(:code).returns(200)
        success = Haivision::Recording.stop(@recording_link)
        assert_equal(true, success)
      end
      
      should "publish a recording" do
        @response.body = fixture('link.xml')
        RestClient.expects(:post).returns(@response)
        @response.expects(:code).returns(202)
        success, link = Haivision::Recording.publish(@recording_link)
        assert_equal(true, success)
        assert_equal(@publish_link, link)
      end
    end
  end
  
  def fixture(filename)
    File.read(File.dirname(__FILE__) + "/fixtures/#{filename}").gsub(/>\s*\n\s*</,'><')
  end
end
