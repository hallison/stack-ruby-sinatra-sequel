# encoding: utf-8

module Boilerplate

class HomeController < ApplicationController
  before do
    page.update title: 'Wellcome'
  end

  get action(:index) do
    if authenticated?
      view 'home/index'
    else
      view 'home/wellcome'
    end
  end
end

end # module
