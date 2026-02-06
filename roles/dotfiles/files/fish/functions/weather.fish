function weather
    set data (curl -sf 'https://api.open-meteo.com/v1/forecast?latitude=52.23&longitude=21.01&daily=temperature_2m_max,temperature_2m_min&current_weather=true&timezone=Europe/Warsaw&forecast_days=16')
    or return 1
    echo $data | jq -c 'def lpad(n): tostring | (" " * ([0, n - length] | max)) + .;
    def rpad(n): tostring | (. + (" " * ([0, n - length] | max)));
    {
        text: "\(.current_weather.temperature | round)°",
        tooltip: ([.daily.time, .daily.temperature_2m_max, .daily.temperature_2m_min] | transpose | map((.[0] | strptime("%Y-%m-%d") | strftime("%A")) as $day | (.[0] | strptime("%Y-%m-%d") | strftime("%d.%m")) as $date | "\($day | rpad(9))  \($date)   \(.[1] | round | tostring + "°" | lpad(4)) / \(.[2] | round | tostring + "°" | lpad(4))") | join("\n"))
    }'
end
