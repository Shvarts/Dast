class LocationsController < ApplicationController

  respond_to :json, :html
  # GET /locations
  # GET /locations.xml
  def index
    @locations = Location.all
    @json = Location.all.to_gmaps4rails
    respond_with @json
  end

  # GET /locations/1
  # GET /locations/1.xml
  def show
    @location = Location.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @location }
    end
  end

  # GET /locations/new
  # GET /locations/new.xml
  def new
    @location = Location.new
 #   @location.process_geocoding

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @location }
    end
  end

  # GET /locations/1/edit
  def edit
    @location = Location.find(params[:id])
  end

  # POST /locations
  # POST /locations.xml
  def create
    @location = Location.new(params[:location])
#    @location.process_geocoding
    respond_to do |format|
      if @location.save
        format.html { redirect_to(@location, :notice => 'Location was successfully created.') }
        format.xml  { render :xml => @location, :status => :created, :location => @location }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @location.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /locations/1
  # PUT /locations/1.xml
  def update
    @location = Location.find(params[:id])

    respond_to do |format|
      if @location.update_attributes(params[:location])
        format.html { redirect_to(@location, :notice => 'Location was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @location.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.xml
  def destroy
    @location = Location.find(params[:id])
    @location.destroy

    respond_to do |format|
      format.html { redirect_to(locations_url) }
      format.xml  { head :ok }
    end
  end

  def excel
    @locations = Location.all
        Spreadsheet.client_encoding = 'UTF-8'
 
    uploaded_io = params[:dump][:excel_file]
    File.open(Rails.root.join('app', 'assets', 'files', uploaded_io.original_filename), 'wb+') do |file|
      file.write(uploaded_io.read)
    end
    book = Spreadsheet.open("#{Rails.root}/app/assets/files/#{uploaded_io.original_filename}")
    sheet1 = book.worksheet 0
    i=0
    sheet1.each do |row|
      if row!='' || row!=nil        
        @location = Location.new(:address => row[0].to_s, :zip => row[1])
#        @location.process_geocoding
        i+=1
        if i>=2
          @location.save
        end  
      end
    end
    respond_to do |format|
      if @location.save
        format.html { redirect_to(@location, :notice => 'Location was successfully created.') }
        format.xml  { render :xml => @location, :status => :created, :location => @location }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @location.errors, :status => :unprocessable_entity }
      end
    end  
  #  redirect_to locations_path
  end  
end
