require 'rubygems'
require 'bundler/setup'
require 'open-uri'
require 'json'

# require your gems as usual
require 'nokogiri'

f = File.read("paths.txt")
data = JSON::parse(f)
@paths_to_visit = ["a.html"] + data["to_visit"].to_a
@paths_visited = data["visited"].to_a

def add_new_path(path)
  path.gsub!(/#.+/,"")
  unless @paths_visited.include?(path) || @paths_to_visit.include?(path)
    @paths_to_visit.push path
  end
end

def visit_path(path, file, titles_file)
  sleep 1
  puts "Visiting: '#{path}'"
  page_object = Nokogiri::HTML open("http://www.darklyrics.com/#{path}")
  links = page_object.css('.artists a')
  links.each do |link|
    path = link['href']
    add_new_path(path)
  end
  albums = page_object.css('.album a')
  albums.each do |link|
    path = link['href'].sub("../",'')
    add_new_path(path)
  end
  albums = page_object.css('.album h2 strong')
  albums.each do |album|
    puts album.content
  end
  lyric_titles = page_object.css('.lyrics h3 a')
  lyric_titles.each do |title|
    real_title = title.content.gsub(/\d+\. /,'')
    titles_file.write "#{real_title}\n"
    puts "Title: #{real_title}"
  end
  lyrics = page_object.css('.lyrics')
  lyrics.each do |lyric|
    clean_content = lyric.content
    clean_content.gsub!(/^\s*$/,'') #remove empty lines
    clean_content.gsub!(/^\d+\. .*$/,'') #remove title
    clean_content.gsub!(/^\[.*\]$/,'') #remove notes
    puts clean_content
    file.write clean_content
  end
end


loop do
  titles_file = File.open("titles.txt","a")
  file = File.open("lyrics.txt","a")
  next_path = @paths_to_visit.pop
  visit_path(next_path, file, titles_file)
  file.close
  titles_file.close
  File.open("paths.txt", "w") do |f|
    data = {"to_visit" => @paths_to_visit, "visited" => @paths_visited}
    f.write data.to_json
  end
end
