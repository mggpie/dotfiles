#!/usr/bin/env python3
import json
import datetime
import re
import calendar

calendar.setfirstweekday(0)  # Monday

MONTH_NAMES = [
    '', 'Styczeń', 'Luty', 'Marzec', 'Kwiecień', 'Maj', 'Czerwiec',
    'Lipiec', 'Sierpień', 'Wrzesień', 'Październik', 'Listopad', 'Grudzień'
]


def easter(year):
    """Easter Sunday via Anonymous Gregorian algorithm."""
    a = year % 19
    b, c = divmod(year, 100)
    d, e = divmod(b, 4)
    f = (b + 8) // 25
    g = (b - f + 1) // 3
    h = (19 * a + b - d - g + 15) % 30
    i, k = divmod(c, 4)
    l = (32 + 2 * e + 2 * i - h - k) % 7
    m = (a + 11 * h + 22 * l) // 451
    month = (h + l - 7 * m + 114) // 31
    day = (h + l - 7 * m + 114) % 31 + 1
    return datetime.date(year, month, day)


def polish_holidays(year):
    e = easter(year)
    td = datetime.timedelta
    return {
        datetime.date(year, 1, 1),    # Nowy Rok
        datetime.date(year, 1, 6),    # Trzech Krolow
        datetime.date(year, 5, 1),    # Swieto Pracy
        datetime.date(year, 5, 3),    # Konstytucja 3 Maja
        datetime.date(year, 8, 15),   # Wniebowziecie NMP
        datetime.date(year, 11, 1),   # Wszystkich Swietych
        datetime.date(year, 11, 11),  # Niepodleglosci
        datetime.date(year, 12, 25),  # Boze Narodzenie
        datetime.date(year, 12, 26),  # Drugi dzien BN
        e,              # Wielka Niedziela
        e + td(1),      # Wielki Poniedzialek
        e + td(49),     # Zielone Swiatki
        e + td(60),     # Boze Cialo
    }


def pango_len(s):
    """Visible character count of a Pango markup string (strips tags)."""
    return len(re.sub(r'<[^>]+>', '', s))


def pango_ljust(s, width):
    pad = width - pango_len(s)
    return s + ' ' * max(0, pad)


def fmt_day(raw, is_today, is_off):
    if is_today and is_off:
        return f"<b><span color='#ff8888' background='#4a1a1a'>{raw}</span></b>"
    if is_today:
        return f"<b><span background='#444444'>{raw}</span></b>"
    if is_off:
        return f"<span color='#cc3333'>{raw}</span>"
    return raw


def render_month(year, month, today, holidays):
    COL_W = 20
    header = f"{MONTH_NAMES[month]} {year}".center(COL_W)
    # Su column header colored red to signal it's always off
    week_hdr = "Mo Tu We Th Fr Sa <span color='#cc3333'>Su</span>"
    lines = [header, week_hdr]

    for week in calendar.monthcalendar(year, month):
        parts = []
        for day in week:
            if day == 0:
                parts.append("  ")
            else:
                d = datetime.date(year, month, day)
                raw = f"{day:2d}"
                parts.append(fmt_day(raw, d == today, d in holidays or d.weekday() == 6))
        lines.append(" ".join(parts))

    return lines


def build_calendar(year, today, holidays):
    months = [render_month(year, m, today, holidays) for m in range(1, 13)]
    SEP = "   "
    COL_W = 20
    lines = []

    for row in range(4):
        group = months[row * 3:(row + 1) * 3]
        max_h = max(len(m) for m in group)
        for m in group:
            m += [''] * (max_h - len(m))
        for i in range(max_h):
            lines.append(SEP.join(pango_ljust(group[c][i], COL_W) for c in range(3)))
        if row < 3:
            lines.append('')

    return '\n'.join(lines)


def main():
    today = datetime.date.today()
    year = today.year
    holidays = polish_holidays(year)

    text = datetime.datetime.now().strftime('%a, %d %b  %H:%M')
    tooltip = build_calendar(year, today, holidays)

    print(json.dumps({'text': text, 'tooltip': tooltip, 'class': ''}))


if __name__ == '__main__':
    main()
