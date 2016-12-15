$LOAD_PATH.unshift '.'

require 'test/helpers'

filename_pattern = "test/#{ARGV[0]}/*_test.rb"

Dir[filename_pattern].each do |test|
  load test
end
