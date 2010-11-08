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
    @channels = Channel.find_all_by_number([params[:m_endo], params[:m_room]])
    # close_players
    render :index
  end

end
