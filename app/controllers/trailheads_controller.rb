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
      end
      format.json do
        entity_factory = ::RGeo::GeoJSON::EntityFactory.instance
        if (params[:loc])
          @trailheads = sort_by_distance(@trailheads)   
        end
        features = []
        @trailheads.each do |trailhead|
          feature = entity_factory.feature(trailhead.geom, trailhead.id, trailhead.attributes.except("geom", "wkt").merge( {:distance => trailhead.distance} ))
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
