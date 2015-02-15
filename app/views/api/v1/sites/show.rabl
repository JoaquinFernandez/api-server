object @site => :site

attributes :url, :total_lines, :inline, :external

node :links do |site|
  links = {}
  if params['action'] == 'index'
    links[:show_site] = api_v1_site_url(site.id)
  else
    links[:all_sites] = api_v1_sites_url
  end
  links
end
