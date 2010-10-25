class RecordingsController < ApplicationController
  include Haivision
  before_filter :get_channel, :except => [:edit, :publish, :stop]
  before_filter :get_recording, :only => [:edit, :publish, :stop]
  def new
    @recording = Recording.new
    close_players(:except => @channel.number)
  end
  
  def edit
    @channel = Channel.find_by_source_url(@recording.source_url)
  end
  
  def create
    title = params[:title].present? ? params[:title] : @channel.title
    description = params[:description].present? ? params[:description] : Time.now.to_s(:long)
    success, @link = Recording.start(@channel.source_url, title, description)
    if success
      @recording = Recording.find_by_link(@link)
      session[:active_recording] = @recording.id
      redirect_to edit_recording_path(@recording.id)
    else
      @recording = Recording.new
      flash[:error] = @link.message
      redirect_to :back
    end
  end
  
  def stop
    @recording.stop!
    flash[:confirm] = "Recording has been stopped"
    close_players
    redirect_to edit_recording_path(@recording.id)
  end
  
  def publish
    @recording.publish!
    flash[:confirm] = "Recording has been published"
    redirect_to '/dashboard'
  end
  
  def update
    
  end
  
  protected
    def get_channel
      @channel = Channel.find(params[:channel_id])
    end
    
    def get_recording
      @recording = Recording.find(params[:id])
    end
end
