desc "This task is called by the Heroku scheduler add-on"
task :update_sites => :environment do
  puts "Updating sites..."
  Site.update_all
  puts "done."
end