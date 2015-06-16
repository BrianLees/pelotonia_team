require 'mechanize'
require 'csv'

agent = Mechanize.new

page = agent.get("https://www.mypelotonia.org/team_profile.jsp?MemberID=311516")

#Get Team information
#team_info = page.search("div.dashboard-status dl").map(&:text).map{ |i| i.gsub(/\s/, '')}
team_info = page.search("div.dashboard-status dl").map(&:text)

#Get Peloton members
member_links = page.links_with(:href => /riders_profile/)

member_data = Array.new
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
    member_info[:type] = 'Virtual Rider'
  end

  member_info[:story] = story.include?("(no story on file)") ? "Not completed" : "Completed"
  member_info[:goal] = goal.split(':').last.strip.squeeze(' ') unless goal.nil?

  member_data << member_info
end
member_data.uniq!

#File.open('pelotonia_team.csv', 'w'){ |file| member_data.map{ |record| file << record.to_csv } }
File.open('pelotonia_team.csv', 'w') do |file|
  file << member_data.first.keys.to_csv

  member_data.each do |team_member_data|
    file << team_member_data.values.to_csv
  end
end

#page.at #single
#page.search #multiple

# Command to get just commands from IRB and not output
# ReadLine::HISTORY.entries.split("exit").last[0..-2].join("\n")
