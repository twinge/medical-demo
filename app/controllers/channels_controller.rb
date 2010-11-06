class ChannelsController < ApplicationController
  def show
    @channel = Channel.find(params[:id])
    open_channel(@channel.number)
    render 'dashboard/index'
  end
end
