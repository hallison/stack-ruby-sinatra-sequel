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

.m4.rb:
	$(munge) $(<) > $(@)

install: install.libraries

install.libraries:
	$(bundle) install

version: lib/$(name)/version.rb

# make db.migrate environment=[development]
db.migrate: db.migrate.up

migrate = $(sequel) -e $(environment) -E -l $(log) -m $(migrations)
db.migrate.up:
	$(migrate) $(connection).yml

db.migrate.down:
	$(migrate) -M $(changeset) $(connection).yml

# make db.console environment=[development]
db.console:
	$(sequel) -r $(name) -e $(environment) $(connection).yml

clean:
	rm -rf lib/$(name)/version.rb
