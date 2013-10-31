class TrailsController < ApplicationController
  before_action :set_trail, only: [:show, :edit, :destroy, :update]
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_show_all_param
  before_action :check_for_cancel, only: [:update]

  # GET /trails
  # GET /trails.json
  def index    
    respond_to do |format|
      format.html do
        authenticate_user!
        if !user_signed_in? || (!current_user.admin && current_user.organization.nil?)
          sign_out :user
          redirect_to trails_path
          return  
        end
        if @show_all == "true" || current_user.admin?
          @trails = Trail.all.includes([:photorecord]).order("name")
        else
          # @trails = Trail.where(source: current_user.organization).order("name")
          @trails = Trail.includes([:photorecord]).joins(:source).merge(Organization.where(id: current_user.organization)).order("name")
        end
      end
      format.json do
        if params[:source_id].nil?
          @trails = Trail.includes([:photorecord]).order("name")
        else
          @trails = Trail.includes([:photorecord]).where(source_id: params[:source_id]).order("name")
        end
        entity_factory = ::RGeo::GeoJSON::EntityFactory.instance
        features = []
        @trails.each do |trail|
          # taking a trip to Null Island, because RGeo::GeoJSON chokes on empty geometry here
          json_attributes = create_json_attributes(trail)
          feature = entity_factory.feature(RGeo::Geographic.spherical_factory.point(0,0), trail.id, json_attributes)
          features.push(feature)
        end
        collection = entity_factory.feature_collection(features)
        my_geojson = RGeo::GeoJSON::encode(collection)
        render json: Oj.dump(my_geojson)
      end
      format.csv do
        if params[:source_id].nil?
          @trails = Trail.includes([:photorecord]).order("name")
        else
          @trails = Trail.includes([:photorecord]).where(source_id: params[:source_id]).order("name")
        end
        render text: @trails.to_csv
      end
    end
  end

  # GET /trails/1
  # GET /trails/1.json
  def show
    respond_to do |format|
      format.html 
      format.json do
        entity_factory = ::RGeo::GeoJSON::EntityFactory.instance
        json_attributes = create_json_attributes(@trail)
        feature = entity_factory.feature(RGeo::Geographic.spherical_factory.point(0,0), @trail.id, json_attributes)
        render json: RGeo::GeoJSON::encode(feature)
      end
    end
  end

  # # GET /trails/new
  # We're not currently allowing trails to be created from the admin UI
  #
  # def new
  #   @trail = Trail.new
  # end

  # GET /trails/1/edit
  def edit
    unless authorized?
      redirect_to trails_path, notice: 'Authorization failure.'
    end
  end

  # # POST /trails
  # # POST /trails.json
  # def create
  #   @trail = Trail.new(trail_params)

  #   respond_to do |format|
  #     if @trail.save
  #       format.html { redirect_to trails_path, notice: 'Trail was successfully created.' }
  #       format.json { render action: 'show', status: :created, location: @trail }
  #     else
  #       format.html { render action: 'new' }
  #       format.json { render json: @trail.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # PATCH/PUT /trails/1
  # PATCH/PUT /trails/1.json
  def update
    respond_to do |format|
      if params[:trail][:delete_photo] && params[:trail][:delete_photo] == "1"
        @trail.photorecord_attributes = { id: params[:trail][:photorecord_attributes][:id], _destroy: 1 }
      end
      # if params[:trail][:photorecord_attributes][:id] == "" && params[:trail][:photorecord_attributes][:photo].nil?
      #   params[:trail].delete :photorecord_attributes
      # end
      if authorized? && @trail.update(trail_params)
        format.html { redirect_to trails_path, notice: 'Trail was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @trail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trails/1
  # DELETE /trails/1.json
  def destroy
    respond_to do |format|
      if authorized? && @trail.destroy
        format.html { redirect_to trails_url, notice: "Trail '" + @trail.name + "' was successfully deleted." }
        format.json { render :json => { head: no_content }, status: :ok }
      else
        format.html { redirect_to trails_url, notice: "Trail '" + @trail.name + "' was not deleted." }
        format.json { render :json => { head: no_content }, status: :unprocessable_entity }
      end
    end
  end

  # POST /trails/upload
  def upload
    if !current_user
      head 403
    end
    @confirmed = params[:confirmed] ? true : false
    redirect_to trails_url, notice: "Please enter a source organization code for uploading trail data." if params[:source_id].empty?
    source_id = params[:source_id]
    @source = Organization.find(source_id)
    parsed_trails = Trail.parse(params[:trails])
    if parsed_trails.nil?
      redirect_to trails_url, notice: "Unable to parse file #{params[:trails].original_filename}. Make sure it is a valid CSV file."
      return
    end
    source_trails = Trail.where(source: @source)
    @non_source_trails = Trail.where.not(source: @source)
    # remove all trails from the current source
    @removed_trails = []
    source_trails.each do |old_trail|
      removed_trail = Hash.new
      removed_trail[:trail] = old_trail
      if @confirmed
        removed_trail[:success] = old_trail.destroy
      else
        removed_trail[:success] = true
      end
      @removed_trails.push(removed_trail)
    end
    # add all of the new trails
    @added_trails = []
    parsed_trails.each do |new_trail|
      photorecord = Photorecord.where(source_id: new_trail.source, name: new_trail.name).first     
      if photorecord
        new_trail.photorecord = photorecord
      end
      added_trail = Hash.new
      added_trail[:trail] = new_trail
      if new_trail.source != @source
        added_trail[:success] = false
        if !new_trail.source.nil?
          added_trail[:message] = "Trail source organization #{new_trail.source.code} doesn't match user organization #{@source.code}."
        else
          added_trail[:message] = "No trail source found."
        end
      elsif @confirmed
        if (new_trail.save)
          added_trail[:success] = true
        else
          added_trail[:success] = false
          added_trail[:message] = new_trail.errors.full_messages
        end
      else 
        # we're just doing a test run, so check for validity
        if (new_trail.valid?)
          added_trail[:success] = true
        else
          # this is because we can't easily test name uniqueness without deleting data
          if new_trail.errors.full_messages == ["Name  has already been taken for this source"]
            added_trail[:success] = true
          else
            added_trail[:success] = false
            added_trail[:message] = new_trail.errors.full_messages
          end
        end
      end
      @added_trails.push(added_trail)
    end
  end

  def default_url_options
    { all: @show_all }.merge(super)
  end

  def set_show_all_param
    @show_all = params[:all] if params[:all]
  end

  def create_json_attributes(trail)
    json_attributes = trail.attributes.clone.except!("created_at", "updated_at", "source_id", "steward_id")
    if trail.source
      json_attributes["source"] = trail.source.code
      json_attributes["source_fullname"] = trail.source.full_name
      json_attributes["source_phone"] = trail.source.phone
      json_attributes["source_url"] = trail.source.url
      json_attributes["source_logo_url"] = trail.source.logo.url(:medium)
    end
    if trail.steward 
      json_attributes["steward"] = trail.steward.code
      json_attributes["steward_fullname"] = trail.steward.full_name
      json_attributes["steward_phone"] = trail.steward.phone
      json_attributes["steward_url"] = trail.steward.url
      json_attributes["steward_logo_url"] = trail.steward.logo.url(:medium)
    end
    if trail.photorecord
      json_attributes["orig_photo_url"] = trail.photorecord.photo.url
      json_attributes["medium_photo_url"] = trail.photorecord.photo.url(:medium)
      json_attributes["thumb_photo_url"] = trail.photorecord.photo.url(:thumb)
      json_attributes["photo_credit"] = trail.photorecord.credit
    end
    json_attributes
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trail
      @trail = Trail.find(params[:id])
    end

    def authorized?
      current_user.admin? || (@trail && (current_user.organization == @trail.source)) 
    end
    
    # Never trust parameters from the scary internet, only allow the white list through.
    def trail_params
      params.require(:trail).permit(:name, :status, :statustext, :description, 
        :source, :source_id, :steward, :steward_id, :length, :accessible, :hike, :equestrian, :xcntryski, :dogs, 
        :roadbike, :mtnbike, :conditions, :map_url, :trlsurface, :delete_photo, :photorecord_attributes => [:photo, :source, :source_id, :name, :id, :credit])
    end


    def check_for_cancel
      if params[:commit] == "Cancel"
        redirect_to trailheads_path
      end
    end
end
