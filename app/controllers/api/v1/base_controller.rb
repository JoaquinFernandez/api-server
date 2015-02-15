class Api::V1::BaseController < Api::BaseController
  before_action :set_resource, only: [:show, :update]

  # GET /api/v1/{plural_resource_name}
  def index
    resources = resource_class.all
                              .page(page_params[:page])
                              .per(page_params[:page_size])

    instance_variable_set(plural_resource_name, resources)
    puts instance_variable_get(plural_resource_name).class
    respond_with instance_variable_get(plural_resource_name)
  end

  # GET /api/v1/{plural_resource_name}/{url}
  def show
    site = resource_class.find(params[:id])
    respond_with site
  end

  # def create
  #   set_resource(resource_class.new(resource_params))

  #   if get_resource.save
  #     render :show, status: :created, location: get_resource
  #   else
  #     render json: get_resource.errors, status: :unprocessable_entity
  #   end
  # end

  # def update
  #   # PATCH/PUT /api/v1/{plural_resource_name}/{url}
  #   puts params[:url]
  #   if params[:url]
  #     if update_resource(resource_class.find_or_create_by("url" => params[:url]))
  #       render :show
  #     else
  #       render json: get_resource.errors, status: :unprocessable_entity
  #     end
  #   # PATCH/PUT /api/v1/{plural_resource_name}
  #   else
  #     if update_resources
  #       render :index
  #     else
  #       render json: get_resource.errors, status: :unprocessable_entity
  #     end
  #   end
  # end

  # DELETE /api/v1/{plural_resource_name}/1
  # def destroy
  #   get_resource.destroy
  #   head :no_content
  # end

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
      resource ||= resource_class.find_by("url" => :id)
      instance_variable_set("@#{resource_name}", resource)
    end
end
