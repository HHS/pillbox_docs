class PillsController < ApplicationController
  
#  skip_before_filter :ensure_authenticated_to_facebook, :only=>[:index, :lookup]
  def match
    @message = Message.find(params[:message], :include=>[:pills])
  end
  def index
    respond_to do |format|
      format.fbml {render :action=>'index.haml'}
    end
  end
  
#  http://pillbox.nlm.nih.gov/pillimage/search_results.php?s=20&np=85&getimprint=&getshape=&getfirstcolor=&getsecondcolor=&getsize=12.00&getscore=0&getingredient=&submit=Search&display=20
  def lookup
    # this is fugly
    # lookup should be broken into two different routes, 
    #  - :pill_properties querystring, and 
    #  - regular routing with /pill/:id
    #
    # ... alas. It is not.
   
    @pill = case params[:pill]
      when /^(\d+)$/;   Pill.find_by_id(params[:pill])
      when String;      Pill.find_by_name(params[:pill])
     end
#   pill_properties = @pill.try(:properties) 

   params[:pill_properties] ||= {}
   params[:pill_properties].reject! {|k,v| v.blank?}
   if @pill.nil? && params[:pill_properties].blank?
       flash[:errors] = "Please enter some parameters?"
       render :index
       return
    else
      pill_properties = params[:pill_properties]
    end
    pill_properties = @pill.try(:get_searchable_attributes) if pill_properties.blank?
    pill_properties ||= {}
    
    pill_properties.merge!(:page=>params[:page]) if params[:page]
    pill_properties.merge!(:start=>params[:start]) if params[:start]

    debugger
    begin
      PillboxResource.api_key = 'B0FB27B73G'      
      @pill_resources = PillboxResource.find(:all, :params=>pill_properties.merge('has_image'=>'1'))
    rescue => e
      flash[:errors] = "This is an error with the API." if e.message.include? "MYCOBUTIN"
    end
    

    if @pill_resources.blank?
      flash[:errors] ||= "None found. Try a simpler search?"
      render :index
      return
    end

    respond_to do |format|
      format.fbml { render :action=>'results.html' }
      format.xml  {}
      format.js   {}
    end
  end
  
  
end
