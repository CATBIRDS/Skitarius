# Charge-release regression

The tests use Busted 2.3.0 on LuaJIT (Lua 5.1). Busted is declared as a
test-only dependency in `skitarius-dev-1.rockspec`; players do not need it.

On macOS with Homebrew, install the development tools:

```sh
brew install luajit luarocks
```

Then run from the repository root:

```sh
luarocks --lua-version=5.1 --lua-dir="$(brew --prefix luajit)" --tree=lua_modules test
```

This installs missing test dependencies into the ignored `lua_modules/` directory
and runs Busted. On other platforms, replace the `--lua-dir` value with your
LuaJIT installation prefix. Native dependencies require a C compiler and LuaJIT
headers. The fixture uses Lua 5.1's `setfenv`, so use LuaJIT or Lua 5.1 rather
than a newer stock Lua interpreter.

After installation, the shorter command is:

```sh
./lua_modules/bin/busted
```

Expected: all tests pass, with exit status 0. Commit `2eee575` preserves the
original red phase: four passing controls and one failing manual-release test.
Busted discovers `tests/*_spec.lua` through `.busted`. The behavior tests use
`tests/support/charge_release_fixture.lua`; the charge policy tests load the
pure `SkitariusChargeRelease` module directly, with no game stubs.

The regression models manually holding secondary attack with Always Auto-Release
Charges enabled, Global Charge Threshold at 100%, and the flame staff's Weapon
Charge Threshold saved as 50% under `override_primary`. No sequence is running.
At charge level 0.50, the mod should synthesize `action_one_pressed`.

The fixture loads the real Armoury, BindManager, Engram, WeaponManager, and Omnissiah
modules. It stubs the engine's class factory, player/extensions, held input, and
peril detection. The threshold selection and fire-input decision are production
code. Each fixture has its own Lua 5.1 environment and module state.

Passing controls cover equipment identification, an active weapon sequence at
50%, a lower global threshold, and manual charging with both thresholds at 100%.

This establishes a configuration-to-input failure outside the game, not an
in-game timing or animation test. The expected manual behavior follows the
global threshold tooltip's promise that a lower weapon threshold overrides it.
When no sequence is running, manual auto-release uses the equipped weapon's
`override_primary` (Primary) threshold. An active sequence retains its own
threshold. Other saved keybinds do not affect manual charging. Without a saved
Primary weapon threshold, the global auto-release threshold applies. The
Primary profile's `global_ranged` sequence settings are not used as a manual
fallback; the global auto-release slider already provides that default.

Here, Primary names the mod's default configuration profile. The regression
holds secondary attack (right-click) to charge. Auto-release synthesizes primary
fire while secondary remains held, using the mod's existing staff input mapping.
It does not change the ordinary uncharged primary attack.
