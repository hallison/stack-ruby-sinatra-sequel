SHELL = /bin/bash
.SUFFIXES:

-include config.mk

name         = boilerplate
module       = Boilerplate
version     ?= 0.1.0
release     ?= 2016-10-08
database     = $(name)
environment ?= development

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

clean:
	rm -rf lib/$(name)/version.rb
