include Boilerplate
include Rack::Test::Methods

describe AccountController do
  before do
    User.truncate
  end

  let :app do
    AccountController
  end

  let :users do
    fixtures[:users].symbolize_keys.each_with_object Hash.new do |(id, data), list|
      data[:password][:confirmation] = data[:password][:phrase]
      list[id] = data
      list
    end
  end

  it 'not authorize account page without login' do
    get app.action(:index)
    assert last_response.unauthorized?, last_response.status
  end

  it 'get page to create a new account' do
    get app.action(:new)
    assert last_response.successful?, last_response.status
  end

  it 'post data to create new account' do
    post app.action(:create), users[:first]
    assert last_response.redirection?, last_response.status
  end
end
