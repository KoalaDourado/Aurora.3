/var/datum/controller/subsystem/persistent_configuration/SSpersist_config = null

/datum/controller/subsystem/persistent_configuration
	name = "Persistent Configuration"
	init_order = SS_INIT_PERSISTENT_CONFIG
	flags = SS_NO_FIRE

// Config options go here. Make sure to give them sane default values!
// DO NOT keep security information (passwords or something like that)
// in this config! This config is viewable by VV.

	// Keep this variable up to date for the parsers to work.
	var/list/_variables_to_save = list("last_gamemode", "rounds_since_hard_restart", "forced_awaymission")

	var/last_gamemode = "extended"
	var/rounds_since_hard_restart = 0
	var/forced_awaymission = FALSE

/datum/controller/subsystem/persistent_configuration/Initialize(timeofday)
	SSpersist_config = src

	load_from_file("data/persistent_config.json")

/datum/controller/subsystem/persistent_configuration/proc/load_from_file(filename)
	var/file = file2text(filename)

	if (!file)
		log_config("SSpersist_config: file [filename] not found, falling back to default values.")
		return

	var/list/decoded = null

	try
		decoded = json_decode(file)
	catch (var/exception/e)
		log_config("ERROR: SSperist_config: invalid JSON detected. Error: [e]")
		log_exception(e)
		return

	if (!decoded || !decoded.len)
		return

	populate_variables(decoded)

/datum/controller/subsystem/persistent_configuration/proc/save_to_file(filename)
	var/list/to_save = list()
	for (var/key in _variables_to_save)
		to_save[key] = vars[key]

	var/file_contents = json_encode(to_save)
	fdel(filename)
	text2file(file_contents, filename)

#define IF_FOUND_USE(container, key) if (container[#key]) { ##key = container[#key]; }
#define IF_FOUND_CONV(container, key, conv) if (container[#key]) { ##key = ##conv(container[#key]); }

/datum/controller/subsystem/persistent_configuration/proc/populate_variables(list/decoded)
	IF_FOUND_USE(decoded, last_gamemode)
	master_mode = last_gamemode

	IF_FOUND_CONV(decoded, rounds_since_hard_restart, text2num)
	IF_FOUND_USE(decoded, forced_awaymission)

#undef IF_FOUND_USE
#undef IF_FOUND_CONV
