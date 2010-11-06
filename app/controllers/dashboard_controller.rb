class DashboardController < ApplicationController
  def index
    if request.post?
      redirect_to '/dashboard'
      return false
    end
    @channel = Channel.find(params[:channel_id] || :first)
    open_channel(@channel.number)
  end
  
  def login
  end
  
  def multiview
    @channel = Channel.new
    close_players
    render :index
  end

end
