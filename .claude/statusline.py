#!/usr/bin/env python3
import json
import sys

# --- Nerd Font glyphs (FiraMono NF / JetBrainsMono NF) ---
IC_5H = ""        # clock        -> rate limit 5h
IC_7D = ""        # calendar     -> rate limit 7d
IC_CTX = ""       # database     -> context window
IC_COST = ""      # dollar       -> cost
IC_MODEL = ""     # microchip    -> model
IC_EFFORT = ""    # tachometer   -> effort

# --- 256-color ANSI ---
def c(code, s):
    return f"\x1b[38;5;{code}m{s}\x1b[0m"

DIM = 240
ICON = 75       # frost cyan
TEXT = 252
SEP = c(238, " │ ")

def pct_color(p):
    if p >= 80:
        return 203   # red
    if p >= 50:
        return 215   # amber
    return 114       # green


def main():
    raw = sys.stdin.read()
    try:
        data = json.loads(raw)
    except (ValueError, TypeError):
        data = {}
    d = data.get("data", data) if isinstance(data, dict) else {}

    parts = []
    rl = d.get("rate_limits", {}) or {}

    # model
    name = (d.get("model") or {}).get("display_name", "")
    if name:
        name = name.replace("Claude ", "").strip()
        parts.append(c(ICON, IC_MODEL) + " " + c(141, name))

    # effort (from stdin: effort.level)
    effort = (d.get("effort") or {}).get("level", "")
    if effort and effort != "unset":
        short = {"medium": "med"}.get(effort, effort)
        parts.append(c(ICON, IC_EFFORT) + " " + c(180, short))

    # fast mode flag
    if d.get("fast_mode") is True:
        parts.append(c(ICON, "") + " " + c(214, "fast"))

    # rate limit 5h (rolling)
    five = (rl.get("five_hour") or {}).get("used_percentage")
    if five is not None:
        parts.append(c(ICON, IC_5H) + " " + c(pct_color(five), f"{int(five)}%"))

    # rate limit 7d (weekly) — last
    seven = (rl.get("seven_day") or {}).get("used_percentage")
    if seven is not None:
        parts.append(c(ICON, IC_7D) + " " + c(pct_color(seven), f"{int(seven)}%"))

    sys.stdout.write(SEP.join(parts))


if __name__ == "__main__":
    main()
