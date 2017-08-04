ENV['RACK_ENV'] = 'test'

$LOAD_PATH.unshift 'lib'
$LOAD_PATH.unshift 'app'

require 'minitest/autorun'
require 'rack/test'
require 'boilerplate'

module Boilerplate
  def self.root_directory
    Pathname.new(File.expand_path("#{File.dirname(__FILE__)}/fixtures"))
  end
end

module Minitest
  class Test
    def debugger
    end unless defined? debugger

    def fixtures
      datalist = [
        :users
      ]
      @fixtures ||= datalist.each_with_object Hash.new do |id, list|
        list[id] = Boilerplate.load_data(id)
        list
      end
    end

    def load_data(model)
      fixtures[model.table_name].symbolize_keys.each_with_object Hash.new do |(id, data), list|
        params = data.clone
        yield params if block_given?
        list[id] = model.find(params) || model.create(params)
        list
      end
    end

    def database
      @database ||= {}
      @database[:users] ||= load_data(User)
      @database
    end
  end

  module Assertions
    def assert_hash_equal(expected, actual, message = nil)
      messages = {}
      expected.keys.each do |key|
        equal = actual[key] == expected[key]
        messages[key] = build_message(message, "#{expected[key]} expected but was <?>", actual[key])
        assert_block(messages[key]) { expected[key] == actual[key] }
      end
    end
  end
end

class MockProcess
  def initialize
    @counter = 0
  end

  def write(data)
    $stdout.puts data
  end

  def read(data)
    $sdtout.puts data
  end

  def eof?
    @counter += 1
    @counter > 10 ? true : false
  end
end

class IO
  def self.popen(*args)
    MockProcess.new
  end
end
