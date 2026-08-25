#!/usr/bin/env python3
import json
import os
import subprocess
import sys
import time

# --- Nerd Font glyphs (FiraMono NF / JetBrainsMono NF) ---
IC_5H = ""  # clock        -> rate limit 5h
IC_7D = ""  # calendar     -> rate limit 7d
IC_MODEL = ""  # microchip    -> model
IC_EFFORT = ""  # tachometer   -> effort

# --- 256-color ANSI ---
def c(code, s):
    return f"\x1b[38;5;{code}m{s}\x1b[0m"

ICON = 75       # frost cyan
TEXT = 252
SEP = c(238, " │ ")

# toggled by the statusline-toggle script — "icons" (default) or "text"
STYLE_FILE = os.path.expanduser("~/.claude/statusline-style")


def get_style():
    try:
        s = open(STYLE_FILE, encoding="utf-8").read().strip()
    except OSError:
        return "icons"
    return s if s in ("icons", "text") else "icons"

# each model maps to a fill level on the same circle_slice scale as the
# rate-limit circles (haiku=light/fast .. opus=full/top-tier); fable sits off
# the cost axis (narrative-purpose, not "bigger" than opus) so it gets its
# own level instead of colliding with sonnet or opus
MODEL_LEVELS = {
    "haiku":  25,
    "sonnet": 50,
    "fable":  75,
    "opus":   100,
}

# effort maps onto the same circle_slice scale, reusing pct_color's own
# severity ramp for color (114 green / 215 amber / 220 amber-high / 203 red);
# max keeps the fire glyph instead of a fuller circle — xhigh is already a
# full circle, so max still needs a shape break to be told apart
EFFORT_LEVELS = {
    "low":    (25, 114),
    "medium": (50, 220),
    "high":   (75, 215),
    "xhigh":  (100, 203),
}
EFFORT_MAX_GLYPH = ("", 203)  # fire — beyond full, breaks the circle metaphor on purpose


def pct_color(p):
    if p >= 80:
        return 203   # red
    if p >= 50:
        return 215   # amber
    return 114       # green


# md-circle_slice_1 .. md-circle_slice_8 — a circle filled in eighths, index 0 = 1/8
CIRCLE_SLICES = ["󰪞", "󰪟", "󰪠", "󰪡", "󰪢", "󰪣", "󰪤", "󰪥"]
CIRCLE_EMPTY = ""  # fa-circle_thin — 0%, no slice reads as "empty" rather than "1/8"


def circle_glyph(p):
    level = round(max(0, min(100, p)) / 100 * 8)
    return CIRCLE_EMPTY if level == 0 else CIRCLE_SLICES[level - 1]


def main():
    raw = sys.stdin.read()
    try:
        data = json.loads(raw)
    except (ValueError, TypeError):
        data = {}
    d = data.get("data", data) if isinstance(data, dict) else {}

    style = get_style()
    parts = []
    # Claude Code does not always put rate_limits on stdin. vibe-island keeps a
    # fresh copy on disk, so read that when the payload has none — else the
    # quota glyphs vanish with no sign of why.
    rl = d.get("rate_limits") or {}
    if not rl:
        try:
            with open(os.path.expanduser("~/.vibe-island/cache/rl.json")) as f:
                rl = json.load(f) or {}
        except Exception:
            rl = {}
    now = time.time()

    # model + effort
    if style == "text":
        name = (d.get("model") or {}).get("display_name", "")
        effort = (d.get("effort") or {}).get("level", "")
        compact = []
        if name:
            words = name.replace("Claude ", "").strip().split()
            family = words[0][:3].lower() if words else ""
            version = words[1] if len(words) > 1 else ""
            if family:
                compact.append(f"{family}-{version}" if version else family)
        if effort and effort != "unset":
            short = {"medium": "med"}.get(effort, effort)
            compact.append(short[:3])
        if compact:
            parts.append(c(ICON, IC_MODEL) + " " + c(141, "-".join(compact)))
    else:
        model_effort = []
        name = (d.get("model") or {}).get("display_name", "").lower()
        if name:
            key = next((k for k in MODEL_LEVELS if k in name), None)
            level = MODEL_LEVELS.get(key)
            glyph = circle_glyph(level) if level is not None else CIRCLE_EMPTY
            model_effort.append(c(ICON, glyph))

        effort = (d.get("effort") or {}).get("level", "")
        if effort and effort != "unset":
            if effort == "max":
                glyph, color = EFFORT_MAX_GLYPH
            else:
                level = EFFORT_LEVELS.get(effort)
                if level:
                    pct, color = level
                    glyph = circle_glyph(pct)
                else:
                    glyph, color = (IC_EFFORT, ICON)
            model_effort.append(c(color, glyph))

        if model_effort:
            parts.append(" ".join(model_effort))

    # fast mode flag
    if d.get("fast_mode") is True:
        parts.append(c(ICON, "\uf0e7") + " " + c(214, "fast"))

    # rate limit 5h (rolling)
    five = rl.get("five_hour") or {}
    fp = five.get("used_percentage")
    if fp is not None:
        seg = c(ICON, IC_5H) + " "
        if style == "text":
            seg += c(pct_color(fp), f"{int(fp)}%")
            if five.get("resets_at"):
                elapsed_frac = 100 - max(0, min(1, (five["resets_at"] - now) / (5 * 3600))) * 100
                seg += " " + c(ICON, circle_glyph(elapsed_frac))
        else:
            seg += c(pct_color(fp), circle_glyph(fp))
            if five.get("resets_at"):
                elapsed_frac = 100 - max(0, min(1, (five["resets_at"] - now) / (5 * 3600))) * 100
                seg += " " + c(ICON, circle_glyph(elapsed_frac))
        parts.append(seg)

    # rate limit 7d (weekly) — last
    seven = rl.get("seven_day") or {}
    sp = seven.get("used_percentage")
    if sp is not None:
        seg = c(ICON, IC_7D) + " "
        if style == "text":
            seg += c(pct_color(sp), f"{int(sp)}%")
            if seven.get("resets_at"):
                elapsed_frac = 100 - max(0, min(1, (seven["resets_at"] - now) / (7 * 86400))) * 100
                seg += " " + c(ICON, circle_glyph(elapsed_frac))
        else:
            seg += c(pct_color(sp), circle_glyph(sp))
            if seven.get("resets_at"):
                elapsed_frac = 100 - max(0, min(1, (seven["resets_at"] - now) / (7 * 86400))) * 100
                seg += " " + c(ICON, circle_glyph(elapsed_frac))
        parts.append(seg)

    # project-local segment — appended after the global one, never replaces it
    project_dir = (d.get("workspace") or {}).get("project_dir") or os.environ.get("CLAUDE_PROJECT_DIR")
    if project_dir:
        hook = os.path.join(project_dir, ".claude", "hooks", "statusline.sh")
        if os.access(hook, os.X_OK):
            try:
                res = subprocess.run(["sh", hook], input=raw, capture_output=True, text=True, timeout=3)
                seg = res.stdout.strip()
                if seg:
                    parts.append(seg)
            except Exception:
                pass

    sys.stdout.write(SEP.join(parts))

if __name__ == "__main__":
    main()
