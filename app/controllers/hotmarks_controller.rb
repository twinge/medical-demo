class HotmarksController < ApplicationController
  include Haivision
  def create
    if params[:type] == 'hotmark'
      @message = "Hotmark created: #{params[:hotmark]}"
      Hotmark.create(params[:link], params[:hotmark])
    else
      Hotmark.create(params[:link], 'Bookmark', 'CHAPTER')
      @message = "Bookmark inserted."
    end
  end

end
