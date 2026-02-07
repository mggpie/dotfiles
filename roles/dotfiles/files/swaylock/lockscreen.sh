#!/bin/sh
# Generate a lock screen image with clock, date and weather, then lock with swaylock

RES="3440x1440"
IMG="/tmp/lockscreen.png"
FONT="/usr/share/fonts/TTF/inter/Inter-Regular.ttf"
WHITE="#D0CFCC"
GRAY="#555753"
BLUE="#3465A4"

# Current time and date
TIME=$(date '+%H:%M')
DATE=$(date '+%A, %-d %B')

# Weather (reuse open-meteo API)
WEATHER=$(curl -sf 'https://api.open-meteo.com/v1/forecast?latitude=52.23&longitude=21.01&daily=temperature_2m_max,temperature_2m_min&current_weather=true&timezone=Europe/Warsaw&forecast_days=1' 2>/dev/null)
if [ -n "$WEATHER" ]; then
    TEMP=$(echo "$WEATHER" | jq -r '.current_weather.temperature | round')
    TMIN=$(echo "$WEATHER" | jq -r '.daily.temperature_2m_min[0] | round')
    TMAX=$(echo "$WEATHER" | jq -r '.daily.temperature_2m_max[0] | round')
    CODE=$(echo "$WEATHER" | jq -r '.current_weather.weathercode')
    case $CODE in
        0)  DESC="Clear" ;;
        1)  DESC="Mostly clear" ;;
        2)  DESC="Partly cloudy" ;;
        3)  DESC="Overcast" ;;
        45|48) DESC="Fog" ;;
        51) DESC="Light drizzle" ;;
        53) DESC="Drizzle" ;;
        55) DESC="Dense drizzle" ;;
        61) DESC="Light rain" ;;
        63) DESC="Rain" ;;
        65) DESC="Heavy rain" ;;
        71) DESC="Light snow" ;;
        73) DESC="Snow" ;;
        75) DESC="Heavy snow" ;;
        80) DESC="Light showers" ;;
        81) DESC="Showers" ;;
        82) DESC="Heavy showers" ;;
        95) DESC="Thunderstorm" ;;
        *)  DESC="Unknown" ;;
    esac
    WEATHER_LINE1="${DESC}  ${TEMP}°C"
    WEATHER_LINE2="↓ ${TMIN}°C   ↑ ${TMAX}°C"
else
    WEATHER_LINE1=""
    WEATHER_LINE2=""
fi

# Generate image
magick -size "$RES" xc:"#000000" \
    -gravity center \
    -font "$FONT" \
    -fill "$WHITE" \
    -pointsize 200 -annotate +0-120 "$TIME" \
    -fill "$GRAY" \
    -pointsize 40 -annotate +0+20 "$DATE" \
    -fill "$BLUE" \
    -pointsize 32 -annotate +0+90 "$WEATHER_LINE1" \
    -fill "$GRAY" \
    -pointsize 26 -annotate +0+135 "$WEATHER_LINE2" \
    "$IMG"

# Lock
exec swaylock \
    -f \
    -i "$IMG" \
    --scaling fill \
    --indicator-radius 1 \
    --indicator-thickness 0 \
    --inside-color 00000000 \
    --ring-color 00000000 \
    --line-color 00000000 \
    --separator-color 00000000 \
    --text-color 00000000 \
    --inside-ver-color 00000000 \
    --ring-ver-color 00000000 \
    --text-ver-color 00000000 \
    --inside-wrong-color 00000000 \
    --ring-wrong-color CC000088 \
    --text-wrong-color 00000000 \
    --inside-clear-color 00000000 \
    --ring-clear-color 00000000 \
    --text-clear-color 00000000 \
    --key-hl-color 00000000 \
    --bs-hl-color 00000000 \
    --show-failed-attempts
