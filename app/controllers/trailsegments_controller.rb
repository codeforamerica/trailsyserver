class TrailsegmentsController < ApplicationController
  before_action :set_trailsegment, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_show_all_param
  before_action :check_for_cancel, only: [:update]
  
  # GET /trailsegments
  # GET /trailsegments.json
  def index

    respond_to do |format|
      format.html do
        authenticate_user!
        if params[:all] == "true" || current_user.admin?
          @trailsegments = Trailsegment.order("trail1").order("trail2").order("trail3")
        else
          @trailsegments = Trailsegment.joins(:source).merge(Organization.where(id: current_user.organization)).order("trail1").order("trail2").order("trail3")
        end
      end
      format.json do
        simplify_factor = params[:simplify].to_i
        if simplify_factor > 0
          @trailsegments = Trailsegment.find_by_sql(["select *, st_linemerge(geom::geometry) as merged_geom from trailsegments"]);
        else
          @trailsegments = Trailsegment.all
        end
        @entity_factory = ::RGeo::GeoJSON::EntityFactory.instance
        line_factory = ::RGeo::Geographic.spherical_factory(:srid => 4326)
        features = []

        @trailsegments.each do |trailsegment|
          merged_geom = trailsegment.attributes["merged_geom"]
          if simplify_factor > 0
            if merged_geom.geometry_type.type_name == "MultiLineString"
              new_trailsegment_linestrings = []
              merged_geom.each_with_index do |linestring, ls_index|
                new_linestring_points = []
                linestring.points.each_with_index do |point, p_index|
                  if p_index % simplify_factor == 0 || p_index == linestring.num_points - 1
                    new_linestring_points.push(point)
                  end
                end
                new_trailsegment_linestrings.push(line_factory.line_string(new_linestring_points))
              end
              simplified_trailsegment_geom = line_factory.multi_line_string(new_trailsegment_linestrings)
              trailsegment.geom = simplified_trailsegment_geom

            elsif merged_geom.geometry_type.type_name == "LineString" 
              new_linestring_points = []
              merged_geom.points.each_with_index do |point, p_index|
                if p_index % simplify_factor == 0 || p_index == merged_geom.num_points() - 1
                  new_linestring_points.push(point)
                end
              end
              simplified_trailsegment_geom = line_factory.line_string(new_linestring_points)
              trailsegment.geom = simplified_trailsegment_geom
            end
          end
          json_attributes = create_json_attributes(trailsegment)
          feature = @entity_factory.feature(trailsegment.geom, 
            trailsegment.id, 
            json_attributes)
          features.push(feature)
        end
        collection = @entity_factory.feature_collection(features)
        my_geojson = RGeo::GeoJSON::encode(collection)
        render json: Oj.dump(my_geojson)
      end
    end
  end

  # GET /trailsegments/1
  # GET /trailsegments/1.json
  def show
    respond_to do |format|
      format.html
      format.json do
        @entity_factory = ::RGeo::GeoJSON::EntityFactory.instance
        json_attributes = create_json_attributes(@trailsegment)
        feature = @entity_factory.feature(@trailsegment.geom, @trailsegment.id, json_attributes )
        render json: RGeo::GeoJSON::encode(feature)
      end
    end
  end

  # GET /trailsegments/new
  # def new
  #   @trailsegment = Trailsegment.new
  # end

  # GET /trailsegments/1/edit
  def edit
    unless authorized?
      redirect_to trailsegments_path, notice: 'Authorization failure.'
    end
  end

  # # POST /trailsegments
  # # POST /trailsegments.json
  # def create
  #   @trailsegment = Trailsegment.new(trailsegment_params)

  #   respond_to do |format|
  #     if @trailsegment.save
  #       format.html { redirect_to trailsegments_path, notice: 'Trail segment was successfully created.' }
  #       format.json { render action: 'show', status: :created, location: @trailsegment }
  #     else
  #       format.html { render action: 'new' }
  #       format.json { render json: @trailsegment.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # PATCH/PUT /trailsegments/1
  # PATCH/PUT /trailsegments/1.json
  def update
    respond_to do |format|
      if authorized? && @trailsegment.update(trailsegment_params)
        format.html { redirect_to trailsegments_path, notice: 'Trailsegment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @trailsegment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trailsegments/1
  # DELETE /trailsegments/1.json
  def destroy
    respond_to do |format|
      if authorized? && trailsegment.destroy
        format.html { redirect_to trailsegments_url, notice: "Trail segment was successfully deleted." }
        format.json { render :json => { head: :no_content }, status: :ok }
      else
        format.html { redirect_to trailsegments_url, notice: "Trail segment was not deleted."}
        format.json { render :json => { head: :no_content }, status: :unprocessable_entity }
      end
    end
  end

  def upload
    if !current_user
      head 403
    end
    redirect_to trailsegments_url, notice: "Please enter a source organization code for uploading trail segment data." if params[:source_id].empty?
    source_id = params[:source_id]
    @source = Organization.find(source_id)
    parsed_trailsegments = Trailsegment.parse(params[:trailsegments])
    if parsed_trailsegments.nil?
      redirect_to trailsegments_url, notice: "Unable to parse file #{params[:trailsegments].orginial_filename}. Make sure it is a valid GeoJSON file or zipped shapefile."
      return
    end
    source_trailsegments = Trailsegment.where(source: @source)
    @non_source_trailsegments = Trailsegment.where.not(source: @source)
    # source_trailsegments = Trailsegment.source_trailsegments(parsed_trailsegments, current_user.organization || params[:source])
    # @non_source_trailsegments = Trailsegment.non_source_trailsegments(parsed_trailsegments, current_user.organization || params[:source])
    @removed_trailsegments = []
    source_trailsegments.each do |old_trailsegment|
      removed_trailsegment = Hash.new
      removed_trailsegment[:trailsegment] = old_trailsegment
      removed_trailsegment[:success] = old_trailsegment.destroy
      @removed_trailsegments.push(removed_trailsegment)
    end
    @added_trailsegments = []
    parsed_trailsegments.each do |new_trailsegment|
      added_trailsegment = Hash.new
      added_trailsegment[:trailsegment] = new_trailsegment
      if new_trailsegment.source != @source
        added_trailsegment[:success] = false
        if !new_trail.source.nil?
          added_trailsegment[:message] = "Trail segment organization #{new_trailsegment.source.code} doesn't match user organization #{@source.code}."
        else
          added_trailsegment[:message] = "No trail segment source found."
        end
      elsif (new_trailsegment.save)
        added_trailsegment[:success] = true
      else
        added_trailsegment[:success] = false
        added_trailsegment[:message] = new_trailsegment.errors.full_messages
      end
      @added_trailsegments.push(added_trailsegment)
    end
  end

  def default_url_options
    { all: @show_all }.merge(super)
  end

  def set_show_all_param
    @show_all = params[:all] if params[:all]
  end

  def create_json_attributes(trailsegment)
    json_attributes = trailsegment.attributes.except("geom", "wkt", "created_at", "updated_at")
    if trailsegment.source
      json_attributes["source"] = trailsegment.source.code
      json_attributes["source_fullname"] = trailsegment.source.full_name
      json_attributes["source_phone"] = trailsegment.source.phone
      json_attributes["source_url"] = trailsegment.source.url
    end
    if trailsegment.steward
      json_attributes["steward"] = trailsegment.steward.code
      json_attributes["steward_fullname"] = trailsegment.steward.full_name
      json_attributes["steward_phone"] = trailsegment.steward.phone
      json_attributes["steward_url"] = trailsegment.steward.url
    end
    json_attributes
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trailsegment
      @trailsegment = Trailsegment.find(params[:id])
    end

    def authorized?
      (current_user.organization == @trailsegment.source || current_user.admin?)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def trailsegment_params
      params.require(:trailsegment).permit(:length, :source_id, :steward, :geom, 
        :trail1, :trail2, :trail3, :steward_id, :accessible, :hike, :equestrian, 
        :xcntryski, :dogs, :roadbike, :mtnbike, :trail4, :trail5, :trail6)
    end

    def check_for_cancel
      if params[:commit] == "Cancel"
        redirect_to trailheads_path
      end
    end    
  end
