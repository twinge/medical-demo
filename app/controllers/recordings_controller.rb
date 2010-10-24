class RecordingsController < ApplicationController
  def new
    @channel = Channel.find(params[:channel_id])
    close_players(:except => @channel.number)
  end
  
  def edit
    
  end
  
  def create
    
  end
  
  def update
    
  end
end
