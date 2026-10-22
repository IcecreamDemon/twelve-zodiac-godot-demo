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
- MCP URL: `http://localhost:19081/mcp`
- Source repository: `https://github.com/IcecreamDemon/twelve-zodiac-godot-demo`
- Current stage: M0 through M6 and the M7 Windows export are complete.
- Next implementation target: placeholder art pass, audio, and a 30–60 second demo recording.

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
- Player movement baseline: speed `380`, jump velocity `900`, gravity `2200`, dodge speed `640`.
- Player attacks consume shi, never qi. Qi is reserved for guard, dodge, and burrow.
- Shi slowly recovers at `2` points per second outside attacks; recovery pauses during all attack states and combo branches.
- Current shi costs: light `8`, neutral finisher `12`, forward/up/switch `15`, heavy/air slam/ground finisher `20`, burrow emerge `15`.
- Enemy hit reactions apply both horizontal knockback and hitstun according to `AttackData`.
- Actor-to-actor physical body collision is disabled intentionally; movement blocking uses horizontal contact rules (`actor_contact_distance = 88`) so actors never get vertically displaced by `move_and_slide()`.
- Enemy bodies stop before player contact and separate from other enemies only along the X axis.
- `DemoFlowController` uses a dedicated `node_map.tscn` selection screen and a victory animation after every combat; no next enemy spawns before the player selects a node.
- `flow_hud.tscn` displays player and active enemy health, posture, qi, shi, and state.
- `HitboxComponent` drives short hitstop and `CombatCamera` shake from `AttackData.hitstop_frames` and `screen_shake_strength`.
- Ground attack recovery can cancel into dodge after active frames; startup and counter attacks remain uncancelable.
- Enemy startup telegraph uses silhouette tint: warm color for normal attacks, red for unblockable, blue for anti-burrow.
- AttackData carries `forward_motion_speed`; light attacks drift slightly, forward finishers lunge, and heavy attacks step in.
- Demo Flow and Combat Lab platforms use one-way collision.
- Short blade and spear have separate visible weapon geometry; `Q` always performs the new weapon's switch attack when affordable.
- Demo Flow uses incense currency, a functional shop, post-battle reward choices, and persistent max-health/qi/posture/damage upgrades.
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
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --headless --path "E:\twelfe" --script res://tests/boss/boss_phase_test.gd
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --headless --path "E:\twelfe" --script res://tests/boss/incense_burner_test.gd
& "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --headless --path "E:\twelfe" --script res://tests/flow/demo_flow_test.gd
```

Update the task board and decision log in the full design document after every completed milestone.
