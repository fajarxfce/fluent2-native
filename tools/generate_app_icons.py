#!/usr/bin/env python3
"""Render the catalog's original F app mark (requires Pillow).

The matching editable vector is assets/catalog-icon.svg. App icons are checked
in; this optional tool is not needed to build either library or application.
"""
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
icon = Image.new("RGB", (1024, 1024), "#0f6cbd")
draw = ImageDraw.Draw(icon)
draw.rounded_rectangle((245, 200, 420, 820), radius=32, fill="white")
draw.rounded_rectangle((245, 200, 800, 365), radius=32, fill="white")
draw.rounded_rectangle((245, 450, 690, 600), radius=32, fill="#b4d6fa")

paths = list((ROOT / "examples/flutter/android/app/src/main/res").glob("mipmap-*/ic_launcher.png"))
paths += list((ROOT / "examples/flutter/ios/Runner/Assets.xcassets/AppIcon.appiconset").glob("*.png"))
paths += list((ROOT / "examples/flutter/macos/Runner/Assets.xcassets/AppIcon.appiconset").glob("*.png"))
paths += list((ROOT / "examples/flutter/web/icons").glob("*.png"))
paths += [ROOT / "examples/flutter/web/favicon.png"]
for path in paths:
    with Image.open(path) as previous:
        size = previous.size
    icon.resize(size, Image.Resampling.LANCZOS).save(path)
icon.save(ROOT / "examples/flutter/windows/runner/resources/app_icon.ico", sizes=[(16, 16), (32, 32), (48, 48), (256, 256)])
print(f"Rendered {len(paths)} PNG app icons and one Windows icon.")
