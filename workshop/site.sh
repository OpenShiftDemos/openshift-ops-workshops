#!/bin/bash

_CURR_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
rm -rf $_CURR_DIR/gh-pages $_CURR_DIR/.cache

antora --pull --stacktrace  site.yml