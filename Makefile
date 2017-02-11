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
changeset    = -1

munge  = m4
munge += -D_NAME='$(name)'
munge += -D_VERSION='$(version)'
munge += -D_RELEASE='$(release)'
munge += -D_ENVIRONMENT='$(environment)'

ruby    = exec ruby -S
bundle  = $(ruby) bundle
sequel  = $(bundle) exec sequel -Ilib -Iapp -t
pry     = $(bundle) exec pry -Ilib -Iapp
pumactl = $(bundle) exec pumactl

.SUFFIXES: .m4 .rb

#? Default target
#? $ make [check]
all: check

.m4.rb:
	$(munge) $(<) > $(@)

install: install.libraries

install.libraries:
	$(bundle) install

version: lib/$(name)/version.rb

console: version
	$(pry) -r $(name) -e 'include $(module)'

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
#? $ make db.migrate environment=[development|production]
db.migrate: db.migrate.up

#? $ make db.migrate.[up|down]
migrate = $(sequel) -e $(environment) -E -l $(log) -m $(migrations)
db.migrate.up:
	$(migrate) $(connection).yml

db.migrate.down:
	$(migrate) -M $(changeset) $(connection).yml

#? $ make db.console environment=[development|production]
db.console:
	$(sequel) -r $(name) -e $(environment) $(connection).yml

#?
#? Clean sources
#? $ make clean
clean:
	find -iname '*.bkp' | xargs rm
	rm -rf lib/$(name)/version.rb
	rm -rf public/vendor/*

#?
#? Check and test
#? $ make check
check: check.models check.controllers

#? $ make check.[models|controllers]
check.models check.controllers:
	$(ruby) test/check.rb $(@:check.%=%)

help:
	@grep '^#?' Makefile | cut -c4-
