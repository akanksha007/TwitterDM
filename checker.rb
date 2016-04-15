require_relative 'twitterapi'
client = setup_client
setup_old_followers(client)

while true
  current_followers = get_latest_followers(client)
  send_thanks_to_new_followers(current_followers)
  add_new_followers_to_existing_followers(current_followers)
  sleep(86400);
end
