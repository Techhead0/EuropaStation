/atom/movable/update_nearby_tiles(var/need_rebuild)
	. = ..(need_rebuild)
	fluid_update()

/obj/structure/Destroy()
	fluid_update()
	return ..()

/obj/structure/Move()
	. = ..()
	fluid_update()

/obj/structure/New()
	. = ..()
	fluid_update()

/obj/effect/Move()
	. = ..()
	fluid_update()

/obj/effect/Destroy()
	. = ..()
	fluid_update()

/obj/effect/New()
	. = ..()
	fluid_update()

/atom/proc/fluid_update()
	var/turf/T = get_turf(src)
	if(istype(T))
		T.fluid_update()

/turf/fluid_update(var/ignore_neighbors)

	fluid_blocked_dirs = null
	fluid_can_pass = null

	if(!fluid_master)
		return

	// Wake up our neighbors.
	if(!ignore_neighbors)
		for(var/checkdir in cardinal)
			var/turf/T = get_step(src, checkdir)
			if(T) T.fluid_update(1)

	// Wake up ourself!
	if(flooded)
		if(flood_neighbors(dry_run=1))
			fluid_master.add_active_source(src)
	else
		for(var/obj/effect/fluid/F in src)
			fluid_master.add_active_fluid(F)

/turf/proc/get_fluid_blocking_dirs()
	// Update valid spread directions and flow data.
	if(isnull(fluid_blocked_dirs))
		fluid_blocked_dirs = 0
		for(var/obj/structure/window/W in src)
			if(W.density)
				fluid_blocked_dirs |= W.dir
		for(var/obj/machinery/door/window/D in src)
			if(D.density)
				fluid_blocked_dirs |= D.dir
	return fluid_blocked_dirs
