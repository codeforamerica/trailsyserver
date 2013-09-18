class TrailheadsController < ApplicationController
  before_action :set_trailhead, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index]
  
  # GET /trailheads
  # GET /trailheads.json
  def index
    @trailheads = Trailhead.all

    respond_to do |format|
      format.html do 
        authenticate_user!
        if params[:all] == "true" || current_user.admin?
          @trailheads = Trailhead.all
        else
          @trailheads = Trailhead.where(source: current_user.organization)
        end
      end
      format.json do
        entity_factory = ::RGeo::GeoJSON::EntityFactory.instance
        if (params[:loc])
          @trailheads = sort_by_distance(@trailheads)   
        end
        features = []
        @trailheads.each do |trailhead|
          logger.info trailhead.inspect
          feature = entity_factory.feature(trailhead.geom, 
                                           trailhead.id, 
                                           trailhead.attributes.except("geom", "wkt", "created_at", "updated_at")
                                           .merge( {:distance => trailhead.distance} ))
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
        feature = entity_factory.feature(@trailhead.geom, @trailhead.id, @trailhead.attributes.except("geom", "wkt") )
        render json: RGeo::GeoJSON::encode(feature) 
      end
    end
  end

  # GET /trailheads/new
  def new
    @trailhead = Trailhead.new
  end

  # GET /trailheads/1/edit
  def edit
  end

  # POST /trailheads
  # POST /trailheads.json
  def create
    @trailhead = Trailhead.new(trailhead_params)

    respond_to do |format|
      if @trailhead.save
        format.html { redirect_to @trailhead, notice: 'Trailhead was successfully created.' }
        format.json { render action: 'show', status: :created, location: @trailhead }
      else
        format.html { render action: 'new' }
        format.json { render json: @trailhead.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trailheads/1
  # PATCH/PUT /trailheads/1.json
  def update
    respond_to do |format|
      if @trailhead.update(trailhead_params)
        format.html { redirect_to @trailhead, notice: 'Trailhead was successfully updated.' }
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
      if (@trailhead.source == current_user.organization || current_user.admin?) && @trail.destroy
        format.html { redirect_to trailheads_url, notice: "Trailhead '" + @trailhead.name + "' was successfully deleted." }
        format.json { render :json => { head: no_content }, status: :ok }
      else
        format.html { redirect_to trailheads_url, notice: "Trailhead '" + @trailhead.name + "' was not deleted."}
        format.json { render :json => { head: no_content }, status: :unprocessable_entity }
      end
    end
  end

  def upload
    redirect_to trails_url, notice: "Please enter a source organization code for uploading trail data." if params[:source].empty?
    parsed_trailheads = Trailhead.parse(params[:trailheads])
    if parsed_trailheads.nil?
      redirect_to trailheads_url, notice: "Unable to parse file #{params[:trailheads].original_filename}. Make sure it is a valid GeoJSON file or zipped shapefile."
    end
    source_trailheads = Trailhead.source_trailheads(parsed_trailheads, current_user.organization || params[:source])
    @non_source_trailheads = Trailhead.non_source_trailheads(parsed_trailheads, current_user.organization || params[:source])
    if source_trailheads
      existing_org_trailheads = Trailhead.where(source: current_user.organization)
      @removed_trailheads = []
      existing_org_trailheads.each do |old_trailhead|
        removed_trailhead = Hash.new
        removed_trailhead[:trailhead] = old_trailhead
        removed_trailhead[:success] = old_trailhead.destroy
        @removed_trailheads.push(removed_trailhead)
      end
      @added_trailheads = []
      source_trailheads.each do |new_trailhead|
        added_trailhead = Hash.new
        added_trailhead[:trailhead] = new_trailhead
        added_trailhead[:success] = new_trailhead.save
        @added_trailheads.push(added_trailhead)
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trailhead
      trailhead = Trailhead.find(params[:id])
      if params[:all] == "true" || trailhead.source == current_user.organization || current_user.admin?
        @trailhead = trailhead
      else
        # this should do something smarter
        head 403
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def trailhead_params
      params.require(:trailhead).permit(:name, :source, :trail1, :trail2, :trail3, :geom, :distance)
    end

    def sort_by_distance(trailheads)
      factory = RGeo::Geographic.spherical_factory(:srid => 4326)
      lat, lng = params[:loc].split(',')
      loc = factory.point(lng,lat) 
      logger.info(loc)
      trailheads.each do |trailhead|
        logger.info trailhead.inspect
        logger.info trailhead.geom.inspect
        logger.info loc.inspect
        trailhead.distance =  trailhead.geom.distance(loc)
        logger.info(trailhead.distance)
      end
      trailheads_sort = @trailheads.sort do |a,b|
        a.distance <=> b.distance
      end
      trailheads_sort      
    end

  end
