class LocationsController < ApplicationController
  before_filter :authenticate, :except => [:index, :show]
  respond_to :json, :html
  # GET /locations
  # GET /locations.xml
  def index
    @locs = Location.all
        @search = params[:search]
        @locations = []
    @locs.each do |l|
      if l.address.index(@search.to_s) && @search !="" && @search !=nil
        @locations<<l
      end
    end
    if @locations.empty?
      @locations = Location.all
    end
    @json = @locations.to_gmaps4rails
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
    Spreadsheet.client_encoding = 'UTF-8'
 
    uploaded_io = params[:dump][:excel_file]
    File.open(Rails.root.join('app', 'assets', 'files', uploaded_io.original_filename), 'wb+') do |file|
      file.write(uploaded_io.read)
    end

      addresses = []
      zips = []
      a_n = nil
      z_n = nil
      row_size = 0
      col_size = 0
   
    if uploaded_io.original_filename.split(".").last == "xls"

      book = Spreadsheet.open("#{Rails.root}/app/assets/files/#{uploaded_io.original_filename}")
      sheet1 = book.worksheet 0
      sheet1.each do |row|
        row_size = row.size
        if row[0]!=''
          col_size +=1
        end
      end
      col_size+=1
      row_size.times do |i|
        sheet1.each do |row|
          if row!='' || row!=nil
            if a_n==i
              addresses<<row[i].to_s
            elsif z_n==i
              zips<<row[i].to_i 
            end
            if row[i].to_s == 'Address'
              a_n=i
            elsif row[i].to_s == 'Zip+4' || row[i].to_s == 'Zip'
              z_n=i
            end
          end
        end
      end
    else

      oo = Excelx.new("#{Rails.root}/app/assets/files/#{uploaded_io.original_filename}")
      oo.default_sheet = oo.sheets.first
      row_size = oo.first_row.size
      col_size = oo.first_column.size
      1.upto(row_size) do |i|
        if oo.cell(1,i)=="Address"
          a_n=i
        elsif oo.cell(1,i)=="Zip+4"
          z_n=i
        end 
        1.upto(col_size) do |j|
          if (oo.cell(j,i)!='' || oo.cell(j,i)!=nil) && j!=1
            if a_n==i
              addresses<<oo.cell(j,i).to_s
            elsif z_n==i
              zips<<oo.cell(j,i) 
            end
          end
        end
      end        
    end

    addresses.size.times do |i|
      @location = Location.new(:address => addresses[i], :zip => zips[i])
      @location.save
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
  end  

  def authenticate
     redirect_to("/users/sign_in") unless user_signed_in?
  end

  def parse_xls_spreadsheet

  end

  def parse_xlsx_roo

  end

end
