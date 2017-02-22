# encoding: utf-8

module Boilerplate

class SecurityController < ApplicationController
  before do
    page.update title: 'Página de acesso'
  end

  get action(:index) do
    if authenticated?
      redirect(to(action_for(:account)))
    else
      view('security/index')
    end
  end

  post action(:login) do
    if params[:user] && (@user = User.authenticate(params[:user]))
      authenticate(@user.id, @user.email, *@user.profiles)
      notification.update(level: :information, message: "Hi, #{@user.name}. Wellcome!")
      path = params[:redirect] ? to(params[:redirect]) : action_for(:home)
      redirect(action_for(:account), 303)
    else
      notification.update(level: :error, message: 'User not found or invalid password.')
      view('security/index')
    end
  end

  post action(:logout) do
    @user = nil
    disconect!
    redirect(to(action_for(:home)), 303)
  end
end

end # Boilerplate
