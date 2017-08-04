@environment = ENV['RACK_ENV'] || 'development'

environment @environment

tag 'boilerplate'

if @environment == 'production'
  @url = ENV['PORT'] && "tcp://0.0.0.0:#{ENV['PORT']}" || "unix:///tmp/boilerplate-#{@environment}.sock"
  daemonize true
  bind @url
  stdout_redirect "log/#{@environment}.out.log", "log/#{@environment}.err.log", true
else
  daemonize false
  quiet false
  bind 'tcp://0.0.0.0:8090'
end

pidfile "tmp/boilerplate-#{@environment}.pid"

state_path "tmp/boilerplate-#{@environment}.state"

threads 0, 16

on_restart do
  puts 'boilerplate: Restart...'
end

workers 0
