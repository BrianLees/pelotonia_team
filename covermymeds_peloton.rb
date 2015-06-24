require 'sinatra'
require 'json'

helpers do
  def link(url, text, popup=false)
    target = popup ? ' target="_blank"' : ''
    "<a href=\"#{url}\"#{target}>#{text}</a>"
  end

  def to_cash(number)
    number_parts = number.to_s.split('.')
    number_parts[0] = number_parts.first.reverse.gsub(/...(?=.)/,'\&,').reverse
    number_parts[1] = "00"
    "$#{number_parts.join('.')}"
  end

  def cash_to_float(number)
    number.gsub(/\$|\,/,'').to_f
  end
end

get '/' do
  team_data = JSON.parse(File.read("data/pelotonia_peloton.json"))
  team_member_data = JSON.parse(File.read("data/pelotonia_team.json"))
 
  erb :peloton_info, :locals => {:team_data => team_data, :team_member_data => team_member_data}
end
