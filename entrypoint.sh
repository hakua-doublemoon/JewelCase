#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /myapp/tmp/pids/server.pid

# Then exec the container's main process (what's set as CMD in the Dockerfile).
ruby "/myapp/app/models/VlcServer.rb" &
touch "/myapp/app/models/VlcServer.pid"

exec "$@"

