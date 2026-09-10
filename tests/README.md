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

Expected on the current production code: **4 successes, 1 failure, 0 errors**,
with a nonzero exit status.
The failure is intentional: this is the red phase of TDD, with no production fix.
Busted discovers `tests/charge_release_spec.lua` through `.busted`; the isolated
game fixture is in `tests/support/charge_release_fixture.lua`.

The regression models manually holding secondary attack with Always Auto-Release
Charges enabled, Global Charge Threshold at 100%, and the flame staff's Weapon
Charge Threshold saved as 50% under `override_primary`. No sequence is running.
At charge level 0.50, the expected synthesized `action_one_pressed` is absent.

The test loads the real Armoury, BindManager, Engram, WeaponManager, and Omnissiah
modules. It stubs the engine's class factory, player/extensions, held input, and
peril detection. The threshold selection and fire-input decision are production
code. Each fixture has its own Lua 5.1 environment and module state.

Passing controls cover equipment identification, an active weapon sequence at
50%, a lower global threshold, and manual charging with both thresholds at 100%.

This establishes a configuration-to-input failure outside the game, not an
in-game timing or animation test. The expected manual behavior follows the
global threshold tooltip's promise that a lower weapon threshold overrides it.
The future fix must define which keybind's threshold applies when no sequence is
active: weapon thresholds are stored per keybind. This regression proposes the
default `override_primary` configuration for that case; it does not settle
precedence among other keybinds.
