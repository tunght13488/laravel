MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
ROOT_DIR := $(patsubst %/,%,$(dir $(MAKEFILE_PATH)))

# Folders
DEVOPSDIR = $(ROOT_DIR)/devops
DEVOPSBINDIR = $(DEVOPSDIR)/bin
TOOLSDIR = $(ROOT_DIR)/tools
STORAGEDIR = $(ROOT_DIR)/storage
VENDORDIR = $(ROOT_DIR)/vendor
BOOTSTRAPCACHE = $(ROOT_DIR)/bootstrap/cache

# Executable
PHP = /usr/bin/env php
NPM = /usr/bin/env npm
BOWER = /usr/bin/env bower
GULP = /usr/bin/env gulp
COMPOSER = $(TOOLSDIR)/composer.phar
ARTISAN = $(ROOT_DIR)/artisan

# Other

default: help

# PUBLIC

help:
	@echo "Targets:"
	@echo "  - clean"
	@echo "  - install"

clean:
	@echo "..removing '$(TOOLSDIR)' folder"
	@rm -rf $(TOOLSDIR)
	@echo "..removing '$(VENDORDIR)' folder"
	@rm -rf $(VENDORDIR)

install: install-composer install-deps set-file-permission install-frontend-deps compile-frontend

seed:
	@$(PHP) $(ARTISAN) migrate --seed

# INTERNAL

create-toolsdir:
	@if [ ! -d $(TOOLSDIR) ]; then echo "..creating '$(TOOLSDIR)' folder"; mkdir $(TOOLSDIR); fi

install-composer: create-toolsdir
	@if [ ! -f $(COMPOSER) ]; then echo "..downloading Composer"; curl -sS https://getcomposer.org/installer | $(PHP) -- --install-dir=$(TOOLSDIR); fi

install-deps:
	@echo "..installing dependencies with Composer"
	@$(PHP) $(COMPOSER) install --no-progress

set-file-permission:
	@echo "..setting permission for $(STORAGEDIR)"
	@find $(STORAGEDIR) -type d -exec chmod 0777 {} \;
	@echo "..setting permission for $(BOOTSTRAPCACHE)"
	@chmod 0777 $(BOOTSTRAPCACHE)

install-frontend-deps:
	@echo "..installing NodeJS packages"
	@$(NPM) install
	@echo "..installing Bower packages"
	@$(BOWER) install

compile-frontend:
	@echo "..compiling frontend assets"
	@$(GULP)

.PHONY: default help clean install create-toolsdir install-composer install-deps set-file-permission install-frontend-deps compile-frontend
