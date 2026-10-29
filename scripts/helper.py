#!/usr/bin/env python3
"""install.sh / install.ps1 共用的小工具。

  helper.py bindirs                  印出 pip 可能安裝執行檔的資料夾（以系統路徑分隔符連接）
  helper.py timeouts <config> <name> 在 [mcp_servers.<name>] 補上逾時設定（已有則略過）
"""
import os
import site
import sys
import sysconfig


def bindirs():
    dirs = [sysconfig.get_path("scripts")]
    try:
        dirs.append(os.path.join(site.getuserbase(), "Scripts" if os.name == "nt" else "bin"))
    except Exception:
        pass
    print(os.pathsep.join(d for d in dirs if d))


def timeouts(cfg, name):
    with open(cfg, encoding="utf-8", newline="") as f:
        text = f.read()
    eol = "\r\n" if "\r\n" in text else "\n"
    lines = text.split(eol)
    hdr = "[mcp_servers.%s]" % name
    try:
        i = lines.index(hdr)
    except ValueError:
        print("  [!] 找不到設定區段，略過逾時設定")
        return
    j = i + 1
    while j < len(lines) and not lines[j].lstrip().startswith("["):
        j += 1
    body = eol.join(lines[i + 1:j])
    add = []
    if "startup_timeout_sec" not in body:
        add.append("startup_timeout_sec = 30")
    if "tool_timeout_sec" not in body:
        add.append("tool_timeout_sec = 300")
    if not add:
        print("  [OK] 逾時設定已存在")
        return
    k = j
    while k > i + 1 and lines[k - 1].strip() == "":
        k -= 1
    lines[k:k] = add
    with open(cfg, "w", encoding="utf-8", newline="") as f:
        f.write(eol.join(lines))
    print("  [OK] 已加入逾時設定：" + "、".join(add) + "（原檔備份為 config.toml.bak-notebooklm）")


if __name__ == "__main__":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    if cmd == "bindirs":
        bindirs()
    elif cmd == "timeouts" and len(sys.argv) == 4:
        timeouts(sys.argv[2], sys.argv[3])
    else:
        sys.exit(__doc__)
