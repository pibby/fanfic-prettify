require 'bundler/setup'
require 'sinatra'
require 'slim'
require 'nokogiri'
require 'open-uri'

def fetch_story(id)
  @base_url = "https://www.fanfiction.net/s/#{id}/"
  story = Nokogiri::HTML(open(@base_url))
  if story.at_css('#chap_select')
    last_page = Integer(story.at_css('#chap_select option:last-of-type').attr('value')) # find out how many pages are in the story
  else
    last_page = 1 # if only 1 chapter
  end
  title = story.css('link[rel=canonical]')[0]['href'].split('/').last # grab the hyphen delineated title
  @full_title = title.gsub('-',' ') # replace the hyphens with spaces
  @author = story.css('#profile_top a')[0].text # get the author's username
  @full_story = ""
  # Grab the story content from each page
  for page_num in 1..last_page
    page = Nokogiri::HTML(open("#{@base_url}#{page_num}"))
    content = page.css("div#storytext")
    @full_story += content.to_s
  end
end

get '/' do
  slim :home
end

post '/' do
  story_id = params[:story_id]
  redirect to "/#{story_id}"
end

get '/:story_id' do
  fetch_story(params[:story_id])
  response.headers['Cache-Control'] = 'public, max-age=259200' # cache for 72 hours
  slim :index
end