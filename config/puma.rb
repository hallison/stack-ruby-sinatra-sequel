@environment = ENV['RACK_ENV'] || 'development'

environment @environment

tag 'boilerplate'

if @environment == 'development'
  quiet false
  bind 'tcp://0.0.0.0:8090'
else
  bind "unix:///tmp/boilerplate-#{@environment}.sock"
  daemonize true
end

stdout_redirect "log/#{@environment}.out.log", "log/#{@environment}.err.log", true

pidfile "tmp/boilerplate-#{@environment}.pid"

state_path "tmp/boilerplate-#{@environment}.state"

threads 0, 16

on_restart do
  puts 'boilerplate: Restart...'
end

workers 0
