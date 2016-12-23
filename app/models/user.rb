# encoding: utf-8

require 'bcrypt'

module Boilerplate

class User < Model[:users]
  include BCrypt
  include Model

  EMAIL_PATTERN = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  USERNAME_PATTERN = /^[a-zA-Z][a-zA-Z0-9\-_\.]{6,32}$/
  PROFILES = %w{
    administrator
    moderator
  }.freeze

  COLUMNS = %w{
    username
    name
    email
  }.freeze

  plugin :validation_helpers
  set_allowed_columns *(COLUMNS+PROFILES).map(&:to_sym)

  def validate
    super
    validates_presence :username, message: 'deve ser atribuído'
    validates_unique :username, message: 'já existe'
    validates_min_length 6, :username, message: lambda{ |n| "deve ter no mínimo #{n} caracteres" }
    validates_max_length 32, :username, message: lambda{ |n| "deve ser de até #{n} caracteres" }
    validates_format USERNAME_PATTERN, :username, message: 'deve possuir um formato válido'

    validates_presence :name, message: 'deve ser atribuído'
    validates_max_length 64, :name, message: lambda{ |n| "deve ser de até #{n} caracteres" }

    validates_presence :email, message: 'deve ser atribuído'
    validates_unique :email, message: 'já foi registrado'
    validates_max_length 256, :email, message: lambda{ |n| "deve ser de até #{n} caracteres" }
    validates_format EMAIL_PATTERN, :email, message: 'deve possuir um formato válido'

    validates_password_changed
  end

  def password
    @password ||= token self[:signature]
  end

  def password=(new_password)
    @password = encript new_password
    @password_matched = true
    self[:signature] = @password
  end

  def change_password(new_password, confirmation)
    if @password_matched = confirm_password(new_password, confirmation)
      password = new_password
    end
  end

  def authenticate?(other_password)
    password == other_password
  end

  def profiles
    PROFILES.select do |profile|
      send(profile) && (send(profile) == 'S')
    end << 'user'
  end

  def has_profile?(name)
    profiles.include? name.to_s
  end

  def param_name
    "#{id}-#{username.downcase}"
  end

protected

  def validates_password_changed
    if (!@password_matched)
      errors.add(:password, 'não combina com a confirmação ou está vazia')
    else
      @password_matched
    end
  end

private

  def encript(text)
    # Digest::MD5.hexdigest(salt ? "#{salt}:#{text}" : text)
    Password.create(text)
  end

  def token(text)
    Password.new(text)
  end

  def confirm_password(password, confirmation)
    ((password && confirmation) && !(password.empty? && confirmation.empty?)) && (password == confirmation)
  end

  class << self
    def authenticate(options)
      usuario = find username: options[:username]
      usuario && (usuario.authenticate? options[:password]) && usuario
    end

    def by_letra_inicial(*letras)
      where("UPPER(SUBSTR(name, 1, 1)) IN ?",  letras.map(&:upcase))
    end

    def search(termo)
      regexp_like(username: termo, name: termo)
    end

  private

    def regexp_like(hash)
      expressao = hash.map do |field, pattern|
        format("REGEXP_LIKE(#{field}, '%s', 'i')", pattern.to_s)
      end.join(' OR ')
      where(expressao)
    end
  end
end

end # Boilerplate
