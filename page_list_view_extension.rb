# Uncomment this if you reference any of your controllers in activate
begin
  require_dependency 'application_controller'
rescue MissingSourceFile
  require_dependency 'application'
end

class PageListViewExtension < Radiant::Extension
  version "0.9.0"
  description "Enables viewing site pages in a list view sortable by attibute, paginated or full"
  url "http://github.com/avonderluft/radiant-page_list_view-extension"
  
  def activate
    Page.send :include, PageListView::PageExtensions
    Admin::PagesController.send :include, PageListView::AdminPageControllerExtensions
    Admin::PagesController.send :helper, Admin::ListViewHelper
    admin.page.index.add :top, "page_view_toggle"
    
    Radiant::Config['page_list_view.roles'] = '' unless Radiant::Config['page_list_view.roles']
  end
  
  def deactivate
  end
  
end