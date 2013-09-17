class TrailsegmentsController < ApplicationController
  before_action :set_trailsegment, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index]
  
  # GET /trailsegments
  # GET /trailsegments.json
  def index

    respond_to do |format|
      format.html do
        authenticate_user!
        if params[:all] == "true"
          @trailsegments = Trailsegment.all
        else
          @trailsegments = Trailsegment.where(source: current_user.organization)
        end
      end
      format.json do
        @entity_factory = ::RGeo::GeoJSON::EntityFactory.instance
        features = []
        @trailsegments.each_with_index do |trailsegment, index|
          feature = @entity_factory.feature(trailsegment.geom, trailsegment.id, trailsegment.attributes.except("geom", "wkt"))
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
        feature = @entity_factory.feature(@trailsegment.geom, @trailsegment.id, @trailsegment.attributes.except("geom", "wkt") )
        render json: RGeo::GeoJSON::encode(feature)
      end
    end
  end

  # GET /trailsegments/new
  def new
    @trailsegment = Trailsegment.new
  end

  # GET /trailsegments/1/edit
  def edit
  end

  # POST /trailsegments
  # POST /trailsegments.json
  def create
    @trailsegment = Trailsegment.new(trailsegment_params)

    respond_to do |format|
      if @trailsegment.save
        format.html { redirect_to @trailsegment, notice: 'Trailsegment was successfully created.' }
        format.json { render action: 'show', status: :created, location: @trailsegment }
      else
        format.html { render action: 'new' }
        format.json { render json: @trailsegment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trailsegments/1
  # PATCH/PUT /trailsegments/1.json
  def update
    respond_to do |format|
      if @trailsegment.update(trailsegment_params)
        format.html { redirect_to @trailsegment, notice: 'Trailsegment was successfully updated.' }
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
    @trailsegment.destroy
    respond_to do |format|
      format.html { redirect_to trailsegments_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trailsegment
      trailsegment = Trailsegment.find(params[:id])
      if params[:all] == "true" || trailsegment.source == current_user.organization || current_user.admin?
        @trailsegment = trailsegment
      else
        # this should do something smarter
        head 403
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def trailsegment_params
      params.require(:trailsegment).permit(:length, :source, :steward, :geom, :trail1, :trail2, :trail3)
    end
end
