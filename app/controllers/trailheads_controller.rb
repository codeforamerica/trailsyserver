class TrailheadsController < ApplicationController
  before_action :set_trailhead, only: [:show, :edit, :destroy, :update]
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_show_all_param
  before_action :check_for_cancel, only: [:update]

  # GET /trailheads
  # GET /trailheads.json
  def index
    respond_to do |format|
      format.html do 
        authenticate_user!
        if params[:all] == "true" || current_user.admin?
          @trailheads = Trailhead.order("name")
        else
          @trailheads = Trailhead.joins(:source).merge(Organization.where(id: current_user.organization)).order("name")
        end
      end
      format.json do
        @trailheads = Trailhead.order("name")
        entity_factory = ::RGeo::GeoJSON::EntityFactory.instance
        if (params[:loc])
          @trailheads = sort_by_distance(@trailheads)
        end
        features = []
        @trailheads.each do |trailhead|
          json_attributes = create_json_attributes(trailhead)
          feature = entity_factory.feature(trailhead.geom, 
           trailhead.id, 
           json_attributes)
          features.push(feature)
        end
        collection = entity_factory.feature_collection(features)
        my_geojson = RGeo::GeoJSON::encode(collection)
        render json: Oj.dump(my_geojson)
      end
    end
  end
  
  # GET /trailheads/1
  # GET /trailheads/1.json
  def show
    respond_to do |format|   
      format.html
      format.json do
        entity_factory = ::RGeo::GeoJSON::EntityFactory.instance
        json_attributes = create_json_attributes(@trailhead)
        feature = entity_factory.feature(@trailhead.geom, @trailhead.id, json_attributes)
        render json: RGeo::GeoJSON::encode(feature) 
      end
    end
  end

  # GET /trailheads/new
  # We're not currently allowing trailheads to be created from the admin UI
  #
  # def new
  #   @trailhead = Trailhead.new
  # end

  # GET /trailheads/1/edit
  def edit
    unless authorized?
      redirect_to trailsegments_path, notice: 'Authorization failure.'
    end
  end

  # # POST /trailheads
  # # POST /trailheads.json
  # def create
  #   @trailhead = Trailhead.new(trailhead_params)

  #   respond_to do |format|
  #     if @trailhead.save
  #       format.html { redirect_to trailheads_path, notice: 'Trailhead was successfully created.' }
  #       format.json { render action: 'show', status: :created, location: @trailhead }
  #     else
  #       format.html { render action: 'new' }
  #       format.json { render json: @trailhead.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # PATCH/PUT /trailheads/1
  # PATCH/PUT /trailheads/1.json
  def update
    respond_to do |format|
      if authorized? && @trailhead.update(trailhead_params)

        format.html { redirect_to trailheads_path, notice: 'Trailhead was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @trailhead.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trailheads/1
  # DELETE /trailheads/1.json
  def destroy
    respond_to do |format|
      if authorized? && @trailhead.destroy
        format.html { redirect_to trailheads_url, notice: "Trailhead '" + @trailhead.name + "' was successfully deleted." }
        format.json { render :json => { head: :no_content }, status: :ok }
      else
        format.html { redirect_to trailheads_url, notice: "Trailhead '" + @trailhead.name + "' was not deleted."}
        format.json { render :json => { head: :no_content }, status: :unprocessable_entity }
      end
    end
  end

  def upload
    if !current_user
      head 403
    end
    @confirmed = params[:confirmed] ? true : false
    redirect_to trails_url, notice: "Please enter a source organization code for uploading trailhead data." if params[:source_id].empty?
    source_id = params[:source_id]
    @source = Organization.find(source_id)
    parsed_trailheads = Trailhead.parse(params[:trailheads])
    if parsed_trailheads.nil?
      redirect_to trailheads_url, notice: "Unable to parse file #{params[:trailheads].original_filename}. Make sure it is a valid GeoJSON file or zipped shapefile."
      return
    end
    source_trailheads = Trailhead.where(source: @source)
    @non_source_trailheads = Trailhead.where.not(source: @source)
    @removed_trailheads = []
    source_trailheads.each do |old_trailhead|
      removed_trailhead = Hash.new
      removed_trailhead[:trailhead] = old_trailhead
      if @confirmed
        removed_trailhead[:success] = old_trailhead.destroy
      else
        removed_trailhead[:success] = true
      end
      @removed_trailheads.push(removed_trailhead)
    end
    @added_trailheads = []
    parsed_trailheads.each do |new_trailhead|
      added_trailhead = Hash.new
      added_trailhead[:trailhead] = new_trailhead
      if new_trailhead.source != @source
        added_trailhead[:success] = false
        if !new_trailhead.source.nil?
          added_trailhead[:message] = "Trailhead organization #{new_trailhead.source.code} doesn't match user organization #{@source.code}"
        else
          added_trailhead[:message] = "No trailhead source found or organization code in input does not match a known organization."
        end
      elsif @confirmed
        if (new_trailhead.save)
          added_trailhead[:success] = true
        else
          added_trailhead[:success] = false
          added_trailhead[:message] = new_trailhead.errors.full_messages
        end
      else
        if (new_trailhead.valid?)
          added_trailhead[:success] = true
        else
          if new_trailhead.errors.full_messages == ["Name  has already been taken for this source"]
            added_trailhead[:success] = true
          else
            added_trailhead[:success] = false
            added_trailhead[:message] = new_trailhead.errors.full_messages
          end
        end
      end
      @added_trailheads.push(added_trailhead)
    end
  end

  def default_url_options
    { all: @show_all }.merge(super)
  end

  def set_show_all_param
    @show_all = params[:all] if params[:all]
  end

  def create_json_attributes(trailhead)
    json_attributes = trailhead.attributes.except("geom", "wkt", "created_at", "updated_at", "source_id", "steward_id")
    if trailhead.source
      json_attributes["source"] = trailhead.source.code
      json_attributes["source_fullname"] = trailhead.source.full_name
      json_attributes["source_phone"] = trailhead.source.phone
      json_attributes["source_url"] = trailhead.source.url
    end
    if trailhead.steward
      json_attributes["steward"] = trailhead.steward.code
      json_attributes["steward_fullname"] = trailhead.steward.full_name
      json_attributes["steward_phone"] = trailhead.steward.phone
      json_attributes["steward_url"] = trailhead.steward.url
    end
    json_attributes["distance"] = trailhead.distance
    json_attributes
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trailhead
      @trailhead = Trailhead.find(params[:id])
    end

    def authorized?
      (current_user.organization == @trailhead.source || current_user.admin?)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def trailhead_params
      params.require(:trailhead).permit(:name, :park, :address, :city, :state, :zip, :source_id, :trail1, :trail2, 
        :trail3, :geom, :distance, :steward_id, :parking, :drinkwater, :restrooms, 
        :kiosk, :trail4, :trail5, :trail6)
    end

    def sort_by_distance(trailheads)
      factory = RGeo::Geographic.spherical_factory(:srid => 4326)
      lat, lng = params[:loc].split(',')
      loc = factory.point(lng,lat) 
      trailheads.each do |trailhead|
        trailhead.distance =  trailhead.geom.distance(loc)
      end
      trailheads_sort = @trailheads.sort do |a,b|
        a.distance <=> b.distance
      end
      trailheads_sort      
    end

    def check_for_cancel
      if params[:commit] == "Cancel"
        redirect_to trailheads_path
      end
    end
end
