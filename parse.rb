require 'bundler/setup'
require 'sinatra'
require 'slim'
require 'nokogiri'
require 'open-uri'

def fetch_story(id)
  @base_url = "https://www.fanfiction.net/s/#{id}/"
  story = Nokogiri::HTML(open(@base_url))
  last_page = Integer(story.at_css('#chap_select option:last-of-type').attr('value')) # find out how many pages are in the story
  title = story.css('link[rel=canonical]')[0]['href'].split('/').last # grab the hyphen delineated title
  @full_title = title.gsub('-',' ') # replace the hyphens with spaces
  @author = story.css('#profile_top a')[0].text #get the author's username
  @full_story = ""
  # Grab the story content from each page
  for page_num in 1..last_page
    page = Nokogiri::HTML(open("#{@base_url}#{page_num}"))
    content = page.css("div#storytext")
    @full_story += content.to_s
  end
end

get '/' do
  "Hello, world."
end

get '/:story_id' do
  fetch_story(params[:story_id])
  slim :index
end