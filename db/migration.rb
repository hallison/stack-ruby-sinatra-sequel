$LOAD_PATH.unshift 'lib'
$LOAD_PATH.unshift 'app'

require 'boilerplate'

include Boilerplate

environment = ARGV.at(0)
migration_path = Database.migration_path

if migration_path.exist?
  Boilerplate.set_environment_to environment
  migrator = Database.migrator

  migration_path.children.map do |file|
    file.basename.to_s
  end.select do |basename|
    basename =~ /.*\.rb$/
  end.sort.each_with_index do |basename, i|
    counter = i + 1
    current = basename.split('_').at(0).to_i
    status = (migrator.current >= current) ? '*' : ' '
    printf("%s %s\n", status, basename)
  end
else
  warn "Unable to find #{migration_path} "
  exit(0)
end
