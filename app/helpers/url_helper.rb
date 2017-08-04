# encoding: utf-8

module Boilerplate

module UrlHelper
  def controllers
    Boilerplate.controllers
  end

  # Helper descrito como solução para sub URI nas aplicações em jRuby.
  # Detalhes: https://github.com/jruby/warbler/issues/110
  def context_path
    @context_path ||= check_for_context
  end

  def path_to(path, *args)
    subpath = nil
    params = ""
    if args.last.kind_of? Hash
      slashes = args[0..-2]
      query = args[-1]
    else
      slashes = args
    end
    (slashes.size > 0) && (subpath = "/" + slashes.join('/'))
    query && (params = ("?" + query.map{|k,v|"#{k}=#{v}"}.join("&")))
    url_path = routing[path] && routing[path].last || path.to_s
    url_path = "/#{url_path}#{subpath}"
    url_path = url_path.squeeze('/')
    "#{context_path}#{url_path}#{params}"
  end

  def action_for(controller, action = nil, params = {})
    route = routing[controller].last
    map   = mapping[controller][action || :index]
    map   = map.set_params(params)

    path = "#{context_path}#{route}#{map}"
    path = !params.empty? && format("%s?%s", path, params.map{|k,v|"#{k}=#{v}"}.join("&")) || path
    path = path.squeeze('/')
    "#{context_path}#{path}"
  end

  def action_path?(controller, action = nil)
    action_for(controller, action) == request.path
  end

private
  def routing
    Boilerplate.routing
  end

  def mapping
    Boilerplate.mapping
  end

  def check_for_context
    if $servlet_context
      return $servlet_context.getContextPath
    else
      return ""
    end
  end
end

end # Boilerplate
