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
end # Boilerplate
