class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  
  require 'discogs'
  require 'google/api_client'
  require 'json'
  
  def index
  end
  
  def search
  	@name = params[:query]
  	
  	if @name != nil
  		# CREATE SERVER KEY FOR YOUTUBE DATA API AND PUT IT IN THE KEY FIELD BELOW (https://console.developers.google.com/)
  												
  												   
  												   
  		google = Google::APIClient.new(:key => "AIzaSyAxCzzM8PRq40A_oxqIT-1scHB92nM2sYg", :application_name => "project480", :application_version => "1.0", :authorization => nil)
  		youtube = google.discovered_api("youtube", "v3")
  		@discogs = Discogs::Wrapper.new("project480", {:access_token => session[:access_token], :app_key => "nQsyksXWTamTUxoydLOe", :app_secret => "pPIESeToctrtSfMSjoUYknPAVbPsHbdG"})
    	@links = Hash.new(0)
    	
    	# search discogs for artist and get releases
    	results = @discogs.search(@name, :type => :artist)
    	artist = results[:results][0][:id]
    	albums = @discogs.get_artists_releases(artist)
    	
    	# iterate through releases and get videos
    	albums[:releases].each do |album|
    		search = google.execute(:api_method => youtube.search.list, :parameters => {:part => "id", :q => "#{@name} #{album[:title]} full album", :maxResults => 1, :type => "video"})
    		video = JSON.parse(search.data.to_json)
    		if video["items"][0] != nil
    			@links["#{album[:title]}"] = "https://www.youtube.com/embed/#{video["items"][0]["id"]["videoId"]}"
    		else
    			@links["#{album[:title]}"] = nil
    		end
    	end
  	end
  end
end

