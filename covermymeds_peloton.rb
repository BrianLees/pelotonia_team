require 'sinatra'
require 'json'

get '/' do
  team_data = JSON.parse(File.read("pelotonia_peloton.json"))
  team_member_data = JSON.parse(File.read("pelotonia_team.json"))
 
  erb :peloton_info, :locals => {:team_data => team_data, :team_member_data => team_member_data}
end
