# encoding: utf-8

# ENV['NLS_LANG'] = 'AMERICAN_AMERICA.UTF8'
# ENV['NLS_SORT'] = 'BINARY_AI'
# ENV['NLS_COMP'] = 'LINGUISTIC'
# DEFAULT_OCI8_ENCODING = 'utf-8'

require 'date'
require 'pathname'
require 'yaml'
require 'sequel'
require 'json'
require 'boilerplate/extensions'
require 'boilerplate/version'

module Boilerplate
  PATTERN_EMAIL = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  PATTERN_USERNAME = /^[a-zA-Z][a-zA-Z0-9\-_\.]{6,32}$/

  class << self
    def root_directory
      @root_directory ||= Pathname.new(File.expand_path("#{File.basename(__FILE__)}/.."))
    end

    def environment
      @environment ||= ENV['RACK_ENV'] ? ENV['RACK_ENV'].to_sym : :development
    end

    def set_environment_to(new_environment)
      @environment = new_environment.to_sym
    end

    def load_config(file)
      load_yaml(:config, file).symbolize_keys
    end

    def load_data(file)
      load_yaml(:db, file)
    end

    def application_config
      @application_config ||= load_config(:application)
    end

    def database_config
      @database_config ||= load_config(:database)
    end

    def routing
      @routing ||= application_config[:routing].each_with_object Hash.new do |(id, route), routes|
        (const_name = controllers[id]) && (routes[id] = [const_name, route[:root]])
        (const_name.nil?) && (warn "--> Routing to '#{id}' was not found")
        routes
      end
      @routing
    end

    def mapping
      @mapping ||= application_config[:routing].each_with_object Hash.new do |(id, route), maps|
        actions = (route[:actions] || {})
        maps[id] = actions.merge index: '/'
        maps
      end
      @mapping
    end

    alias sections mapping

    def controllers
      @controllers ||= constants.grep(/Controller/).each_with_object Hash.new do |const_name, hash|
        hash[const_get(const_name).controller_id] = const_get(const_name)
        hash
      end
      @controllers
    end

    def sources_from(*pathnames)
      pathnames.each_with_object({}) do |pathname, sources|
        Dir[root_directory.join('app').join(pathname.to_s).join('*.rb')].each do |source|
          id = File.basename(source.gsub(/.*\/#{pathname}/, ''), '.rb')
          sources[id.to_sym] = {
            require_path: "#{pathname}/#{id}",
            const_name: id.camelcase.to_sym
          }
        end
      end
    end

    def autoload_sources(*paths)
      sources_from(*paths).each do |id, source|
        autoload source[:const_name], source[:require_path]
      end
    end

  private

    def load_yaml(prefix, file)
      require 'erb'
      YAML.load(ERB.new(root_directory.join(prefix.to_s, "#{file}.yml").read).result)
    end
  end

  class Database
    # Sequel::Inflections.clear

    # Sequel.inflections do |inflect|
    #   inflect.irregular 'autor', 'autores'
    #   inflect.irregular 'classificacao', 'classificacoes'
    # end

    class << self
      attr_reader :options

      def connection(env = Boilerplate.environment)
        options = Boilerplate.database_config[env.to_sym]
        options[:prefetch_rows] = 50
        if options[:debug]
          require 'logger'
          options[:loggers] = [Logger.new($stdout)]
        end
        @connection ||= Sequel.connect(options)
      end

      def migration_path
        Boilerplate.root_directory.join('db', "migrations")
      end

      def migrator(target = 999)
        Sequel.extension(:migration)
        Sequel::IntegerMigrator.new(connection, migration_path, target: target)
      end

      def [](dataset)
        connection[dataset]
      end
    end
  end # Database

  module Model
    def self.[](dataset_name)
      klass = Sequel::Model(Database[dataset_name])
      # Oracle
      # klass.dataset = klass.dataset.sequence("s_#{dataset_name}".to_sym)
      klass.include Methods
      klass.plugin :validation_helpers
      klass.plugin :whitelist_security
      klass
    end

    module Methods
      def self.included(klass)
        klass.extend ClassMethods
      end

      def param_name
        (id || '').to_s
      end

      def to_url_param(prefix = nil)
        [prefix, param_name_slug].compact.join('/')
      end

      def before_create
        (self.class.columns && self.class.columns.include?(:creation_date)) && (self.creation_date ||= Time.now)
        super
      end

      def before_save
        (self.class.columns && self.class.columns.include?(:modification_date)) && (self.modification_date = Time.now)
        super
      end

    protected

      def param_name_slug
        param_name.normalize.downcase.gsub(/\W/, '-').sub(/-$/,'').squeeze('-')
      end

      def generate_uuid(*keys)
        keys.join.normalize.gsub(/\W/,'').downcase.md5
      end

      module ClassMethods
        def column_aliases
          columns.map do |column|
            "#{table_name}__#{column}".to_sym
          end
        end
      end
    end
  end # Model

  autoload_sources :models, :helpers, :controllers
end # Boilerplate
