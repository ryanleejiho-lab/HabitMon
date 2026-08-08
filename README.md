# HabitMon

A pixel-art companion creature that grows as you complete tasks in [boring.notch](https://github.com/ryanleejiho-lab/boring.notch)'s Checklist tab. Different task types feed different stats — your creature's look reflects which parts of life you've been tending.

**Status:** In development.

## Requirements

- macOS 13 or later
- Xcode 15+ (for the Swift 5.9 toolchain) or a standalone Swift 5.9+ toolchain
- The [boring.notch fork](https://github.com/ryanleejiho-lab/boring.notch) with the Checklist type-tagging feature, installed and running (HabitMon reads its data — it doesn't work standalone)

## Install & run

```bash
git clone https://github.com/ryanleejiho-lab/HabitMon.git
cd HabitMon
swift run HabitMon
```

A window opens with your creature in a small room. Use the arrow keys to walk around. Add and tag tasks in boring.notch's Checklist tab (flame/book/leaf/droplet/bolt icons); checking one off feeds 10 XP to that stat within a few seconds, visible both in the HUD below the room and as a visual change on the creature once a stat crosses a stage threshold (50 XP, then 150 XP).

## How it works

- HabitMon polls boring.notch's checklist file (`~/Library/Application Support/boringNotch/Checklist/state.json`) every 3 seconds — it never writes to that file, only reads it.
- Each completed, tagged task is credited exactly once, tracked in HabitMon's own state file (`~/Library/Application Support/HabitMon/state.json`), so nothing is double-counted even after boring.notch's own daily rollover deletes checked-off items the next day.
- All creature art is generated procedurally in code — no external image assets.
- Run the test suite for the core logic (crediting, evolution thresholds, persistence) with `swift test`.

## Project structure

- `Sources/HabitMonCore/` — pure logic: models, the checklist-crediting algorithm, evolution math, persistence. Fully unit tested.
- `Sources/HabitMon/` — the SwiftUI + SpriteKit app itself: the room, the HUD, procedural sprite generation, and the polling integration. Not unit tested — verify by running.
- `Tests/HabitMonCoreTests/` — tests for `HabitMonCore`.
