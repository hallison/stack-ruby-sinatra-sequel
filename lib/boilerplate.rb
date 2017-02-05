# encoding: utf-8

require 'pathname'
require 'yaml'
require 'sequel'
require 'boilerplate/version'

class String
  def camelcase
    gsub('/', ' :: ').split(/[ _]/).map(&:capitalize).join
  end

  def underscore
    gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
end

module Boilerplate
  class << self
    def root_directory
      @root_directory ||= Pathname.new(File.expand_path("#{File.basename(__FILE__)}/.."))
    end

    def environment
      ENV['RACK_ENV'].nil? ? :development : ENV['RACK_ENV'].to_sym
    end

    def load_config(file)
      load_yaml(:config, file)
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

  private

    def load_yaml(prefix, file)
      YAML.load_file(root_directory.join(prefix.to_s, "#{file}.yml"))
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
        @options = Boilerplate.database_config[env.to_sym]
        @options[:prefetch_rows] = 50
        if @options[:debug]
          require 'logger'
          @options[:loggers] = [Logger.new($stdout)]
        end
        @connection ||= Sequel.connect @options
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
      klass
    end

    module Methods
      def param_name
        id || ''
      end

      def to_url_param(prefix = nil)
        [prefix, param_name].compact.join('/')
      end

      def self.included(klass)
        klass.extend ClassMethods
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

  def self.autoload_sources
    sources_from(:models, :helpers, :controllers).each do |id, source|
      autoload source[:const_name], source[:require_path]
    end
  end

  autoload_sources

end # Boilerplate
