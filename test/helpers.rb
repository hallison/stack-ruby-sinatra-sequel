$LOAD_PATH.unshift 'lib'
$LOAD_PATH.unshift 'app'

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'boilerplate'

ENV['RACK_ENV'] = 'test'

module Minitest
  class Test
    def fixtures(*args)
      Boilerplate.root_directory.join('test','fixtures').join(*(args.map(&:to_s)))
    end

    def debugger
    end unless defined? debugger

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
