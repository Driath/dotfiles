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
IC_DIR = ""  # folder       -> current path
IC_GIT = ""  # branch       -> git branch

# --- 256-color ANSI ---
def c(code, s):
    return f"\x1b[38;5;{code}m{s}\x1b[0m"

ICON = 75       # frost cyan
TEXT = 252
DIM = 240
SEP = c(238, " │ ")


def pct_color(p):
    if p >= 80:
        return 203   # red
    if p >= 50:
        return 215   # amber
    return 114       # green


def fmt_reset(epoch, now):
    rem = int(epoch) - int(now)
    if rem <= 0:
        return None
    days, rem = divmod(rem, 86400)
    hours, rem = divmod(rem, 3600)
    mins = rem // 60
    if days:
        return f"-{days}j{hours}h" if hours else f"-{days}j"
    if hours:
        return f"-{hours}h{mins:02d}"
    return f"-{mins}m"


def main():
    raw = sys.stdin.read()
    try:
        data = json.loads(raw)
    except (ValueError, TypeError):
        data = {}
    d = data.get("data", data) if isinstance(data, dict) else {}

    parts = []
    rl = d.get("rate_limits", {}) or {}
    now = time.time()

    # current path (home-relative, fish-style)
    cwd = d.get("cwd") or (d.get("workspace") or {}).get("current_dir") or ""
    if cwd:
        home = os.path.expanduser("~")
        root = "~" if cwd.startswith(home) else ""
        tail = cwd[len(home):] if cwd.startswith(home) else cwd
        segs = [s for s in tail.split("/") if s]
        # fish-style: abbreviate every ancestor to its first char, keep last full
        disp = "/".join([s[0] for s in segs[:-1]] + segs[-1:]) if segs else ""
        disp = (root + "/" + disp).rstrip("/") if disp else (root or "/")
        parts.append(c(ICON, IC_DIR) + " " + c(TEXT, disp))

    # git branch + dirty state (single call: porcelain v2 has branch, ahead/behind, files)
    if cwd:
        try:
            lines = subprocess.run(
                ["git", "-C", cwd, "status", "--porcelain=v2", "--branch"],
                capture_output=True, text=True, timeout=0.3,
            ).stdout.splitlines()
        except Exception:
            lines = []
        branch, ahead, modified, untracked = "", 0, 0, 0
        for line in lines:
            if line.startswith("# branch.head "):
                branch = line.split(" ", 2)[2]
            elif line.startswith("# branch.ab "):
                ahead = int(line.split()[2].lstrip("+"))
            elif line.startswith(("1 ", "2 ")):
                modified += 1
            elif line.startswith("? "):
                untracked += 1
        if branch and branch != "(detached)":
            git_str = c(ICON, IC_GIT) + " " + c(213, branch)
            if modified:
                git_str += " " + c(215, f"*{modified}")
            if untracked:
                git_str += " " + c(DIM, f"?{untracked}")
            if ahead:
                git_str += " " + c(114, f"↑{ahead}")
            parts.append(git_str)

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
        parts.append(c(ICON, "") + " " + c(214, "fast"))

    # rate limit 5h (rolling)
    five = rl.get("five_hour") or {}
    fp = five.get("used_percentage")
    if fp is not None:
        seg = c(ICON, IC_5H) + " " + c(pct_color(fp), f"{int(fp)}%")
        rs = fmt_reset(five["resets_at"], now) if five.get("resets_at") else None
        if rs:
            seg += " " + c(DIM, rs)
        parts.append(seg)

    # rate limit 7d (weekly) — last
    seven = rl.get("seven_day") or {}
    sp = seven.get("used_percentage")
    if sp is not None:
        seg = c(ICON, IC_7D) + " " + c(pct_color(sp), f"{int(sp)}%")
        rs = fmt_reset(seven["resets_at"], now) if seven.get("resets_at") else None
        if rs:
            seg += " " + c(DIM, rs)
        parts.append(seg)

    sys.stdout.write(SEP.join(parts))


if __name__ == "__main__":
    main()
