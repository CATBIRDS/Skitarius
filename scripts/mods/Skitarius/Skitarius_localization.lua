local WeaponTemplates = require("scripts/settings/equipment/weapon_templates/weapon_templates")
local Mark9 = get_mod("Mark9") -- compatibility check

-- Chinese localization provided by jcyl2023 and SyuanTsai
local localizations = {
    -- Mod Details
    mod_name = {
        en = "Skitarius",
        ["zh-tw"] = "機械教信徒",
        ["zh-cn"] = "战斗序列（鼠标宏）",

    },
    mod_description = {
      en = "FROM THE MOMENT I UNDERSTOOD THE WEAKNESS OF MY FLESH, IT DISGUSTED ME.",
      ["zh-tw"] = "當我看穿血肉的脆弱，那一刻，我的心靈便被機械的完美所召喚，對這腐朽之軀只剩厭憎。（繁體中文已由簡體漢化者維護，可能用詞差異和遊戲詞彙不同的不准確）",
      ["zh-cn"] = "设置一个独属于你的连招，按键自动作出相应动作——————B站 独一无二的小真寻 汉化维护",
    },
    -- Debug
    debug = {
      en = "Debug",
      ["zh-tw"] = "開發模式",
      ["zh-cn"] = "调试模式",
    },
    -- HUD Element
    hud_element = {
        en = "Enable Sequence Indicator",
        ["zh-tw"] = "啟用MOD指示器",
        ["zh-cn"] = "启用MOD指示器",
    },
    hud_element_tooltip = {
        en = "When enabled, a HUD icon will be displayed indicating mod and sequence status.",
      ["zh-cn"] = "启用后，将显示一个HUD图标，指示模块和序列状态。",
      ["zh-tw"] = "啟用後，將顯示一個HUD圖標，訓示模塊和序列狀態。",
    },
    hud_element_type = {
      en = "Sequence Indicator Style",
      ["zh-cn"] = "显像模式",
      ["zh-tw"] = "顯像模式",
 
    },
    hud_element_type_tooltip = {
      en = string.format("Color: HUD element will be colored when a sequence is active, black-and-white when inactive.\n"..
        "Icon: HUD element will change icons depending on sequence activity status.\n"..
        "Icon + Color: HUD element will change icons and color depending on sequence activity status.\n"),
      ["zh-cn"] = string.format("颜色：当序列处于活动状态时，HUD元素将着色，当序列处于非活动状态时将为黑白.\n"..
        "图标：HUD元素将根据序列活动状态更改图标.\n"..
        "颜色+图标：HUD元素将根据序列活动状态更改图标和颜色.\n"),
      ["zh-tw"] = string.format("顏色：當序列處於活動狀態時，HUD元素將著色，當序列處於非活動狀態時將為黑白.\n"..
        "圖標：HUD元素將根據序列活動狀態更改圖標.\n"..
        "顏色+圖標：HUD元素將根據序列活動狀態更改圖標和顏色. \n"),
    },
    hud_element_type_color = {
      en = "Color",
      ["zh-cn"] = "颜色",
      ["zh-tw"] = "顏色",
    },
    hud_element_type_icon = {
      en = "Icon",
      ["zh-cn"] = "图标",
      ["zh-tw"] = "圖標",
    },
    hud_element_type_opacity = {
      en = "Opacity",
      ["zh-cn"] = "透明度",
      ["zh-tw"] = "透明度",
    },
    hud_element_type_icon_color = {
      en = "Icon + Color",
      ["zh-cn"] = "图标+颜色",
      ["zh-tw"] = "圖標+顏色",
    },
    hud_element_size = {
        en = "Sequence Indicator Size",
        ["zh-tw"] = "MOD指示器大小",
        ["zh-cn"] = "指示器尺寸大小",
    },
    -- Mod Settings
    mod_settings = {
      en = "Mod Settings",
      ["zh-cn"] = "MOD设置",
      ["zh-tw"] = "MOD指設置",
 
    },
    mod_enable_held = {
      en = "Enable/Disable Mod (Held)",
      ["zh-cn"] = "长按式模组启停",
      ["zh-tw"] = "長按式模組啟停",
    },
    mod_enable_pressed = {
      en = "Enable/Disable Mod (Toggle)",
      ["zh-cn"] = "切换式模组启停",
      ["zh-tw"] = "切換模組啟停",
    },
    mod_enable_verbose = {
      en = "Notify on Mod Enabled/Disabled",
      ["zh-cn"] = "模组状态通知",
      ["zh-tw"] = "模組狀態通知",
    },
    overload_protection = {
      en = "Overload Protection",
      ["zh-cn"] = "武器切换时保持键位绑定",
      ["zh-tw"] = "武器切換時保持按鍵綁定",
    },
    overload_protection_tooltip = {
      en = string.format("When enabled, the mod will prevent sequence input which would lead to death from Perils of the Warp. \nThis will NOT prevent deaths caused by manual player inputs."),
      ["zh-cn"] = "切换武器时防止键位绑定自动失效。启用后请注意远程与近战键位可能产生的冲突。",
      ["zh-tw"] = "切換武器時防止按鍵綁定自動失效。 啟用後注意遠程與近戰鍵位可能產生的衝突",
    },
    -- Keybinds
    maintain_bind = {
      en = "Maintain Keybind Status on Weapon Swap",
      ["zh-cn"] = "武器切换时保持键位绑定",
      ["zh-tw"] = "武器切換時保持按鍵狀態",
    },
    maintain_bind_tooltip = {
      en = "Prevents keybinds from disabling themselves when switching weapons. Be aware of overlapping Ranged and Melee keybinds when using this feature.",
      ["zh-cn"] = "切换武器时防止键位绑定自动失效。启用后请注意远程与近战键位可能产生的冲突。",
      ["zh-tw"] = "當切換武器時，防止按鍵綁定自動關閉。使用此功能時，請注意近戰和遠程按鍵綁定的重疊。",
    },
    override_primary = {
        en = "Override Primary Attack Input",
        ["zh-tw"] = "取代主要攻擊操作",
        ["zh-cn"] = "覆盖主要攻击",
    },
    keybinds = {
        en = "Keybinds",
        ["zh-tw"] = "按鍵綁定",
        ["zh-cn"] = "键位绑定",
    },
    keybind_selection_melee = {
        en = "Keybind Selection",
        ["zh-tw"] = "按鍵選擇",
        ["zh-cn"] = "近战选择键位",
    },
    keybind_selection_ranged = {
        en = "Keybind Selection",
        ["zh-tw"] = "按鍵選擇",
        ["zh-cn"] = "远程选择键位",
    },
    keybind_one_pressed = {
        en = "Keybind One (Toggle)",
        ["zh-tw"] = "按鍵一 (切換)",
        ["zh-cn"] = "键位一（切换）",
    },
    keybind_one_held = {
        en = "Keybind One (Held)",
        ["zh-tw"] = "按鍵一 (長按)",
        ["zh-cn"] = "键位一（按住）",
    },
    keybind_two_pressed = {
        en = "Keybind Two (Toggle)",
        ["zh-tw"] = "按鍵二 (切換)",
        ["zh-cn"] = "键位二（切换）",
    },
    keybind_two_held = {
        en = "Keybind Two (Held)",
        ["zh-tw"] = "按鍵二 (長按)",
        ["zh-cn"] = "键位二（按住）",
    },
    keybind_three_pressed = {
        en = "Keybind Three (Toggle)",
        ["zh-tw"] = "按鍵三 (切換)",
        ["zh-cn"] = "键位三（切换）",
    },
    keybind_three_held = {
        en = "Keybind Three (Held)",
        ["zh-tw"] = "按鍵三 (長按)",
        ["zh-cn"] = "键位三（按住）",
    },
    keybind_four_pressed = {
        en = "Keybind Four (Toggle)",
        ["zh-tw"] = "按鍵四 (切換)",
        ["zh-cn"] = "键位四（切换）",
    },
    keybind_four_held = {
        en = "Keybind Four (Held)",
        ["zh-tw"] = "按鍵四 (長按)",
        ["zh-cn"] = "键位四（按住）",
    },
    -- Melee
    melee_settings = {
        en = "Melee Settings",
        ["zh-tw"] = "近戰設定",
        ["zh-cn"] = "近战设置",
    },
    halt_on_interrupt = {
        en = "Halt On Manual Interrupt",
        ["zh-tw"] = "中斷時停止",
        ["zh-cn"] = "中断应急终止",
    },
    halt_on_interrupt_tooltip = {
        en = "Halts the current sequence and turns off active toggled keybinds when interrupted by user inputs.",
        ["zh-tw"] = "當輸入中斷時，停止當前序列並關閉活動的切換按鍵綁定。",
        ["zh-cn"] = "遭遇操作中断时立即终止当前指令，并重置所有切换式键位绑定。",
    },
    current_melee = {
      en = "JUMP TO CURRENT/GLOBAL",
      ["zh-cn"] = "近战武器选择",
      ["zh-tw"] = "近戰武器選擇",
    },
    current_ranged = {
      en = "JUMP TO CURRENT/GLOBAL",
      ["zh-cn"] = "跳转到当前 或 全局",
      ["zh-tw"] = "跳轉到當前 或 全域",
    },
    interrupt = {
      en = "Action On Stun",
      ["zh-cn"] = "当玩家被打晕时",
      ["zh-tw"] = "當玩家被打暈時",
    },
    interrupt_tooltip = {
      en = "Determines the action taken by sequences when the player is stunned/interrupted by external sources.",
      ["zh-cn"] = "确定当玩家被外部来源击晕/打断时，序列所采取的动作",
      ["zh-tw"] = "確定當玩家被外部來源擊暈/打斷時，序列所採取的動作",
    },
    reset = {
      en = "Reset Sequence",
      ["zh-cn"] = "重置序列",
      ["zh-tw"] = "重置序列",
    },
    halt = {
      en = "Halt Sequence",
      ["zh-tw"] = "暂停序列",
      ["zh-cn"] = "中断序列",
 
    },
    melee_weapon_selection = {
        en = "Weapon Selection",
        ["zh-tw"] = "武器選擇",
        ["zh-cn"] = "近战武器选择",
    },
    heavy_buff = {
        en = "Heavy Buff Modifier",
        ["zh-tw"] = "重擊強化調整",
        ["zh-cn"] = "蓄力强化调整",
    },
    heavy_buff_tooltip = {
      en = "When selected, Heavy attacks will be charged until this buff reaches the specified number of stacks in the Heavy Buff Stacks setting.",
      ["zh-cn"] = "启动神圣充能协议后，战术重击将维持相位蓄能状态，直至机魂增幅矩阵达到预设充能阶位（参见『重击增幅协议阶位配置』）。",
      ["zh-tw"] = "啟動神聖充能協定後，戰術重擊將維持相位蓄能狀態，直至機魂增幅矩陣達到預設充能階比特（參見『重擊增幅協定階比特配寘』）。",
    },
    thrust = {
        en = "Thrust",
        ["zh-tw"] = "推進",
        ["zh-cn"] = "推开",
    },
    slow_and_steady = {
        en = "Slow and Steady",
        ["zh-tw"] = "緩慢而確實",
        ["zh-cn"] = "步稳行远",
    },
    crunch = {
      en = "Crunch",
      ["zh-tw"] = "嘎嘎！欧格林满蓄增伤",
      ["zh-cn"] = " 暴力粉碎！欧格林满蓄力增伤天赋",
    },
    heavy_buff_stacks = {
        en = "Heavy Buff Stacks",
        ["zh-tw"] = "重擊強化層數",
        ["zh-cn"] = "蓄力buff层数",
    },
    heavy_buff_special = {
        en = "Special Required For Heavy Modifier",
        ["zh-tw"] = "重擊修飾需要特殊攻擊",
        ["zh-cn"] = "蓄力buff特殊条件层数",
    },
    special_buff_stacks = {
		en = "Heavy Buff Stacks (Special Attacks)",
		["zh-tw"] = "重擊強化層數 （特殊攻擊）",
		["zh-cn"] = "蓄力buff层数 （特殊攻击）",
	},
    always_special = {
      en = "Always Activate Special Actions",
      ["zh-cn"] = "始终激活武器特殊技能",
      ["zh-tw"] = "始终激活武器特殊技能",
    },
    always_special_tooltip = {
      en = "When enabled, the mod will always execute Special actions, regardless of weapon state.",
      ["zh-cn"] = "启用后，无论武器状态如何，mod都将始终执行特殊动作",
      ["zh-tw"] = "啟用後，無論武器狀態如何，mod都將始終執行特殊動作",
    },
    heavy_buff_special_tooltip = {
      en = "When enabled, the Heavy Buff Modifier setting will only take effect while the current weapon's Special Action is active.",
      ["zh-cn"] = "启用后，「蓄力buff修正器」设置将仅在当前武器的特殊动作激活期间生效",
      ["zh-tw"] = "啟用後，「蓄力buff修正器」設定將僅在當前武器的特殊動作啟動期間生效",
    },
    global_melee = {
      en = "GLOBAL",
      ["zh-tw"] = "全局近戰",
      ["zh-cn"] = "全局近战",
    },
    force_heavy_when_special = {
      en = "Force Heavies When Special Active",
      ["zh-cn"] = "全局近战",
      ["zh-tw"] = "全局近戰",
    },
    force_heavy_when_special_tooltip = {
      en = "When enabled, Heavy attacks will be executed when the weapon's Special action is active, regardless of the standard sequence.",
      ["zh-cn"] = "启用后，无论标准顺序如何，当武器的特殊动作处于活动状态时，都将执行重型攻击",
      ["zh-tw"] = "啟用後，無論標準順序如何，當武器的特殊動作處於活動狀態時，都將執行重型攻擊",
    },
    sequence_cycle_point = {
        en = "Cycle Point",
        ["zh-tw"] = "循環點",
        ["zh-cn"] = "循环点",
    },
    sequence_cycle_point_tooltip = {
      en = "Once the sequence has completed, it will restart from this step.",
      ["zh-cn"] = "当技能序列完整执行后，将从本步骤重新开始循环",
      ["zh-tw"] = "當技能序列完整執行後，將從本步驟重新開始迴圈",
 
    },
    no_repeat = {
      en = "Halt Sequence on Completion",
      ["zh-tw"] = "步驟一",
      ["zh-cn"] = "步骤1",
    },
    sequence_step_one = {
        en = "Step One",
        ["zh-tw"] = "步驟一",
        ["zh-cn"] = "步骤1",
    },
    sequence_step_two = {
        en = "Step Two",
        ["zh-tw"] = "步驟二",
        ["zh-cn"] = "步骤2",
    },
    sequence_step_three = {
        en = "Step Three",
        ["zh-tw"] = "步驟三",
        ["zh-cn"] = "步骤3",
    },
    sequence_step_four = {
        en = "Step Four",
        ["zh-tw"] = "步驟四",
        ["zh-cn"] = "步骤4",
    },
    sequence_step_five = {
        en = "Step Five",
        ["zh-tw"] = "步驟五",
        ["zh-cn"] = "步骤5",
    },
    sequence_step_six = {
        en = "Step Six",
        ["zh-tw"] = "步驟六",
        ["zh-cn"] = "步骤6",
    },
    sequence_step_seven = {
        en = "Step Seven",
        ["zh-tw"] = "步驟七",
        ["zh-cn"] = "步驟7",
    },
    sequence_step_eight = {
        en = "Step Eight",
        ["zh-tw"] = "步驟八",
        ["zh-cn"] = "步骤8",
    },
    sequence_step_nine = {
        en = "Step Nine",
        ["zh-tw"] = "步驟九",
        ["zh-cn"] = "步骤9",
    },
    sequence_step_ten = {
        en = "Step Ten",
        ["zh-tw"] = "步驟十",
        ["zh-cn"] = "步骤10"
    },
    sequence_step_eleven = {
        en = "Step Eleven",
        ["zh-tw"] = "步驟十一",
        ["zh-cn"] = "步骤11",
    },
    sequence_step_twelve = {
        en = "Step Twelve",
        ["zh-tw"] = "步驟十二",
        ["zh-cn"] = "步骤12",
    },
    -- Sequence steps
    none = {
        en = "None",
        ["zh-tw"] = "無",
        ["zh-cn"] = "无",
    },
    light_attack = {
        en = "Light Attack",
        ["zh-tw"] = "輕擊",
        ["zh-cn"] = "轻攻击",
    },
    heavy_attack = {
        en = "Heavy Attack",
        ["zh-tw"] = "重擊",
        ["zh-cn"] = "重攻击",
    },
    special_action = {
        en = "Special Action",
        ["zh-tw"] = "特殊動作",
        ["zh-cn"] = "特殊动作",
    },
    block = {
        en = "Block",
        ["zh-tw"] = "格擋",
        ["zh-cn"] = "格挡",
    },
    push = {
        en = "Push",
        ["zh-tw"] = "推擊",
        ["zh-cn"] = "推",
    },
    push_attack = {
        en = "Push Attack",
        ["zh-tw"] = "助推攻擊",
        ["zh-cn"] = "推攻击",
    },
    wield = {
      en = "Swap Weapon",
      ["zh-cn"] = "交换武器",
      ["zh-tw"] = "交換武器",
    },
    -- Reset
    reset_weapon_melee = {
        en = "RESET MELEE WEAPON",
        ["zh-tw"] = "重置近戰武器",
        ["zh-cn"] = "重置近战武器",
    },
    reset_all_melee = {
        en = "RESET ALL MELEE SETTINGS",
        ["zh-tw"] = "重置所有近戰設定",
        ["zh-cn"] = "重置所有近战设置",
    },
    reset_weapon_ranged = {
        en = "RESET RANGED WEAPON",
        ["zh-tw"] = "重置遠程武器",
        ["zh-cn"] = "重置远程武器",
    },
    reset_all_ranged = {
        en = "RESET ALL RANGED SETTINGS",
        ["zh-tw"] = "重置所有遠程設定",
        ["zh-cn"] = "重置所有远程设置",
    },
    -- Ranged
    ranged_settings = {
        en = "Ranged Settings",
        ["zh-tw"] = "遠程設定",
        ["zh-cn"] = "远程设置",
    },
    always_charge = {
        en = "Always Auto-Release Charges",
        ["zh-tw"] = "蓄力將自動釋放，無需手動操作",
        ["zh-cn"] = "始终自动释放充能",
    },
    always_charge_threshold = {
        en = "Global Charge Threshold %%",
        ["zh-tw"] = "蓄力將自動釋放，無需手動操作的閾值 %%",
        ["zh-cn"] = "充能自动释放阈值 %%",
    },
    always_charge_tooltip = {
        en = string.format("Automatically release charged attacks when the charge is full, regardless of other ranged settings."),
        ["zh-tw"] = string.format("無論其他遠程設定如何，在蓄力完成時自動釋放蓄力攻擊。"),
        ["zh-cn"] = string.format("当充能满时自动释放充能攻击，无论其他远程设置如何。"),
    },
    always_charge_threshold_tooltip = {
      en = string.format("When enabled, this threshold will be used to determine when to auto-release charged attacks. \nThis will be overridden by the Weapon Charge Threshold setting if that setting is lower."),
      ["zh-cn"] = string.format("该阈值决定何时释放闪击\n 如果充能阈值设置过低，此设置将被覆盖"),
      ["zh-tw"] = string.format("該閾值决定何時釋放閃擊\n 如果充能閾值設定過低（蓄力將自動釋放，無需手動操作），此設定將被覆蓋"),
    },
    ranged_weapon_selection = {
      en = "Weapon Selection",
      ["zh-tw"] = "遠程武器選擇",
      ["zh-cn"] = "远程武器选择",
    },
    global_ranged = {
      en = "GLOBAL",
      ["zh-tw"] = "全局遠程",
      ["zh-cn"] = "全局远程",
    },
    automatic_fire = {
        en = "Automatic Fire",
        ["zh-tw"] = "自動射擊",
        ["zh-cn"] = "自动射击",
    },
    standard = {
        en = "Standard",
        ["zh-tw"] = "標準",
        ["zh-cn"] = "标准",
    },
    charged = {
        en = "Charged",
        ["zh-tw"] = "蓄力",
        ["zh-cn"] = "充能",
    },
    special = {
        en = "Special",
        ["zh-tw"] = "特殊",
        ["zh-cn"] = "特殊",
    },
    special_standard = {
        en = "Special + Standard",
        ["zh-tw"] = "特殊和標準",
        ["zh-cn"] = "特殊 + 标准",
    },
    special_charged = {
      en = "Special (Charged)",
      ["zh-cn"] = "特殊（蓄力）",
      ["zh-tw"] = "特殊（蓄力）",
    },
    auto_charge_threshold = {
        en = "Weapon Charge Threshold %%",
        ["zh-tw"] = "蓄力閾值 %%",
        ["zh-cn"] = "充能阈值 %%",
    },
    auto_shoot = {
        en = "Shoot Without Input",
        ["zh-tw"] = "無輸入自動射擊",
        ["zh-cn"] = "无需输入即可射击",
    },
    ads_filter = {
        en = "ADS/Hipfire Filter",
        ["zh-tw"] = "瞄準/腰射過濾器",
        ["zh-cn"] = "瞄准/腰射过滤",
    },
    ads_only = {
        en = "ADS Only",
        ["zh-tw"] = "僅瞄準",
        ["zh-cn"] = "仅瞄准",
    },
    ads_hip = {
        en = "ADS and Hipfire",
        ["zh-tw"] = "瞄準和腰射",
        ["zh-cn"] = "瞄准和腰射",
    },
    hip_only = {
        en = "Hipfire Only",
        ["zh-tw"] = "僅腰射",
        ["zh-cn"] = "仅腰射（散射）",
    },
    rate_of_fire = {
        en = "Rate of Fire",
        ["zh-tw"] = "射速",
        ["zh-cn"] = "射速",
    },
    rate_of_fire_hip = {
        en = "Hipfire Attack Delay (ms)",
        ["zh-tw"] = "射速 %% (腰射)",
        ["zh-cn"] = "射速 %% (散射)",
    },
    rate_of_fire_ads = {
        en = "ADS Attack Delay (ms)",
        ["zh-tw"] = "射速 %% (瞄準)",
        ["zh-cn"] = "射速 %% (瞄准)",
    },
    automatic_special = {
        en = "Automatic Special",
        ["zh-tw"] = "自動特殊攻擊",
        ["zh-cn"] = "自动特殊攻击",
    },
    psyker_throwing_knives = {
        en = "Assail",
        ["zh-tw"] = "突襲",
        ["zh-cn"] = "强袭",
    },
}

--------------------------------------------------------------------------
-- PLEASE DO NOT EDIT BEYOND THIS POINT IF YOU ARE ADDING LOCALIZATIONS --
--------------------------------------------------------------------------

local family_prefix = "loc_weapon_family_"
local pattern_prefix = "loc_weapon_pattern_"
local mark_prefix = "loc_weapon_mark_"
for weapon, _ in pairs(WeaponTemplates) do
    local localized_family = Localize(family_prefix .. weapon)
    local localized_pattern = Localize(pattern_prefix .. weapon)
    if not localized_pattern or string.find(localized_pattern, "unlocalized") then
        -- Some weapons use the WRONG WEAPON NAME for localization because whoever changed how data is stored in this update is a moron
        local alt_pattern = weapon:gsub("_m%d+", "_m1") -- fallback to first mark
        localized_pattern = Localize(pattern_prefix .. alt_pattern)
    end
    -- Mark9 compatibility
    local localized_mark
    local mark_key = mark_prefix .. weapon
    if Mark9 then
        -- Bypass standard localization function for weapon marks to avoid interacting with Mark9's hook unecessarily
        local manager = Managers.localization
        if manager then
            local localizers = manager._localizers
            for ii = 1, #localizers do
                local localizer = localizers[ii]
                local loc_str
                if manager._lookup_with_tag ~= nil and manager._enable_string_tags then
                    loc_str = manager:_lookup_with_tag(localizer, mark_key)
                else
                    loc_str = Localizer.lookup(localizer, mark_key)
                end
                -- Only attempt localization for strings that won't cause problems for Mark9 hook
                if loc_str then
                    localized_mark = Localize(mark_key)
                end
            end
        end
    -- If Mark9 isn't present localization failures can just be ignored as they won't be visible to the user anyway
    else
        localized_mark = Localize(mark_key)
    end
    local localized = localized_family and localized_pattern and localized_mark and string.format("%s %s %s", localized_pattern, localized_mark, localized_family)
    if localized and not string.find(localized, "unlocalized") then
        localizations[weapon] = {
            en = localized
        }
    end
end


return localizations