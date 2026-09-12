#!/usr/bin/env bash

WEATHER_JSON="/home/nox/.local/cache/noctalia/location.json"

read TEMP WINDSPEED CODE < <(gojq -r '[
  .weather.current_weather.temperature,
  .weather.current_weather.windspeed,
  .weather.current_weather.weathercode
] | @tsv' "$WEATHER_JSON")

case $CODE in
  0)        DESC="Clear"        ;;
  1)        DESC="Mostly clear" ;;
  2)        DESC="Partly cloudy";;
  3)        DESC="Overcast"     ;;
  45|48)    DESC="Fog"          ;;
  51|53|55) DESC="Drizzle"      ;;
  61|63|65) DESC="Rain"         ;;
  71|73|75) DESC="Snow"         ;;
  80|81|82) DESC="Showers"      ;;
  95)       DESC="Thunderstorm" ;;
  *)        DESC="Unknown"      ;;
esac

echo "${TEMP}°C, ${DESC}, wind ${WINDSPEED} km/h"
