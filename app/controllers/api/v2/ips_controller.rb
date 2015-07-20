require 'nokogiri'
require 'json'
require 'open-uri'

class Api::V2::IpsController < Api::V2::BaseController

  private

    def ip_params
      params.require(:secret_key)
    end

    def query_params
    end
end
