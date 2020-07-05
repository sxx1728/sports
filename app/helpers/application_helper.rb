module ApplicationHelper

  def brac_flash
    dismiss_btn = '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>'
    if flash[:alert]
      raw "<div class='alert alert-danger'>#{dismiss_btn}#{flash[:alert]}</div>"
    elsif flash[:notice]
      raw "<div class='alert alert-success'>#{dismiss_btn}#{flash[:notice]}</div>"
    elsif flash[:success]
      raw "<div class='alert alert-success'>#{dismiss_btn}#{flash[:success]}</div>"
    end
  end

  def brac_datetime datetime
    datetime.try(:strftime, '%Y-%m-%d %H:%M')
  end

  def brac_boolean value
    raw(value ? '<span class="label label-primary">是</span>' : '<span class="label label-danger">否</span>')
  end

  def brac_boolean_reverse value
    raw(value ? '<span class="label label-danger">是</span>' : '<span class="label label-primary">否</span>')
  end

  def brac_date date
    date.try(:strftime, '%m/%d/%Y')
  end

  def brac_image image, options = {}
    versioned_image = options[:version] ? image.send(options[:version]) : image
    css_class = ['img-rounded', 'img-responsive'] << options[:class]
    if versioned_image.url
      link_to image_tag(versioned_image, class: css_class.flatten.join(' ')), versioned_image.url, target: '_blank'
    else
      image_tag('admin/no-image.png', class: 'img-rounded '+css_class.flatten.join(' '))
    end
  end

end

