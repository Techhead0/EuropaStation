/obj/item/reagent_containers/spray
	name = "spray bottle"
	desc = "A spray bottle, with an unscrewable top."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cleaner"
	item_state = "cleaner"
	flags = OPENCONTAINER|NOBLUDGEON
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = 2.0
	throw_speed = 2
	throw_range = 10
	amount_per_transfer_from_this = 10
	unacidable = 1 //plastic
	possible_transfer_amounts = list(5,10) //Set to null instead of list, if there is only one.
	var/spray_size = 3
	var/list/spray_sizes = list(1,3)
	volume = 250

/obj/item/reagent_containers/spray/New()
	..()
	src.verbs -= /obj/item/reagent_containers/verb/set_APTFT

/obj/item/reagent_containers/spray/afterattack(atom/A as mob|obj, mob/user as mob, proximity)
	if(istype(A, /obj/item/storage) || istype(A, /obj/structure/table) || istype(A, /obj/structure/closet) || istype(A, /obj/item/reagent_containers))
		return

	if(proximity)
		if(standard_dispenser_refill(user, A))
			return

	if(reagents.total_volume < amount_per_transfer_from_this)
		user << "<span class='notice'>\The [src] is empty!</span>"
		return

	Spray_at(A, user, proximity)

	playsound(src.loc, 'sound/effects/spray2.ogg', 50, 1, -6)

	user.setClickCooldown(4)

	if(reagents.has_reagent(REAGENT_ID_ACID))
		message_admins("[key_name_admin(user)] fired acid from \a [src].")
		log_game("[key_name(user)] fired acid from \a [src].")
	return

/obj/item/reagent_containers/spray/proc/Spray_at(atom/A as mob|obj, mob/user as mob, proximity)
	if (A.density && proximity)
		A.visible_message("[usr] sprays [A] with [src].")
		reagents.splash(A, amount_per_transfer_from_this)
	else
		spawn(0)
			var/obj/effect/effect/water/chempuff/D = new/obj/effect/effect/water/chempuff(get_turf(src))
			var/turf/my_target = get_turf(A)
			D.create_reagents(amount_per_transfer_from_this)
			if(!src)
				return
			reagents.trans_to_obj(D, amount_per_transfer_from_this)
			D.set_color()
			D.set_up(my_target, spray_size, 10)
	return

/obj/item/reagent_containers/spray/attack_self(var/mob/user)
	if(!possible_transfer_amounts)
		return
	amount_per_transfer_from_this = next_in_list(amount_per_transfer_from_this, possible_transfer_amounts)
	spray_size = next_in_list(spray_size, spray_sizes)
	user << "<span class='notice'>You adjusted the pressure nozzle. You'll now use [amount_per_transfer_from_this] units per spray.</span>"

/obj/item/reagent_containers/spray/examine(mob/user)
	if(..(user, 0) && loc == user)
		user << "[round(reagents.total_volume)] units left."
	return

/obj/item/reagent_containers/spray/verb/empty()

	set name = "Empty Spray Bottle"
	set category = "Object"
	set src in usr

	if (alert(usr, "Are you sure you want to empty that?", "Empty Bottle:", "Yes", "No") != "Yes")
		return
	if(isturf(usr.loc))
		usr << "<span class='notice'>You empty \the [src] onto the floor.</span>"
		reagents.splash(usr.loc, reagents.total_volume)

//space cleaner
/obj/item/reagent_containers/spray/cleaner
	name = "space cleaner"
	desc = "BLAM!-brand non-foaming space cleaner!"

/obj/item/reagent_containers/spray/cleaner/drone
	name = "space cleaner"
	desc = "BLAM!-brand non-foaming space cleaner!"
	volume = 50

/obj/item/reagent_containers/spray/cleaner/initialize()
	..()
	reagents.add_reagent(REAGENT_ID_CLEANER, volume)

/obj/item/reagent_containers/spray/antiseptic
	name = "antiseptic"
	desc = "Great for hiding incriminating bloodstains and sterilizing scalpels."

/obj/item/reagent_containers/spray/antiseptic/initialize()
	..()
	reagents.add_reagent(REAGENT_ID_ANTISEPTIC, volume)

/obj/item/reagent_containers/spray/waterflower
	name = "water flower"
	desc = "A seemingly innocent sunflower...with a twist."
	icon = 'icons/obj/device.dmi'
	icon_state = "sunflower"
	item_state = "sunflower"
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = null
	volume = 10

/obj/item/reagent_containers/spray/waterflower/initialize()
	..()
	reagents.add_reagent(REAGENT_ID_WATER, 10)

/obj/item/reagent_containers/spray/chemsprayer
	name = "chem sprayer"
	desc = "A utility used to spray large amounts of reagent in a given area."
	icon = 'icons/obj/gun.dmi'
	icon_state = "chemsprayer"
	item_state = "chemsprayer"
	throwforce = 3
	w_class = 3.0
	possible_transfer_amounts = null
	volume = 600

/obj/item/reagent_containers/spray/chemsprayer/Spray_at(atom/A as mob|obj)
	var/direction = get_dir(src, A)
	var/turf/T = get_turf(A)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))
	var/list/the_targets = list(T, T1, T2)

	for(var/a = 1 to 3)
		spawn(0)
			if(reagents.total_volume < 1) break
			var/obj/effect/effect/water/chempuff/D = new/obj/effect/effect/water/chempuff(get_turf(src))
			var/turf/my_target = the_targets[a]
			D.create_reagents(amount_per_transfer_from_this)
			if(!src)
				return
			reagents.trans_to_obj(D, amount_per_transfer_from_this)
			D.set_color()
			D.set_up(my_target, rand(6, 8), 2)
	return
