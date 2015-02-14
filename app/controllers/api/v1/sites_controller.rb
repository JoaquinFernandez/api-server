class Api::V1::SitesController < Api::V1::BaseController

  PAGE_URL = "http://www.alexa.com/topsites/global;0"

  def listOfMostPopularSites
    page = Nokogiri::HTML(open(PAGE_URL))
    sitesList = []
    page.css('li.site-listing').css('a').select { |link| 
      href = link['href'].to_s
      if (href.nil? || href.empty?) 
        next
      end
      href = href[href.rindex('/') + 1, href.length]
      sitesList.push(href)
    }
    return sitesList
  end

  def getNumberOfLines pageString
    return pageString.split(/[\n,\r,;,{,}]/).count
  end

  def getInlineJSFromSitePage sitePage
    numberOfJSlines = 0
    sitePage.css('script').each do |script|
      numberOfJSlines += getNumberOfLines(script.inner_html.to_s)
    end
    return numberOfJSlines
  end

  def getExternalJSFromSitePage sitePage
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
      numberOfJSlines += getNumberOfLines(scriptString)

    }

    if (numberOfJSlines == 0)
      return 0
    end

    return numberOfJSlines
  end

  def getJSLinesFromSite site
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
    inlineJS = getInlineJSFromSitePage(sitePage)
    externalJS = getExternalJSFromSitePage(sitePage)
    totalLines = inlineJS + externalJS
    return {
      "total_lines" => totalLines,
      "inline" => inlineJS,
      "external" => externalJS
    }
  end

  private

    def site_params
      params.require(:site).permit(:url, :total_lines, :internal, :external)
    end

    def query_params
      params.permit(:url)
    end

    # @Override Api::V1::BaseController
    def update_resource(site)
      dataObject = getJSLinesFromSite(site)
      if (dataObject == 0)
        return true
      end
      return site.update(dataObject)   
    end

    # @Override Api::V1::BaseController
    def update_resources
      listSites = Site.all
      success = true

      if (listSites.empty?)
        listSites = listOfMostPopularSites()
      end

      listSites.each { |site|
        # In case anyone fails, fail
        if !update_resource(site)
          success = false
        end
      }
      return success
    end

    # Creates a new site object and inserts it into
    # the database
    # @param parameters the parameters of the new object
    # @return if it was successfully inserted in the db
    def update_site(site, parameters)
      return site.update(parameters)
    end

    # Creates a new site object and inserts it into
    # the database
    # @param parameters the parameters of the new object
    # @return if it was successfully inserted in the db
    def insert_site(parameters)
      newSite = Site.new(parameters)
      return newSite.save
    end
end
