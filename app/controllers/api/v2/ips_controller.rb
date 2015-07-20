require 'nokogiri'
require 'json'
require 'open-uri'

class Api::V2::IpsController < Api::V2::BaseController

  private

    def ip_params
      params.require(:ip)
    end

    def query_params
      params.permit(:ip)
    end
end
