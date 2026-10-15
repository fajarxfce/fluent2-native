#!/usr/bin/env python3
"""Generate the same official Fluent 2 icon paths for Compose and Flutter."""
import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = json.loads((ROOT / "tokens/icons.json").read_text())
ICONS = DATA["icons"]
COMMENT = "// Generated from @fluentui/react-icons " + DATA["version"] + "; MIT. See THIRD_PARTY_NOTICES.md."


def kotlin():
    lines = [COMMENT, "package dev.fluent2.core", "",
             "enum class FluentIconType(val viewX: Float, val viewY: Float, val viewWidth: Float, val viewHeight: Float, val paths: List<String>) {"]
    for name, data in ICONS.items():
        box = ", ".join(f"{float(value)}f" for value in data["viewBox"])
        paths = ", ".join(json.dumps(path) for path in data["paths"])
        lines.append(f"    {name[0].upper() + name[1:]}({box}, listOf({paths})),")
    return "\n".join(lines + ["}", ""])


def dart():
    lines = [COMMENT, "enum FluentIconType {"]
    for name, data in ICONS.items():
        box = ", ".join(str(float(value)) for value in data["viewBox"])
        paths = ", ".join(json.dumps(path) for path in data["paths"])
        suffix = ";" if name == list(ICONS)[-1] else ","
        lines.append(f"  {name}({box}, [{paths}]){suffix}")
    lines += ["", "  const FluentIconType(this.viewX, this.viewY, this.viewWidth, this.viewHeight, this.paths);",
              "  final double viewX, viewY, viewWidth, viewHeight;", "  final List<String> paths;", "}", ""]
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    for path, content in {
        "packages/compose/src/commonMain/kotlin/dev/fluent2/core/FluentIconType.kt": kotlin(),
        "packages/flutter/lib/src/theme/fluent_icon_type.dart": dart(),
    }.items():
        destination = ROOT / path
        if args.check:
            if not destination.exists() or destination.read_text() != content:
                raise SystemExit(f"Out of date: {path}. Run tools/generate_icons.py")
        else:
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_text(content)
    print(f"{'Verified' if args.check else 'Generated'} {len(ICONS)} icons for both libraries.")


if __name__ == "__main__":
    main()
