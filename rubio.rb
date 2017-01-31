#!/usr/bin/env ruby
require 'net/http'
require 'date'
# check if working directory exists, create it if not
$work_dir = File.join(Dir.home, ".rubio")
Dir.mkdir($work_dir) unless File.exists?($work_dir)
# check if streams file exists, download it if not
streams_url = URI('https://raw.githubusercontent.com/lemybeck/bash-bbc-radio/master/radio_streams')
unless File.exists?($work_dir+"/radio_streams")
  Net::HTTP.start(streams_url.host, streams_url.port, :use_ssl => streams_url.scheme == 'https') do |http|
    resp = http.get streams_url
    open($work_dir+"/radio_streams", "w") do |file|
      file.write(resp.body)
    end
  end
end
$streams = $work_dir+"/radio_streams"

def nownext(arg1,arg2,arg3)
  linenum = 0
  progs = 0
  # get schedule file
  stations = File.open($streams)
  stations.each do |line|
    linenum = $. if line.downcase.include?('[*') && line.downcase.include?(arg1)
    break if linenum != 0
  end
  schedule_url = URI.parse(URI.encode(stations.each_line.take(2).last.strip))
  Net::HTTP.start(schedule_url.host, schedule_url.port) do |http|
    Dir.chdir($work_dir) do
      schedule = http.get schedule_url
      # count the number of programmes today
  #     schedule.body.each_line do |line|
  #       progs = progs + 1 if line.include?('- is_repeat:')
  #     end
      # make an array containing a hash for each programme in schedule
      $progs = []
      regex_starts = / start: "(.{20})"/
      regex_ends = / end: "(.{20})"/
      regex_synopsis = / short_synopsis: "(.*?)"/
      regex_title = / display_titles:\s*title: "(.*?)"/
      regex_subtitle = / subtitle: "(.*?)"/
      regex_scanner = /(?:#{regex_starts})|(?:#{regex_ends})|(?:#{regex_synopsis})|(?:#{regex_title})|(?:#{regex_subtitle})/m
      schedule.body.split('- is_repeat').drop(1).each do |programme|
        match = programme.scan(regex_scanner).flatten.compact
  #       puts match[1]
        prog = Hash.new
        prog['starts'] = match[0]
        prog['ends'] = match[1]
        prog['synopsis'] = match[2]
        prog['title'] = match[3]
        prog['subtitle'] = match[4]
        $progs.push prog
      end
    
    end
  end 
  # find first instance of end time after now_or_playing
  $progs.compact.each do |prog|
    $now_playing = $progs.index( prog )
    break if ( DateTime.parse(prog['ends']) > DateTime.now )
  end
  
  puts $progs[$now_playing][arg2]

end
nownext(ARGV[0],ARGV[1],'')

    

  # split file into individual programmes
  
  # for each programme:
  # get start time
  # get end time
  # if n > 0
    # print times and title
  # if on now
    # print title, subtitle, synopsis
# end
# 
# streams = "/home/freds/bin/bbc_streams.txt"
# linenum = 0
# if ARGV[0] == "stop"
#   system( "cvlc vlc://quit &> /dev/null &" )
#   puts "stopping radio"
# elsif ARGV[0] == "list"
#   if ARGV[1]
#     file = File.open(streams)
#     file.each do |line|
#       linenum = $. if line.downcase.include?(ARGV[1])
#       break if linenum != 0
#     end
#        puts linenum
#    array = File.readlines(streams)
#     puts array[linenum - 1]
#   else
#     file.each do |line|
#       puts line if line.include?("[*")
#     end
#     list = system( "grep BBC " + streams )
#   end
#   puts list
# else
#   if ARGV[1] == "now"
#     puts "Radio schedules coming soon"
#   else
#     file = File.open(streams)
#     file.each do |line|
#       linenum = $. if line.downcase.include?(ARGV[0])
#       break if linenum != 0
#     end
#     if linenum == 0
#       puts "No Station Found."
#     else
#       array = File.readlines(streams)
#       IO.popen( "cvlc vlc://quit &> /dev/null && sleep 0.1s && cvlc -q " + array[linenum] + " $> /dev/null &" )
#       puts "Playing"
#     end
#   end
#     
# end
# # v1 = ARGV[0]
# # v2 = ARGV[1]
# # puts v1
# # puts v2
