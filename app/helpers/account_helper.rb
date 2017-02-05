module Boilerplate

module AccountHelper
  def username_pattern
    User::USERNAME_PATTERN
  end

  def email_pattern
    User::EMAIL_PATTERN
  end

  def profiles
    User::PROFILES
  end
end # AccountHelper

end # Boilerplate
