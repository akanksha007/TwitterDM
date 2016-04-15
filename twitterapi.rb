require 'json'
require 'twitter'
require 'redis'

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




