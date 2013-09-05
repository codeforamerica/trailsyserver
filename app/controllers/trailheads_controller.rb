class TrailheadsController < ApplicationController
  before_action :set_trailhead, only: [:show, :edit, :update, :destroy]

  # GET /trailheads
  # GET /trailheads.json
  def index
    @trailheads = Trailhead.all
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

  # GET /trailheads/1
  # GET /trailheads/1.json
  def show
    entity_factory = ::RGeo::GeoJSON::EntityFactory.instance
    feature = entity_factory.feature(@trailhead.geom, @trailhead.id, @trailhead.attributes.except("geom", "wkt") )
    render json: RGeo::GeoJSON::encode(feature)
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
    @trailhead.destroy
    respond_to do |format|
      format.html { redirect_to trailheads_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trailhead
      @trailhead = Trailhead.find(params[:id])
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
        trailhead.distance =  trailhead.geom.distance(loc)
      end
      trailheads_sort = @trailheads.sort do |a,b|
        a.distance <=> b.distance
      end
      trailheads_sort      
    end

  end
