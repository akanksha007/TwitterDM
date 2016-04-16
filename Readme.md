##Problem Statement
Build a ruby script which when executed gets all the latest followers of Neha and sends them a DM "Thank you for the follow". 
Use the twitter api for this. The script should have a method `setup_old_followers` which creates record of existing followers before the first run. On subsequent runs, the new followers are thanked and added to the old followers list so that they dont get thanked again. You may store this data in Redis. 
Further plot the graph of followers.

##Prerequisite
You need to have ruby installed

##Getting Started
1. git clone https://github.com/akanksha007/TwitterDM.git
2. cd TwitterDm
3. Create a app on twitter or add the existing consumer_key, consumer_secret, access_token, access_token_secret to file twitterapi.rb and make sure you have the permission for direct message.
4. You need to install the following package.
 * gem install twitter
 * gem install redis
 * gem install redis-server
5. Execute ruby checker.rb
