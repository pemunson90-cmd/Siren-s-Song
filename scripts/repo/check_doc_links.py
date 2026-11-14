#!/usr/bin/env python3
"""Check every relative link in the tracked Markdown files. Read-only.

A link target must exist in the working tree. External links (http, https,
mailto), pure anchors and links inside code spans or fenced blocks are not
checked. Files under a scrap folder (`_scrap-*/`), under the immutable
provenance folders and the run's own charter files are skipped as sources:
they are history and keep the links they had.

Exit code 1 when a link is broken.
"""
import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
SKIP_PREFIXES = ("_scrap-", "reference/", "references/package/sources/", ".fable/", ".claude/", "reports/")
SKIP_FILES = {
    # Verbatim owner records and dated records that quote paths of their time.
    "docs/directives/2026-10-20-audit-reaffirmation.md",
    "docs/directives/2026-10-20-order-correction.md",
}
LINK = re.compile(r"(?<!\!)\[[^\]\n]*\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")
IMAGE = re.compile(r"\!\[[^\]\n]*\]\(([^)\s]+)\)")
FENCE = re.compile(r"^\s*(```|~~~)")
CODE_SPAN = re.compile(r"`[^`\n]*`")


def tracked_markdown():
    out = subprocess.run(["git", "-C", str(ROOT), "ls-files", "-co", "--exclude-standard", "*.md"],
                         capture_output=True, text=True, check=True).stdout
    return [line for line in out.splitlines() if line]


def targets(text):
    fenced = False
    for number, line in enumerate(text.splitlines(), 1):
        if FENCE.match(line):
            fenced = not fenced
            continue
        if fenced:
            continue
        line = CODE_SPAN.sub("", line)
        for pattern in (LINK, IMAGE):
            for match in pattern.finditer(line):
                yield number, match.group(1)


def main():
    broken = []
    checked = 0
    for name in tracked_markdown():
        if name.startswith(SKIP_PREFIXES) or name in SKIP_FILES:
            continue
        path = ROOT / name
        if not path.is_file():
            continue
        for number, target in targets(path.read_text(encoding="utf-8", errors="replace")):
            if re.match(r"^[a-zA-Z][a-zA-Z0-9+.-]*:", target) or target.startswith("#"):
                continue
            checked += 1
            clean = target.split("#", 1)[0].split("?", 1)[0].replace("%20", " ")
            if not clean:
                continue
            resolved = (ROOT / clean.lstrip("/")) if clean.startswith("/") else (path.parent / clean)
            if not resolved.exists():
                broken.append("%s:%d: broken link: %s" % (name, number, target))
    for line in broken:
        print(line)
    print("DOC LINKS %s: %d relative link(s) checked, %d broken" % ("FAIL" if broken else "PASS", checked, len(broken)))
    return 1 if broken else 0


if __name__ == "__main__":
    sys.exit(main())
