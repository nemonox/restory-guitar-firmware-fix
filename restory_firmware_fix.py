#!/usr/bin/env python3
"""ReStory - Firmware Fix (Guitar Legend / devices with no UNLOCK-TOOLKIT content)

Patches HackingContentTable.IsTableContainsDataForDeviceCategory in Restory.Assembly.dll:
when the device category is missing from the table (only console/phone/laptop exist),
the game refused to hack the device ("CAN'T BE DONE ON THIS DEVICE"). After the patch,
the console content is used as a fallback.

Usage:  python3 restory_firmware_fix.py "<game folder or path to Restory.Assembly.dll>"
        python3 restory_firmware_fix.py --restore "<game folder>"
"""
import os, re, shutil, sys

T = rb"(?:.{4})"
BRANCH = rb"\x04\x02\x7B" + T + rb"\x51\x05\x02\x7B" + T + rb"\x51\x17\x2A"
COMPARE = rb"\x03\x6F" + T + rb"\x02\x7B" + T + rb"\x6F" + T + rb"\x28" + T + rb"\x2C."
PATTERN = re.compile(
    rb"\x04\x02\x7B(.{4})\x51\x05\x02\x7B(.{4})\x51\x17\x2A"   # console branch (captures tokens)
    + COMPARE + BRANCH + COMPARE + BRANCH                       # phone and laptop branches
    + rb"(\x72" + T + rb"\x03\x6F" + T + rb"\x28" + T + rb"\x28" + T + rb"\x16\x2A)",  # LogError; return false
    re.DOTALL)
PATCHED = re.compile(rb"\x04\x02\x7B(.{4})\x51\x05\x02\x7B(.{4})\x51\x17\x2A"
                     + COMPARE + BRANCH + COMPARE + BRANCH
                     + rb"\x04\x02\x7B\1\x51\x05\x02\x7B\2\x51\x17\x2A\x00{5}", re.DOTALL)


def find_dll(path):
    if os.path.isfile(path):
        return path
    for rel in ("Restory_Data/Managed/Restory.Assembly.dll", "Managed/Restory.Assembly.dll", "Restory.Assembly.dll"):
        p = os.path.join(path, rel)
        if os.path.isfile(p):
            return p
    sys.exit("ERROR: Restory.Assembly.dll not found in: " + path)


def main():
    args = sys.argv[1:]
    restore = "--restore" in args
    args = [a for a in args if a != "--restore"]
    if not args:
        sys.exit(__doc__)
    dll = find_dll(args[0])
    backup = dll + ".bak"

    if restore:
        if not os.path.isfile(backup):
            sys.exit("ERROR: backup not found: " + backup)
        shutil.copy2(backup, dll)
        print("Original restored:", dll)
        return

    data = open(dll, "rb").read()
    if PATCHED.search(data):
        print("Patch is already applied. Nothing to do.")
        return
    matches = list(PATTERN.finditer(data))
    if len(matches) != 1:
        sys.exit("ERROR: expected code not found (%d matches). Incompatible game version." % len(matches))
    m = matches[0]
    new_tail = b"\x04\x02\x7B" + m.group(1) + b"\x51\x05\x02\x7B" + m.group(2) + b"\x51\x17\x2A" + b"\x00" * 5
    start, end = m.span(3)
    assert end - start == len(new_tail) == 23
    if not os.path.isfile(backup):
        shutil.copy2(dll, backup)
        print("Backup created:", backup)
    tmp = dll + ".tmp"
    with open(tmp, "wb") as f:
        f.write(data[:start] + new_tail + data[end:])
    os.replace(tmp, dll)
    print("Patch applied successfully to:", dll)


if __name__ == "__main__":
    main()
