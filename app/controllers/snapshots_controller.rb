class SnapshotsController < ApplicationController
  before_filter :get_channel, :only => :create
  before_filter :get_snapshot, :except => :create
  
  def show
    send_file(@snapshot.full_path)
  end

  def create
    encoder = Haivision::Encoder.new(@channel.ip)
    @snapshot = Snapshot.create(:filename => encoder.take_snapshot(Snapshot.base_path))
  end

  def destroy
    @snapshot.destroy

    respond_to do |format|
      format.html { redirect_to(snapshots_url) }
      format.xml  { head :ok }
    end
  end
  
  protected
    def get_channel
      @channel = Channel.find(params[:channel_id])
    end
    
    def get_snapshot
      @snapshot = Snapshot.find(params[:id])
    end
end
