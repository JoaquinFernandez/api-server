require 'net/http'
require 'json'
require 'mail'

class Bitcoin < ActiveRecord::Base

  def self.check_value
  	Mail.defaults do
  	  delivery_method :smtp, {
  	    :address => 'smtp.sendgrid.net',
  	    :port => '587',
  	    :domain => 'heroku.com',
  	    :user_name => ENV['SENDGRID_USERNAME'],
  	    :password => ENV['SENDGRID_PASSWORD'],
  	    :authentication => :plain,
  	    :enable_starttls_auto => true
  	  }
  	end
  	bitcoin_value_target = 400
  	uri = URI('https://api.coinbase.com/v2/prices/buy')

  	Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
  	  request = Net::HTTP::Get.new(uri.request_uri)
  	  request.add_field("CB-VERSION", "2016-01-04")
  	  data = JSON.parse(http.request(request).body)
  	  puts "JSON Response: #{data}"
  	  price = data['data']['amount'].to_f
  	  currency = data['data']['currency'].to_s
  	  puts "Price: $#{price} (#{currency})"
  	  if price < bitcoin_value_target
  	  	lastBitcoin = Bitcoin.order('updated_at DESC').first
  	  	if (lastBitcoin.price < bitcoin_value_target)
  	  		puts "Price below target, but mail already sent."
  	  	else
  		    puts "Price ($#{price}) below target ($#{bitcoin_value_target}). Sending alert."
  		    send_notice(ENV['PERSONAL_EMAIL'], price)
  		  end
  	  else
  	    puts "Price ($#{price}) above target ($#{bitcoin_value_target}). Doing nothing."
  	  end
      Bitcoin.create(price: price, currency: currency)
  	end
  end

  private
	def self.send_notice(to, price)
	  Mail.deliver do
	    from    "BTC Communicator <#{to}>"
	    to      to
	    subject "BTC is $#{price}"
	    body    "Good moment to buy: https://www.coinbase.com/buys"
	  end
	end
end
