$LOAD_PATH.unshift 'lib'
$LOAD_PATH.unshift 'app'

require 'boilerplate'

include Boilerplate

environment, target = *ARGV
migration_path = Database.migration_path

if migration_path.exist?
  Boilerplate.set_environment_to environment
else
  warn "Unable to find #{migration_path} "
  exit(0)
end

if target
  migrator = Database.migrator(target.to_i)
else
  migrator = Database.migrator
end

migrator.run
