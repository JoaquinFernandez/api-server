class Site < ActiveRecord::Base
  validates :url, presence: true
  validates_uniqueness_of :url

  def self.update_all

    insert_most_popular_sites_in_db
    
    success = true
    Site.all.each { |site|

      dataObject = get_total_js_lines_from_site(site)
      if (dataObject == 0)
        next
      end
      # In case anyone fails, fail
      if site.update(dataObject) 
        success = false
      end
    }
    return success
  end

  private

    PAGE_URL = "http://www.alexa.com/topsites/global;0"

    def self.insert_most_popular_sites_in_db
      page = Nokogiri::HTML(open(PAGE_URL))
      page.css('li.site-listing').css('a').select { |link| 
        href = link['href'].to_s
        if (href.nil? || href.empty?) 
          next
        end
        href = href[href.rindex('/') + 1, href.length]
        Site.where(:url => href).first_or_create
      }
    end

    def self.get_number_of_lines pageString
      return pageString.split(/[\n,\r,;,{,}]/).count
    end

    def self.get_inline_js_from_page sitePage
      numberOfJSlines = 0
      sitePage.css('script').each do |script|
        numberOfJSlines += get_number_of_lines(script.inner_html.to_s)
      end
      return numberOfJSlines
    end

    def self.get_external_js_from_page sitePage
      numberOfJSlines = 0
      numberOfExternalJSFiles = 0
      externalJS = []
      sitePage.css('script').each { |script|
      }

      sitePage.css('script').each { |link|
        link = link["src"].to_s.strip
        if (link.empty?)
          next
        end
        uri = URI(link)
        if (uri.scheme != "http" && uri.scheme != "https")
          if (link[0] == '/' && link[1] == '/')
            uri = URI ("https:" + link)
          else
            #Path relative to html
            next
          end
        end
        numberOfExternalJSFiles += 1
        scriptString = open(uri,
            :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE,
            "User-Agent" => "Mozilla/5.0 (Windows NT 6.3; WOW64; rv:34.0) Gecko/20100101 Firefox/34.0",
            "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
            "Accept-Language" => "en-US,en;q=0.8"
            ).read
        numberOfJSlines += get_number_of_lines(scriptString)

      }

      if (numberOfJSlines == 0)
        return 0
      end

      return numberOfJSlines
    end

    def self.get_total_js_lines_from_site site
      requestURL = site.url
      begin
        sitePage = Nokogiri::HTML(
          open("http://www." + requestURL,
            "Host" => "www." + requestURL,
            "User-Agent" => "Mozilla/5.0 (Windows NT 6.3; WOW64; rv:34.0) Gecko/20100101 Firefox/34.0",
            "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
            "Accept-Language" => "en-US,en;q=0.8"
            )
          )
      rescue
        begin
          sitePage = Nokogiri::HTML(
            open("https://www." + requestURL,
              :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE,
              "Host" => "www." + requestURL,
              "User-Agent" => "Mozilla/5.0 (Windows NT 6.3; WOW64; rv:34.0) Gecko/20100101 Firefox/34.0",
              "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
              "Accept-Language" => "en-US,en;q=0.8"
              )
            )
        rescue
          puts "Failed HTTPS"
          return 0
        end
      end
      inlineJS = get_inline_js_from_page(sitePage)
      externalJS = get_external_js_from_page(sitePage)
      totalLines = inlineJS + externalJS
      return {
        "total_lines" => totalLines,
        "inline" => inlineJS,
        "external" => externalJS
      }
    end

end
