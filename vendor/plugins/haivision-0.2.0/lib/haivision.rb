require 'rubygems'
require 'rest_client'
require 'nokogiri'
require 'apiserver'

require File.dirname(__FILE__) + '/haivision/recording'
require File.dirname(__FILE__) + '/haivision/error'
require File.dirname(__FILE__) + '/haivision/metadata'
require File.dirname(__FILE__) + '/haivision/hotmark'
require File.dirname(__FILE__) + '/haivision/recorder'
require File.dirname(__FILE__) + '/haivision/cli'
require File.dirname(__FILE__) + '/haivision/encoder'
require File.dirname(__FILE__) + '/haivision/review'

module Haivision
  API = Apiserver.url if Apiserver.url
end
