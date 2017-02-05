# encoding: utf-8

module Boilerplate

class AccountController < ApplicationController
  helpers AccountHelper

  before do
    settings.page.update title: 'Account'
  end

  before "#{action :index}:id/?:action?" do |id, action|
    @user = User[id.to_i]
  end

  get action(:index), authenticate: true do
    @user ||= User[session[:user][:id]]
    view 'account/page'
  end

  get action(:new) do
    @user = User.new
    view 'account/new'
  end

  post action(:new) do
    @user = User.new params[:user]

    if params[:account]
      @user.set_password *params[:account].values
    else
      notification.update level: :error, message: 'Password and confirmation are required'
    end

    if @user.valid?
      @user.save
      notification.update level: :information, message: 'Account created'
      redirect action_for(:account, :index)
    else
      notification.update level: :error, message: 'Errors on creates your account'
      view 'account/new'
    end
  end
end

end # Boilerplate
