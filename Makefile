MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
ROOT_DIR := $(patsubst %/,%,$(dir $(MAKEFILE_PATH)))

# Folders
STORAGE_DIR = $(ROOT_DIR)/storage
BOOTSTRAP_CACHE_DIR = $(ROOT_DIR)/bootstrap/cache
NODE_MODULES_BIN_DIR = $(ROOT_DIR)/node_modules/.bin

# Executable
PHP = /usr/bin/env php
NPM = /usr/bin/env npm
BOWER = $(NODE_MODULES_BIN_DIR)/bower
GULP = $(NODE_MODULES_BIN_DIR)/gulp
COMPOSER = $(ROOT_DIR)/composer.phar
ARTISAN = $(ROOT_DIR)/artisan

# Public

default: build

build: install-composer composer-install set-file-permission npm-install bower-install gulp-default

seed:
	@$(PHP) $(ARTISAN) migrate --seed

ide:
	@$(PHP) $(ARTISAN) ide-helper:generate --memory
	@$(PHP) $(ARTISAN) ide-helper:meta
	@$(PHP) $(ARTISAN) ide-helper:models --nowrite

# Internal

install-composer:
	@if [ ! -f $(COMPOSER) ]; then echo "..downloading Composer"; curl -sS https://getcomposer.org/installer | $(PHP) -- --install-dir=$(ROOT_DIR); fi

composer-install:
	@echo "..installing dependencies with Composer"
	@$(PHP) $(COMPOSER) install --no-interaction --no-progress

set-file-permission:
	@echo "..setting permission for $(STORAGE_DIR)"
	@find $(STORAGE_DIR) -type d -exec chmod 0777 {} \;
	@echo "..setting permission for $(BOOTSTRAP_CACHE_DIR)"
	@chmod 0777 $(BOOTSTRAP_CACHE_DIR)

npm-install:
	@echo "..installing NodeJS packages"
	@$(NPM) install

bower-install:
	@echo "..installing Bower packages"
	@$(BOWER) install --config.interactive=false

gulp-default:
	@echo "..running default Gulp task"
	@$(GULP)

.PHONY: default build seed ide create-toolsdir install-composer composer-install set-file-permission npm-install bower-install gulp-default
