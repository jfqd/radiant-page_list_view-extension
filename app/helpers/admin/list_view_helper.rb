module Admin::ListViewHelper

  def link_or_span_unless_current(params, text, url, options)
    if options[:id] == params[:view]
      content_tag(:span, text)
    else
      link_to text, url, options
    end
  end

  def list_display_attributes
    display_atts = []
    unless config['page_list_view.display_attributes'].nil?
      config['page_list_view.display_attributes'].split.each do |att|
        display_atts << att if Page.column_names.include?("#{att}") || Page.instance_methods.include?("#{att}")
      end
    end
    display_atts = %w{title parent_title slug class_name status_name updated_by_name updated_at} if display_atts.empty?
    @list_display_attributes ||= returning display_atts do |atts|
      # atts << "group_name" if defined?(PageGroupPermissionsExtension)
    end
  end

  def nicify(value)
    case value
    when String; value.humanize
    when Time; value.strftime( fmt=I18n.t("time.formats.default") )
    else value.to_s.humanize
    end
  end

  def attribute_header_class(att)
    @saved_order ||= if cookies['table_kit_order']
      ActiveSupport::JSON.decode(CGI.unescape(cookies['table_kit_order']))
    else
      []
    end
    returning %W{page-#{att}} do |classes|
      classes << 'date-us-civil' if att =~ /(updated|created)_(at|on)/
      if @saved_order[0] && @list_display_attributes.index(att) == @saved_order[0]
        direction = @saved_order[1].to_i < 0 ? "desc" : "asc"
        classes << "sortfirst#{direction}"
      end
    end.join(" ")
  end

  def attribute_header_id(att)
    "#{att}-header"
  end
  
  def attribute_cell_class(att)
    returning %w{page} do |classes|
      # classes << 'date-short' if att =~ /(updated|created)_(at|on)/
    end.join(" ")
  end
  
  def allowed_by_role?
    allowed_roles = Radiant::Config['page_list_view.roles'].gsub(' ','').split(',')
    allowed_roles.any? { |role| @current_user.has_role?(role.to_s.downcase) }
  end
end