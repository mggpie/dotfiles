function weather
    set data (curl -sf 'https://api.open-meteo.com/v1/forecast?latitude=52.23&longitude=21.01&daily=temperature_2m_max,temperature_2m_min,weathercode&current_weather=true&timezone=Europe/Warsaw&forecast_days=16')
    or return 1
    echo $data | jq -c 'def lpad(n): tostring | (" " * ([0, n - length] | max)) + .;
    def rpad(n): tostring | (. + (" " * ([0, n - length] | max)));
    def wmo_icon: if . == 0 then "󰖙" elif . <= 3 then "󰖐" elif . <= 48 then "󰖑" elif . <= 55 then "󰖗" elif . <= 65 then "󰖖" elif . <= 77 then "󰖘" elif . <= 82 then "󰖖" elif . <= 86 then "󰖘" else "󰖓" end;
    def wmo_desc: if . == 0 then "Clear" elif . == 1 then "Mostly clear" elif . == 2 then "Partly cloudy" elif . == 3 then "Overcast" elif . == 45 or . == 48 then "Fog" elif . == 51 then "Light drizzle" elif . == 53 then "Drizzle" elif . == 55 then "Dense drizzle" elif . == 61 then "Light rain" elif . == 63 then "Rain" elif . == 65 then "Heavy rain" elif . == 71 then "Light snow" elif . == 73 then "Snow" elif . == 75 then "Heavy snow" elif . == 77 then "Snow grains" elif . == 80 then "Light showers" elif . == 81 then "Showers" elif . == 82 then "Heavy showers" elif . == 85 then "Light snow showers" elif . == 86 then "Snow showers" elif . == 95 then "Thunderstorm" elif . == 96 or . == 99 then "Thunderstorm with hail" else "Unknown" end;
    {
        text: "<span size=\"x-large\">\(.current_weather.weathercode | wmo_icon)</span>  <span rise=\"2000\">\(.current_weather.temperature | round)°C</span>",
        tooltip: "\(.current_weather.weathercode | wmo_icon)  \(.current_weather.weathercode | wmo_desc), \(.current_weather.temperature | round)°C\n\n" + ([.daily.time, .daily.temperature_2m_max, .daily.temperature_2m_min, .daily.weathercode] | transpose | map((.[0] | strptime("%Y-%m-%d") | strftime("%A")) as $day | (.[0] | strptime("%Y-%m-%d") | strftime("%d.%m")) as $date | "\(.[3] | wmo_icon)  \($day | rpad(9))  \($date)   \(.[1] | round | tostring + "°C" | lpad(5)) / \(.[2] | round | tostring + "°C" | lpad(5))  \(.[3] | wmo_desc)") | join("\n"))
    }'
end
