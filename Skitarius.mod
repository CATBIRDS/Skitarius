return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Skitarius` encountered an error loading the Darktide Mod Framework.")

		new_mod("Skitarius", {
			mod_script       = "Skitarius/scripts/mods/Skitarius/Skitarius",
			mod_data         = "Skitarius/scripts/mods/Skitarius/Skitarius_data",
			mod_localization = "Skitarius/scripts/mods/Skitarius/Skitarius_localization",
		})
	end,
	packages = {},
}
