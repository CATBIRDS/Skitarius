rockspec_format = "3.0"
package = "skitarius"
version = "dev-1"
source = { url = "git+https://github.com/CATBIRDS/Skitarius.git" }
description = {
    summary = "User-defined action sequences for Darktide",
    license = "GPL-3.0",
}
dependencies = { "lua >= 5.1, < 5.2" }
test_dependencies = { "busted == 2.3.0-1" }
test = { type = "busted" }
build = { type = "builtin", modules = {} }
