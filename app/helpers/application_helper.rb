module ApplicationHelper
  def active_link_to(name = nil, options = nil, html_options = nil, &block)
    html_options[:class] << " active" if current_page?(options)
    link_to(name, options, html_options, &block)
  end
end
