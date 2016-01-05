desc "This task is called by the Heroku scheduler add-on"
task :update_sites => :environment do
  puts "Updating sites..."
  Site.update_all
  puts "done."
end
task :bitcoin_value => :environment do
  puts "Checking bitcoin value"
  Bitcoin.check_value
  puts "done."
end