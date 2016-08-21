/client/proc/debug_antagonist_template(antag_type in all_antag_types)
	set category = "Debug"
	set name = "Debug Antagonist"
	set desc = "Debug an antagonist template."

	var/datum/antagonist/antag = all_antag_types[antag_type]
	if(antag)
		usr.client.debug_variables(antag)
		message_admins("Admin [key_name_admin(usr)] is debugging the [antag.role_text] template.")

/client/proc/debug_controller(controller in list("Master","Ticker","Ticker Process","Air","Jobs","Sun","Radio","Shuttles","Emergency Shuttle","Configuration","pAI", "Cameras", "Transfer Controller", "Gas Data","Event","Plants","Alarm","Chemistry","Wireless","Observation","Tgui") + module_controllers)
	set category = "Debug"
	set name = "Debug Controller"
	set desc = "Debug the various periodic loop controllers for the game (be careful!)"

	if(!holder)	return

	if(controller in module_controllers)
		debug_variables(module_controllers[controller])
		feedback_add_details("admin_verb","DMod")
	else
		switch(controller)
			if("Master")
				debug_variables(master_controller)
				feedback_add_details("admin_verb","DMC")
			if("Ticker")
				debug_variables(ticker)
				feedback_add_details("admin_verb","DTicker")
			if("Ticker Process")
				debug_variables(tickerProcess)
				feedback_add_details("admin_verb","DTickerProcess")
			if("Jobs")
				debug_variables(job_master)
				feedback_add_details("admin_verb","DJobs")
			if("Radio")
				debug_variables(radio_controller)
				feedback_add_details("admin_verb","DRadio")
			if("Shuttles")
				debug_variables(shuttle_controller)
				feedback_add_details("admin_verb","DShuttles")
			if("Emergency Shuttle")
				debug_variables(emergency_shuttle)
				feedback_add_details("admin_verb","DEmergency")
			if("Configuration")
				debug_variables(config)
				feedback_add_details("admin_verb","DConf")
			if("Event")
				debug_variables(event_manager)
				feedback_add_details("admin_verb", "DEvent")
			if("Plants")
				debug_variables(plant_controller)
				feedback_add_details("admin_verb", "DPlants")
			if("Chemistry")
				debug_variables(chemistryProcess)
				feedback_add_details("admin_verb", "DChem")
			if("Wireless")
				debug_variables(wirelessProcess)
				feedback_add_details("admin_verb", "DWifi")
			if("Observation")
				debug_variables(all_observable_events)
				feedback_add_details("admin_verb", "DObservation")
			if("Tgui")
				debug_variables(tguiProcess)
				feedback_add_details("admin_verb", "DTgui")
	message_admins("Admin [key_name_admin(usr)] is debugging the [controller] controller.")
	return
