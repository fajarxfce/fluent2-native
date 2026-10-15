#!/usr/bin/env python3
"""API 24+ catalog smoke test on a 720x1280 Android device/emulator."""
import argparse
import re
import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path
from PIL import Image

parser = argparse.ArgumentParser()
parser.add_argument('platform', choices=['compose', 'flutter'])
parser.add_argument('--serial', default='emulator-5554')
parser.add_argument('--root', default=str(Path(__file__).resolve().parents[1] / 'artifacts'))
args = parser.parse_args()
root = Path(args.root)
root.mkdir(parents=True, exist_ok=True)
(root / 'screenshots').mkdir(exist_ok=True)
package = 'dev.fluent2.catalog.' + args.platform
activity = package + '/dev.fluent2.catalog.' + ('compose' if args.platform == 'compose' else 'fluent_catalog') + '.MainActivity'

def adb(*cmd):
    result = subprocess.run(['adb', '-s', args.serial, *cmd], check=True, capture_output=True, timeout=30)
    return result.stdout.decode(errors='replace')

def dump():
    adb('shell', 'uiautomator', 'dump', '/sdcard/fluent-smoke.xml')
    source = adb('exec-out', 'cat', '/sdcard/fluent-smoke.xml')
    (root / f'{args.platform}-window.xml').write_text(source)
    return ET.fromstring(source)

def find(label, scroll=False):
    for attempt in range(7 if scroll else 1):
        tree = dump()
        for node in tree.iter('node'):
            if label in (node.get('text', '') + '\n' + node.get('content-desc', '')).split('\n') or (label == 'Search components' and node.get('class') == 'android.widget.EditText'):
                bounds = [int(v) for v in re.findall(r'\d+', node.get('bounds'))]
                if len(bounds) == 4 and bounds[3] > bounds[1]:
                    return bounds
        if scroll:
            adb('shell', 'input', 'swipe', '360', '1100', '360', '500', '350')
    raise AssertionError(f'{args.platform}: missing {label}')

def tap(label, scroll=False):
    a, b, c, d = find(label, scroll)
    adb('shell', 'input', 'tap', str((a+c)//2), str((b+d)//2))

def hide_keyboard():
    if 'mInputShown=true' in adb('shell', 'dumpsys', 'input_method'):
        adb('shell', 'input', 'keyevent', 'KEYCODE_BACK')

def screenshot(name):
    result = subprocess.run(['adb', '-s', args.serial, 'exec-out', 'screencap', '-p'], check=True, capture_output=True, timeout=20)
    (root / 'screenshots' / f'{args.platform}-{name}.png').write_bytes(result.stdout)

def launch():
    adb('shell', 'am', 'force-stop', package)
    adb('shell', 'am', 'start', '-W', '-n', activity)
    find('Fluent 2')
    hide_keyboard()

def search(text):
    tap('Search components')
    adb('shell', 'input', 'text', text)
    dump()
    hide_keyboard()

launch()
screenshot('light')
# At 720x1280/280dpi the four tile interiors must remain the header color.
# This catches API 24's Compose rendering difference for compact relative SVGs.
with Image.open(root / 'screenshots' / f'{args.platform}-light.png') as shot:
    shot = shot.convert('RGB')
    assert shot.size == (720, 1280), 'Smoke visual checks require 720x1280 at 280dpi'
    background = shot.getpixel((65, 76))
    for point in [(58, 94), (58, 108), (73, 108), (75, 94)]:
        actual = shot.getpixel(point)
        assert max(abs(a - b) for a, b in zip(actual, background)) <= 8, f'Icon interior filled incorrectly at {point}: {actual}'
print(args.platform, 'official icon geometry: PASS', flush=True)
tap('Switch to dark theme')
find('Switch to light theme')
screenshot('dark')
print(args.platform, 'launch and light/dark: PASS', flush=True)
tap('Switch to Teams theme')
find('Switch to Web theme')
screenshot('teams-dark')
print(args.platform, 'Teams theme: PASS', flush=True)
launch()
search('Dropdown')
tap('Workspace role', scroll=True)
tap('Developer')
find('Current role: developer')
screenshot('select')
print(args.platform, 'select: PASS', flush=True)
launch()
search('Dialog')
tap('New workspace', scroll=True)
find('Create a workspace?')
screenshot('modal')
tap('Create workspace')
find('Workspace created.')
print(args.platform, 'async confirmation: PASS', flush=True)
launch()
search('Accordion')
tap('Built for your platform', scroll=True)
find('Compose and Flutter render these components with their native UI toolkits.')
screenshot('accordion')
print(args.platform, 'accordion: PASS', flush=True)
pid = adb('shell', 'pidof', package).strip()
assert pid, 'Application is not running'
log = adb('logcat', '-d', '--pid=' + pid, '-s', 'AndroidRuntime:E')
assert not (package in log and 'FATAL EXCEPTION' in log), log
print(args.platform, 'runtime: PASS', flush=True)
