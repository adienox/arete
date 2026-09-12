#!/usr/bin/env bash

CACHE_TTL=$((30 * 60)) # 30 minutes in seconds
format="\(.weatherDesc[0].value), \(.temp_C)°C |   \(.windspeedKmph) kph"

# Determine cache path
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}"
cache_file="$cache_dir/weather.json"
mkdir -p "$cache_dir"

# Check cache freshness
is_cache_fresh=false
if [[ -f "$cache_file" ]]; then
    last_mod=$(date -r "$cache_file" +%s 2>/dev/null)
    now=$(date +%s)
    ((now - last_mod < CACHE_TTL)) && is_cache_fresh=true
fi

# If cache is fresh, just output and exit
if $is_cache_fresh; then
    gojq -er ".current_condition[0] | \"$format\"" "$cache_file" 2>/dev/null
    exit 0
fi

# Try to detect city
city=$(curl -m 2 -s ipinfo.io | jq -r '.city // empty' 2>/dev/null)

# If no city and no cache → remain silent and exit
if [[ -z "$city" && ! -f "$cache_file" ]]; then
    exit 1
fi

# Fetch new weather data
tmp_file=$(mktemp)
if curl -m 3 -s "wttr.in/${city}?format=j1" -o "$tmp_file"; then
    # Validate JSON content before replacing cache
    if gojq -er ".current_condition[0].temp_C" "$tmp_file" &>/dev/null; then
        mv "$tmp_file" "$cache_file"
    else
        rm -f "$tmp_file"
    fi
else
    rm -f "$tmp_file"
fi

# Final output if cache exists (new or old)
if [[ -f "$cache_file" ]]; then
    gojq -er ".current_condition[0] | \"$format\"" "$cache_file" 2>/dev/null
fi
