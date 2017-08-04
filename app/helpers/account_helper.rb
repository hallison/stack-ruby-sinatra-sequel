module Boilerplate

module AccountHelper
  def username_pattern
    Boilerplate::PATTERN_USERNAME
  end

  def email_pattern
    Boilerplate::PATTERN_EMAIL
  end

  def profiles
    User::PROFILES
  end
end # AccountHelper

end # Boilerplate
