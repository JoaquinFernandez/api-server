class Api::BaseController < ApplicationController
  respond_to :json, :xml
  headers['Access-Control-Allow-Origin'] = '*'
  headers['Access-Control-Allow-Methods'] = 'GET'
end
