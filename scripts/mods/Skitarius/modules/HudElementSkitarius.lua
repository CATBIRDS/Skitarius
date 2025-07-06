local mod = get_mod("Skitarius")

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local ui_definitions = {
    scenegraph_definition = {
        screen = UIWorkspaceSettings.screen,
        skitarius_container = {
            parent = "screen",
            vertical_alignment = "bottom",
            horizontal_alignment = "right",
            size = { 50, 50 },
            position = {
                -370,
                -100,
                10
            }
        }
    },
    widget_definitions = {
        skitarius = UIWidget.create_definition({
            {
                style_id = "icon",
                value_id = "icon",
                pass_type = "texture",
                value = "content/ui/materials/icons/circumstances/maelstrom_01",
                style = {
                    size = { nil, nil },
                }
            }
        }, "skitarius_container")
    }
}

local HudElementSkitarius = class("HudElementSkitarius", "HudElementBase")

HudElementSkitarius.init = function(self, parent, draw_layer, start_scale)
    HudElementSkitarius.super.init(self, parent, draw_layer, start_scale, ui_definitions)
    self:set_size(mod:get("hud_element_size"))
    self:set_icon("circumstances/maelstrom_01")
    self:set_visible(false)
end

HudElementSkitarius.set_visible = function(self, vis)
    self._widgets_by_name.skitarius.style.icon.visible = vis
end

HudElementSkitarius.set_color = function(self, a, r, g, b)
    self._widgets_by_name.skitarius.style.icon.color = { a, r, g, b }
end

HudElementSkitarius.set_size = function(self, side_length)
    local widget_size = self._widgets_by_name.skitarius.style.icon.size
    widget_size[1] = side_length
    widget_size[2] = side_length
end

HudElementSkitarius.set_icon = function(self, icon)
    local icon_path = "content/ui/materials/icons/" .. icon
    self._widgets_by_name.skitarius.content.icon = icon_path
end

--[[ Icon References ]
    circumstances/maelstrom_01 : Skull with normal eyes
    circumstances/maelstrom_02 : Skull with red eyes

--]]

return HudElementSkitarius
