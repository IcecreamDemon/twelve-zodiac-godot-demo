# 十二神相录 Demo - Agent Handoff

## Read First

Full design and live status:

`E:\game plant\docs\superpowers\specs\2026-10-15-zodiac-demo-design.md`

Read that file before editing the project. It contains the Cold Start block, architecture, exact combat rules, task board, open decisions, and decision log.

## Project State

- Godot: `4.7.2.stable.steam.ed1daf0bf`
- Editor:
  `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe`
- MCP: `Godot MCP Native 1.0.8`
- MCP URL: `http://localhost:9080/mcp`
- Current stage: M0 through M5 are complete.
- Next implementation target: M6 夺愿神 boss and the six-node vertical slice.

## Non-Negotiable Scope

- One playable character: 鼠光.
- One borrowed body: 许安.
- One region: 无雨乡.
- Six fixed nodes.
- Two weapons: short blade and spear.
- Three humanoid enemies: 天兵, 镇守, 法吏.
- One old-self fight and one `夺愿神` boss.
- Do not build the other eleven playable zodiac characters or the full four-region campaign.

## Technical Rules

- Use Godot 4.7 and GDScript.
- Target 1920x1080 with `canvas_items` stretching.
- Use `CharacterBody2D` for actors.
- Use keyboard-first InputMap actions; do not hard-code physical keys in gameplay code.
- Use frame counts for attack timing, not raw `delta`.
- Store tuning values in resources or configuration objects.
- Keep combat components isolated: health, posture, qi, shi, hitbox, hurtbox, state machine.
- Player movement baseline: speed `380`, jump velocity `900`, gravity `2200`, dodge speed `460`.
- Player and enemy bodies collide physically; dodge cannot push enemies through their collision bodies.
- Enemy bodies use horizontal-only player separation (`actor_contact_distance = 54`) so collision resolution never displaces them vertically.
- Enemy bodies also separate horizontally from other enemies; they never resolve actor overlap along the Y axis.
- Do not introduce third-party combat or behavior-tree plugins for the first milestone.

## Verification

Editor:

```powershell
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --editor --path "E:\twelfe"
```

Headless validation:

```powershell
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --headless --path "E:\twelfe" --quit
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --headless --path "E:\twelfe" --script res://tests/smoke_test.gd
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --headless --path "E:\twelfe" --script res://tests/combat/attack_timing_test.gd
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --headless --path "E:\twelfe" --script res://tests/combat/combo_branch_test.gd
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --headless --path "E:\twelfe" --script res://tests/combat/parry_and_guard_test.gd
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --headless --path "E:\twelfe" --script res://tests/combat/hit_reaction_test.gd
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --headless --path "E:\twelfe" --script res://tests/combat/air_attack_test.gd
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --headless --path "E:\twelfe" --script res://tests/enemies/enemy_archetype_test.gd
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --headless --path "E:\twelfe" --script res://tests/enemies/enemy_guard_qi_test.gd
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --headless --path "E:\twelfe" --script res://tests/enemies/enemy_unblockable_test.gd
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --headless --path "E:\twelfe" --script res://tests/enemies/enemy_projectile_test.gd
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --headless --path "E:\twelfe" --script res://tests/enemies/enemy_ai_smoke_test.gd
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --headless --path "E:\twelfe" --script res://tests/combat/burrow_state_test.gd
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --headless --path "E:\twelfe" --script res://tests/combat/burrow_cost_test.gd
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --headless --path "E:\twelfe" --script res://tests/combat/emergence_combo_test.gd
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --headless --path "E:\twelfe" --script res://tests/combat/dodge_test.gd
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --headless --path "E:\twelfe" --script res://tests/old_self/behavior_recorder_test.gd
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --headless --path "E:\twelfe" --script res://tests/old_self/old_self_profile_test.gd
```

Update the task board and decision log in the full design document after every completed milestone.
