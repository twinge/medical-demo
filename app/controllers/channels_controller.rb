class ChannelsController < ApplicationController
  def show
    @channel = Channel.find(params[:id])
    close_players(:except => @channel.number)
    render 'dashboard/index'
  end
end
