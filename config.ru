# encoding: utf-8

$LOAD_PATH.unshift 'lib'
$LOAD_PATH.unshift 'app'

require 'boilerplate'

Boilerplate.routing.each do |id, (controller, route)|
  map route do
    run controller
  end
end
