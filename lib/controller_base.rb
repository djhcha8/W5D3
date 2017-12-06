require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'byebug'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise RuntimeError.new("Double render error!!") if already_built_response?
    @res.redirect(url, status = 302)
    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise RuntimeError.new("Double render error!!") if already_built_response?
    @res['Content-Type'] = content_type
    @res.write(content)
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    path = ("#{File.dirname(__FILE__)}/../views/#{self.class.to_s.underscore}/#{template_name}.html.erb")
    # file = File.open(path, "r")
    # read_file = file.read
    read_file = File.read(path)
    content = ERB.new(read_file).result(binding)
    render_content(content, "text/html")
  end

  # method exposing a `Session` object
  def session
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end

