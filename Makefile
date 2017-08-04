SHELL = /bin/bash
.SUFFIXES:

-include config.mk

name         = boilerplate
module       = Boilerplate
version     ?= 0.1.0
release     ?= 2016-10-08
database     = $(name)
environment ?= development
connection   = config/database
migrations   = db/migrations
log          = log/$(environment).db.log

munge  = m4
munge += -D_NAME='$(name)'
munge += -D_VERSION='$(version)'
munge += -D_RELEASE='$(release)'
munge += -D_ENVIRONMENT='$(environment)'

ruby    = exec ruby -S
bundle  = $(ruby) bundle
pry     = $(bundle) exec pry -Ilib -Iapp
pumactl = $(bundle) exec pumactl

.SUFFIXES: .m4 .rb

#? Default target
#? $ make [check]
all: check

.m4.rb:
	$(munge) $(<) > $(@)

install: install.libraries db.migrate install.resources

install.libraries:
	$(bundle) install

version: lib/$(name)/version.rb

console: version
	RACK_ENV=$(environment) $(pry) -r $(name) -e 'include $(module)'

#?
#? Development HTTP server
#? $ make server environment=[development|production]
server: server.start

#? $ make server.[start|stop|restart]
server.start server.stop: version
	$(pumactl) --pidfile tmp/$(environment).pid $(@:server.%=%)

server.restart: server.stop server.start

#?
#? Database migration
#? $ make db.migrate environment=[development|production] target=[999]
db.migrate: version
	$(ruby) db/$(@:db.%=%).rb $(environment) $(target)

#? $ make db.bootstrap
#? $ make db.hotfix
db.migrations db.bootstrap db.hotfix: version
	$(ruby) db/$(@:db.%=%).rb $(environment) v$(version)

#?
#? Clean sources
#? $ make clean
clean:
	rm -f $(name).db
	rm -rf lib/$(name)/version.rb
	rm -rf public/vendor/*

#?
#? Check and test
#? $ make check
check: check.models check.controllers

#? $ make check.[models|controllers] source=[NAME]
check.models check.controllers:
	$(ruby) test/check.rb $(@:check.%=%) $(source)

#?
#? Up and downgrade
#? $ make upgrade
upgrade: clean install version db.migrate.up db.bootstrap db.hotfix

#? $ make downgrade
downgrade: clean version db.migrate.down

#?
#? Distributable file
#? $ make dist
dist: version
	git archive --format=zip --output=$(name)-$(version).zip --prefix=$(name)/ --verbose $(version)

help:
	@grep '^#?' Makefile | cut -c4-
