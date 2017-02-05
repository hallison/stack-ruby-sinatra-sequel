# encoding: utf-8

module Boilerplate

module ApplicationHelper
  def application_title
    Boilerplate.application_config[:title]
  end

  def version
    Boilerplate::VERSION
  end

  def version_info
    Boilerplate.version_info
  end

  def data(filename)
    Boilerplate.load_data(filename)
  end
end

end # Boilerplate

