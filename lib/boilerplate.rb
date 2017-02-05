# encoding: utf-8

require 'pathname'
require 'yaml'
require 'sequel'
require 'boilerplate/version'

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

end # Boilerplate
