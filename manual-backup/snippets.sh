#!/bin/bash

# Combine all downloaded spotify json files
cat "$(ls spotify_json_backups/spotify*.json)" | jq -s 'reduce .[] as $item ({}; . * $item)' | jq -s '.[]' | jq -s ".[] | $(cat spotify_albums.jq)" | bat -ljson
