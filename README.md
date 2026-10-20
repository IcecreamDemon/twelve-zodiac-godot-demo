# 十二神相录 Godot Demo

Godot 4 vertical slice for the original 2D side-view action roguelite concept.

## Engine

- Godot `4.7.2`
- GDScript
- Target resolution: `1920x1080` with `canvas_items` stretching

## Run

```powershell
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --editor --path "E:\twelfe"
```

Press `F5` to run the six-node demo flow. Individual test scenes are under `scenes/tests/`.

## Controls

- Move: `A` / `D`
- Jump: `Space`
- Light attack: `J`
- Heavy attack / air slam: `K`
- Dodge: `L`
- Guard: hold `U`
- Perfect parry: `I`
- Switch weapon: `Q`
- Burrow / emerge: `F`
- Combo up branch modifier: `W`

## Tests

```powershell
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --headless --path "E:\twelfe" --script res://tests/smoke_test.gd
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --headless --path "E:\twelfe" --script res://tests/flow/demo_flow_test.gd
```

## Documentation

- Design and handoff: `https://github.com/IcecreamDemon/game`
- Local design document: `E:\game plant\docs\superpowers\specs\2026-10-15-zodiac-demo-design.md`

## MCP

- Godot MCP Native endpoint: `http://localhost:19081/mcp`
- Start or keep the Godot editor running, then open a new Codex conversation to load MCP tools.

## Repository Scope

The repository includes source, scenes, resources, tests, and the Godot MCP addon. Windows build output and editor caches are intentionally ignored.
