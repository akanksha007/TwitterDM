require 'json'
require 'twitter'
require 'redis'
require 'date'
require 'gnuplot'

@redis = Redis.new
@twitter_handle = "AKANKSHAAGARWA2"

def setup_client
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['CONSUMER_KEY']
    config.consumer_secret     = ENV['CONSUMER_SECRET']
    config.access_token        = ENV['ACCESS_TOKEN']
    config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
  end
end

def setup_old_followers(client)
  old_followers = client.followers(@twitter_handle).to_a
  old_followers_hash = old_followers.map { |follower| {id: follower.id, name: follower.name, screen_name: follower.screen_name}}
  @redis.set @twitter_handle, old_followers_hash.to_json
end

def get_latest_followers(client)
  old_followers = JSON.parse(@redis.get(@twitter_handle))
  old_ids = []
  old_followers.each {|hash| old_ids << hash['id']}
  current_followers = client.followers(@twitter_handle).to_a
  latest_followers = current_followers.reject{|current_follower| old_ids.include? current_follower.id}
	current_date =Time.now.strftime("%d/%m/%Y")
	current_date_followers_count = latest_followers.size
	File.open("graph_data.data", 'a') do |f|
		f.write(current_date)
		f.write(" ")
		f.puts(current_date_followers_count)
	end
end

def last_day?(date_string)
  date = DateTime.parse(date_string)
  (date + 1).day == 1
end

def plot_graph(filename)
date = Array.new
	count = Array.new
	line_num=0
	text=File.open(filename).read
	text.gsub!(/\r\n?/, "\n")
	text.each_line do |line|
		d,c = line.split
		date << d
		count << c.to_i
	end
	Gnuplot.open do |gp|
		Gnuplot::Plot.new(gp) do |plot|
			plot.timefmt "'%d-%m-%Y'"
			plot.title  "Twitter Follower"
			plot.xlabel "Date"
			plot.xdata "time"
			plot.yrange '["50":"500"]' 
			plot.xrange "< awk -v date=`date +'%s'` '{ if ($1 > date - 2592000) print $0; }' datafile"
			plot.ylabel "No. of followers"
			plot.data << Gnuplot::DataSet.new([date, count]) do |ds|
				ds.with = "linespoints"
				ds.title = ""
				ds.using = "1:2"
			end
		end
		if last_day?(Time.now.to_s)
			File.open('graph_data.data', 'w') {|file| file.truncate(0) }
		end
	end
end

def send_thanks_to_new_followers(current_followers)
  latest_followers = current_followers
  if latest_followers
    latest_followers.each do |follower|
      client.create_direct_message("#{follower.screen_name}", "Thanks for the follow!")
      sleep 5
    end
  end
end

def add_new_followers_to_existing_followers(latest_followers)
  old_followers = JSON.parse(@redis.get(@twitter_handle))
  latest_followers_hash = latest_followers.map { |follower| {id: follower.id, name: follower.name, screen_name: follower.screen_name}}
  latest_followers_hash = JSON.parse(latest_followers_hash.to_json)
  @redis.set @twitter_handle, (old_followers|latest_followers_hash).to_json
end




