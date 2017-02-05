# encoding: utf-8

require 'sinatra/base'
require 'sinatra/content_for'
require 'sinatra/reloader'

module Boilerplate

class ApplicationController < Sinatra::Base
  def self.action(name)
    Boilerplate.mapping[controller_id][name]
  end

  def self.controller_id
    self.name.to_s.gsub(/^.*::/, '').underscore.gsub(/_controller/, '').to_sym 
  end

  configure :development do
    register Sinatra::Reloader
    dont_reload 'boilerplate/version'
  end

  helpers Sinatra::ContentFor

  helpers ApplicationHelper

  set :page, {
    title: 'Page title',
    description: 'The page description',
    layout: :default,
    path: '',
    notification: { icon: nil, level: 'information', message: nil }
  }
  set :public_folder, 'public'
  set :views, 'app/views'
  set :authenticate do |required|
    condition do
      if required && !authenticated?
        notification.update level: :warning, message: "Você precisa estar autenticado."
        redirect action_for(:security), 303
      end
    end
  end
  set :authorize do |action|
    condition do
      unless authorized?
        notification.update level: :warning, message: "Você não possui permissão para #{action}."
        redirect action_for(:home), 303
      end
    end
  end
  set :authorize_only do |role|
    condition do
      unless authorized_by? role
        notification.update level: :warning, message: "Você não possui permissão para acessar esta página."
        redirect action_for(:home), 303
      end
    end
  end

  enable :method_override
  enable :sessions

  after do
    settings.page.update path: request.path
  end
end

end # Boilerplate
