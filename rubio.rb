#!/usr/bin/env ruby

require 'net/http'
require 'date'
require 'colorize'

  STREAMS_URL = 'https://raw.githubusercontent.com/lemybeck/bash-bbc-radio/master/radio_streams'


class RadioPlayer
  
  
  def initialize( search, later, play )
    initialize_variables
    set_work_dir
    get_streams_file
    match_station( search )
    regex_scanner
    get_schedule
    now_playing
    now( play )
    next_on( later )
  end

  def initialize_variables
    @station_position = 0
    @schedule = nil
    @programmes = []
  end
  
  # check if working directory exists, create it if not
  def set_work_dir
    @work_dir = File.join(Dir.home, ".rubio/")
    Dir.mkdir @work_dir unless File.exists? @work_dir
  end
  
  # check if streams file exists, download it if not
  def get_streams_file
    uri = URI.parse STREAMS_URL
    @streams = @work_dir+File.basename(uri.path)
    unless File.exists? @streams
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        response = http.get uri
        open(@streams, "w") do |file|
          file.write(response.body)
        end
      end
    end
  end
  
  # match station
  def match_station( search )
    stations = File.open @streams
    stations.each do |line|
      @station_position = $. if line.downcase.include?('[*') && line.downcase.include?(search)
      @station = line.scan(/] (.*)/)[0]
      break if @station_position != 0
    end
    @stream_url = IO.readlines(stations)[@station_position].strip
    schedule = IO.readlines(stations)[@station_position+1].strip
    @schedule = URI.parse(URI.encode(schedule)) if schedule.match(/.*yaml/)
  end

  # if we don't have a link to a schedule, print a short message
  def no_match
    puts 'no information'
    puts @schedule
  end
  
  # if we do have a link to a schedule, get the schedule and print the info
  def regex_scanner
    regex_starts = / start: "(.{20})"/
    regex_ends = / end: "(.{20})"/
    regex_synopsis = / short_synopsis: "(.*?)"/
    regex_title = / display_titles:\s*title: "(.*?)"/
    regex_subtitle = / subtitle: "(.*?)"/
    @regex_scanner = /(?:#{regex_starts})|(?:#{regex_ends})|(?:#{regex_synopsis})|(?:#{regex_title})|(?:#{regex_subtitle})/m
  end
  
  # get schedule file, split it, put relevant info in array
  def get_schedule
    Dir.chdir @work_dir do
      Net::HTTP.start(@schedule.host, @schedule.port) do |http|
        schedule = http.get @schedule
        # put programme info into a hash and push to programmes array
        schedule.body.split('- is_repeat').drop(1).each do |programme|
          prog = Hash.new
          match = programme.scan(regex_scanner).flatten.compact
          prog['starts'] = match[0]
          prog['ends'] = match[1]
          prog['synopsis'] = match[2]
          prog['title'] = match[3]
          prog['subtitle'] = match[4]
          @programmes.push prog
        end
      end
    end
  end
  
  # what's playing now
  def now_playing
    @programmes.compact.each do |prog|
      @now_playing = @programmes.index( prog )
      break if ( DateTime.parse(prog['ends']) > DateTime.now )
    end
  end
  
  # construct now / next info
  # now
  def now( play )
    starts = DateTime.parse(@programmes[@now_playing]['starts']).strftime('%H:%M')
    ends = DateTime.parse(@programmes[@now_playing]['ends']).strftime('%H:%M')
    line1 = (' Now on ' + @station[0]).colorize(:blue) unless play
    line1 = (' Playing ' + @station[0]).colorize(:blue) if play
    line2 = ' ' + starts + ' - ' + ends + '  ' + (@programmes[@now_playing]['title']).colorize(:yellow)
    line3 = ('                - ' + @programmes[@now_playing]['subtitle']).colorize(:green)
    line4 = ' ' + @programmes[@now_playing]['synopsis']
    puts line1, line2, line3, line4, ''
  end
  
  # next
  def next_on( later )
    next_on = ' Next'.colorize(:blue)
    @programmes.compact.drop(@now_playing+1).each_with_index do |programme, index|
      starts = DateTime.parse(programme['starts']).strftime('%H:%M')
      ends = DateTime.parse(programme['ends']).strftime('%H:%M')
      next_on = next_on, ' ' + starts + ' - ' + ends + '  ' + programme['title'].colorize(:yellow)
      break if ((index > 1)  and (later == false))
    end
    puts next_on
  end



end

# def nownext( search, later, play )
# end

input = ARGV
case input[0]
when 'list'
  puts 'list'
when 'stop'
  puts 'Stopping'
  system( "cvlc vlc://quit &> /dev/null &" )
else
  search = input[0].to_s
  case input[1]
  when 'now', 'next'
    RadioPlayer.new( search, false, false )
  when 'later'
    RadioPlayer.new( search, true, false )
  when 'play', nil
    RadioPlayer.new( search, false, true )
  else
    puts 'Please try again'
  end
end




#   system( "cvlc vlc://quit &> /dev/null &" )
#       IO.popen( "cvlc vlc://quit &> /dev/null && sleep 0.1s && cvlc -q " + array[linenum] + " $> /dev/null &" )
