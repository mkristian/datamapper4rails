class <%= controller_class_name %>Controller < ApplicationController

  # GET /<%= table_name %>
  # GET /<%= table_name %>.xml
  def index
    @<%= table_name %> = <%= class_name %>.all()

    respond_to do |format|
      format.html
      format.xml  { render :xml => @<%= table_name %> }
    end
  end

  # GET /<%= table_name %>/1
  # GET /<%= table_name %>/1.xml
  def show
    @<%= file_name %> = <%= class_name %>.get!(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @<%= file_name %> }
    end
  end

  # GET /<%= table_name %>/new
  # GET /<%= table_name %>/new.xml
  def new
    @<%= file_name %> = <%= class_name %>.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @<%= file_name %> }
    end
  end

  # GET /<%= table_name %>/1/edit
  def edit
    @<%= file_name %> = <%= class_name %>.get!(params[:id])
  end

  # POST /<%= table_name %>
  # POST /<%= table_name %>.xml
  def create
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])

    respond_to do |format|
      if @<%= file_name %>.save
        flash[:notice] = <% if options[:i18n] -%>t('<%= plural_name %>.<%= singular_name %>_created')<% else -%>'<%= class_name %> was successfully created.'<% end -%>

        format.html { redirect_to(<%= file_name %>_url(@<%= file_name %>.id)) }
        format.xml  { render :xml => @<%= file_name %>, :status => :created, :location => @<%= file_name %> }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @<%= file_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /<%= table_name %>/1
  # PUT /<%= table_name %>/1.xml
  def update
    @<%= file_name %> = <%= class_name %>.get!(params[:id])

    respond_to do |format|
      if @<%= file_name %>.update(params[:<%= file_name %>])
        flash[:notice] = <% if options[:i18n] -%>t('<%= plural_name %>.<%= singular_name %>_updated')<% else -%>'<%= class_name %> was successfully updated.'<% end -%>

        format.html { redirect_to(<%= file_name %>_url(@<%= file_name %>.id)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @<%= file_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /<%= table_name %>/1
  # DELETE /<%= table_name %>/1.xml
  def destroy
    @<%= file_name %> = <%= class_name %>.get(params[:id])
    @<%= file_name %>.destroy if @<%= file_name %>

    respond_to do |format|
      flash[:notice] = <% if options[:i18n] -%>t('<%= plural_name %>.<%= singular_name %>_deleted')<% else -%>'<%= class_name %> was successfully deleted.'<% end -%>

      format.html { redirect_to(<%= table_name %>_url) }
      format.xml  { head :ok }
    end
  end
end
