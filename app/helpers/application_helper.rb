module ApplicationHelper
  def spinner(extra = nil, options = {})
    e = extra ? "spinner_#{extra}" : 'spinner'
    image = options.delete(:image)
    color = options.delete(:color)
    image ||= color ? "spinner_#{color}.gif" : 'spinner.gif'
    image_tag(image, :id => e, :style => 'display:none', :class => "spinner #{options[:class]}")
  end
end
