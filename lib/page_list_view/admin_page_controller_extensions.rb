module PageListView::AdminPageControllerExtensions
  def self.included(base)
    base.class_eval {
      include Admin::ListViewHelper # we wanna use: allowed_by_role?
      alias_method_chain :index, :page_list_view
    }
  end

  def index_with_page_list_view
    return index_without_page_list_view unless allowed_by_role?
    %w(paginated_list full_list).each do |view|
      if (cookies['page_view'] == view && params[:view] != view )
        redirect_to :view => view and return
      end
    end
    per_page = config['page_list_view.per_page'] || 50
    if params[:view] == 'full_list'
      params[:page] = nil
      if params[:search]
        cond = "%#{params[:search]}%"
        @pages = Page.find(:all, :conditions => ["pages.title LIKE ? OR page_parts.name LIKE ? OR page_parts.content LIKE ?", cond, cond, cond], :include  => :parts, :order => params[:sort] || 'title')
      else
        @pages = Page.find(:all, :order => params[:sort] || 'title')
      end
      @template_name = 'index'
      render :action => "page_list_view" and return
    elsif params[:view] == 'paginated_list'
      @pages = Page.paginate(:page => (params[:page] || 1), :order => params[:sort] || 'title', :per_page => per_page)
      @template_name = 'index'
      render :action => "page_list_view" and return
    else
      index_without_page_list_view
    end
  end
end