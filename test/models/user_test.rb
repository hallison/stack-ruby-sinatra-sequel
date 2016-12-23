include Boilerplate

describe 'User' do
  before do
    User.where(username: 'selinakyle').delete
  end

  it 'creates a new account' do
    user = User.new username: 'selinakyle', name: 'Selina Kyle', email: 'selina@boilerplate.local'
    user.password = 's3kr3t4c4t'

    assert user.valid?, user.errors

    assert user.save, user.errors

    user = User.find username: 'selinakyle'

    assert !user.nil?
  end
end
