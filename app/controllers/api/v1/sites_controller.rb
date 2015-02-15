require 'nokogiri'
require 'json'
require 'open-uri'

class Api::V1::SitesController < Api::V1::BaseController

  private

    def site_params
      params.require(:site).permit(:url, :total_lines, :inline, :external)
    end

    def query_params
      params.permit(:url)
    end
end
