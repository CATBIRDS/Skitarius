# Tests

Requires LuaJIT (or Lua 5.1), LuaRocks, and a C compiler.

Setup on macOS:

```sh
brew install luajit luarocks
luarocks --lua-version=5.1 --lua-dir="$(brew --prefix luajit)" --tree=lua_modules test
```

On other platforms, set `--lua-dir` to your LuaJIT installation path.

Run from the repository root after setup:

```sh
./lua_modules/bin/busted
```
