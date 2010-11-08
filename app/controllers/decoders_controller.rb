require 'net/ssh'
class DecodersController < ApplicationController
  def show
    @decoder = Decoder.find(params[:id])
    @channel = Channel.find(params[:channel_id])
    @message = "Now streaming #{@channel.title} to #{@decoder.title}"
    Net::SSH.start( @decoder.address, 'admin', :password => 'manager' ) do|ssh|
      start_id = @channel.id
      stop_id = start_id == 1 ? 2 : 1
      result = ssh.exec!("stream #{stop_id} stop")
      logger.debug("stream #{stop_id} stop")
      logger.debug(result)
      logger.debug("stream #{start_id} start")
      result = ssh.exec!("stream #{start_id} start")
      logger.debug(result)
    end
  end
end
