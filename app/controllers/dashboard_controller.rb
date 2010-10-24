class DashboardController < ApplicationController
  def index
    if request.post?
      redirect_to '/dashboard'
      return false
    end
    @channel = Channel.find(params[:channel_id] || :first)
    close_players(:except => @channel.number)
  end
  
  def login
  end

end
