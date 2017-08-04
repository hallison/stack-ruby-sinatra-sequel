$LOAD_PATH.unshift '.'

require 'bundler'

Bundler.require

require 'test/helpers'

filename_pattern = "test/#{ARGV[0]}/"
filename_pattern = filename_pattern + (ARGV[1] || '*') + '_test.rb'

Dir[filename_pattern].each do |test|
  load test
end
