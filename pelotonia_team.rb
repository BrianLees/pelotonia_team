require 'mechanize'
require 'json'

member_data = Array.new
team_data = Hash.new
agent = Mechanize.new

pelotonia_date = Date.new(2015,8,8)
days = (pelotonia_date - Date.today).to_i

page = agent.get("https://www.mypelotonia.org/team_profile.jsp?MemberID=311516")

#Get Team information
#team_info = page.search("div.dashboard-status dl").map(&:text).map{ |i| i.gsub(/\s/, '')}
team_info = page.search("div.dashboard-status dl").map(&:text)

team_data[:peloton_funds] = team_info[0].split(':').last.strip.squeeze(' ')
team_data[:total_of_all_members] = team_info[1].split(':').last.strip.squeeze(' ')
team_data[:grand_total_raised] = team_info[2].split(':').last.strip.squeeze(' ')
team_data[:captain] = team_info[3].split(':').last.strip.squeeze(' ')
team_data[:days_until] = days

#Get Peloton members
member_links = page.links_with(:href => /riders_profile/)

member_links.each do |member_link|
  member_info = Hash.new
  member_info[:name] = member_link.text.strip.squeeze(' ')
  member_info[:link] = member_link.uri.to_s

  member_page = member_link.click
  rider_info = member_page.search("div.dashboard-status dl").map(&:text)
  story = member_page.search("div.story").map(&:text)
  goal = member_page.search("td.label").map(&:text).last

  if rider_info.length > 2
    member_info[:route] = rider_info[0].split(':').last.strip.squeeze(' ')
    member_info[:raised] = rider_info[1].split(':').last.strip.squeeze(' ')
    member_info[:type] = 'Rider'
  else
    member_info[:route] = 'N/A'
    member_info[:raised] = rider_info[0].split(':').last.strip.squeeze(' ') 
    member_info[:finished] = 'N/A'
    member_info[:type] = 'Virtual Rider'
  end

  member_info[:story] = story.include?("(no story on file)") ? "Not completed" : "Completed"
  member_info[:goal] = goal.nil? ? 'N/A' : goal.split(':').last.strip.squeeze(' ')
  if member_info[:goal].include?('Congrats')
    member_info[:goal] = member_info[:goal].split(' ').first
    member_info[:finished] = 'yes'
  else
    member_info[:finished] = 'no'
  end

  member_data << member_info
end
member_data.uniq!

File.open('pelotonia_peloton.json', 'w') do |file|
  file.write(team_data.to_json)
end

File.open('pelotonia_team.json', 'w') do |file|
  file.write(member_data.to_json)
end

#page.at #single
#page.search #multiple

# Command to get just commands from IRB and not output
# ReadLine::HISTORY.entries.split("exit").last[0..-2].join("\n")
