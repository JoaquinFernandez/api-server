class Api::V2::BaseController < Api::BaseController
  before_action :set_resource, only: [:show, :create]

  # GET /api/v2/ips
  def create
    # Make sure that the request contains the key
    request_secret_key = JSON.parse(request.body.read)
    secret_key = Rails.application.secrets.http_validation_key
    puts secret_key
    if (request_secret_key["secret_key"] != secret_key)
      render json: get_resource.errors, status: :unprocessable_entity
    end
    #Get the IP from the request
    remote_ip = env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_ADDR']
    remote_ip = remote_ip.scan(/[\d.]+/).first
    ip_record = resource_class.where(:ip => remote_ip).first_or_create;
    # This will update the updated_at field of the record
    ip_record.touch
    set_resource(ip_record)
    if get_resource.save
      render :show, status: :created
    else
      render json: get_resource.errors, status: :unprocessable_entity
    end
  end

  # GET /api/v2/ips
  def index
    respond_with resource_class.all.order(:updated_at).first
  end

  private

    # Returns the resource from the created instance variable
    # @return [Object]
    def get_resource
      instance_variable_get("@#{resource_name}")
    end

    # Returns the allowed parameters for searching
    # Override this method in each API controller
    # to permit additional parameters to search on
    # @return [Hash]
    def query_params
      {}
    end

    # Returns the allowed parameters for pagination
    # @return [Hash]
    def page_params
      params.permit(:page, :page_size)
    end

    # The resource class based on the controller
    # @return [Class]
    def resource_class
      @resource_class ||= resource_name.classify.constantize
    end

    # The singular name for the resource class based on the controller
    # @return [String]
    def resource_name
      @resource_name ||= self.controller_name.singularize
    end

    # The plural name for the resource class based on the controller
    # @return [String]
    def plural_resource_name
      @plural_resource_name ||= "@#{resource_name.pluralize}"
    end

    # Only allow a trusted parameter "white list" through.
    # If a single resource is loaded for #create or #update,
    # then the controller for the resource must implement
    # the method "#{resource_name}_params" to limit permitted
    # parameters for the individual model.
    def resource_params
      @resource_params ||= self.send("#{resource_name}_params")
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_resource(resource = nil)
      resource ||= resource_class.find_by("ip" => :id)
      instance_variable_set("@#{resource_name}", resource)
    end
end
