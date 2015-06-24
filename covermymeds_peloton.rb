require 'sinatra'
require 'json'

helpers do
  def link(url, text, popup=false)
    target = popup ? ' target="_blank"' : ''
    "<a href=\"#{url}\"#{target}>#{text}</a>"
  end
end

get '/' do
  team_data = JSON.parse(File.read("pelotonia_peloton.json"))
  team_member_data = JSON.parse(File.read("pelotonia_team.json"))
 
  erb :peloton_info, :locals => {:team_data => team_data, :team_member_data => team_member_data}
end
