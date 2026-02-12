#!/usr/bin/env python3
"""
Custom mouse gesture handler for qutebrowser
Maps complex gestures to qutebrowser commands via IPC

Gestures:
- Right + Down + Left = Restore tab (undo close)
- Right + Down + Up = New tab
- Right + Down + Right = Close tab
- Right + Up + Down = Reload tab
- Right + Right = Next tab
- Right + Left = Previous tab
"""

import sys
import subprocess

GESTURE_COMMANDS = {
    "RDL": "undo",  # Right-Down-Left = restore tab
    "RDU": "open -t",  # Right-Down-Up = new tab
    "RDR": "tab-close",  # Right-Down-Right = close tab
    "RUD": "reload",  # Right-Up-Down = reload
    "RR": "tab-next",  # Right-Right = next tab
    "RL": "tab-prev",  # Right-Left = previous tab
}


def send_qutebrowser_command(command):
    """Send command to qutebrowser via IPC"""
    try:
        subprocess.run(
            ["qutebrowser", f":{command}"],
            check=True,
            capture_output=True,
        )
    except subprocess.CalledProcessError:
        pass


def main():
    if len(sys.argv) < 2:
        print("Usage: qutebrowser-gestures.py GESTURE")
        sys.exit(1)

    gesture = sys.argv[1].upper()
    command = GESTURE_COMMANDS.get(gesture)

    if command:
        send_qutebrowser_command(command)
    else:
        print(f"Unknown gesture: {gesture}")


if __name__ == "__main__":
    main()
