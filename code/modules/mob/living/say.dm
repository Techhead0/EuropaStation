/mob/living/proc/binarycheck()

	if (!ishuman(src))
		return

	var/mob/living/human/H = src
	if (H.l_ear || H.r_ear)
		var/obj/item/device/radio/headset/dongle
		if(istype(H.l_ear,/obj/item/device/radio/headset))
			dongle = H.l_ear
		else
			dongle = H.r_ear
		if(!istype(dongle)) return
		if(dongle.translate_binary) return 1

/mob/living/proc/get_default_language()
	return default_language

/mob/living/proc/handle_speech_problems(var/message, var/verb)
	var/list/returns[3]
	var/speech_problem_flag = 0

	if((HULK in mutations) && health >= 25 && length(message))
		message = "[uppertext(message)]!!!"
		verb = pick("yells","roars","hollers")
		speech_problem_flag = 1
	if(slurring)
		message = slur(message)
		verb = pick("slobbers","slurs")
		speech_problem_flag = 1
	if(stuttering)
		message = stutter(message)
		verb = pick("stammers","stutters")
		speech_problem_flag = 1

	returns[1] = message
	returns[2] = verb
	returns[3] = speech_problem_flag
	return returns

/mob/living/proc/handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name)
	if(message_mode == "intercom")
		for(var/obj/item/device/radio/intercom/I in view(1, null))
			I.talk_into(src, message, verb, speaking)
			used_radios += I
	return 0

/mob/living/proc/handle_speech_sound()
	var/list/returns[2]
	returns[1] = null
	returns[2] = null
	return returns

/mob/living/proc/get_speech_ending(verb, var/ending)
	if(ending=="!")
		return pick("exclaims","shouts","yells")
	if(ending=="?")
		return "asks"
	return verb

/mob/living/say(var/message, var/datum/language/speaking = null, var/verb="says", var/alt_name="")
	if(client)
		if(client.prefs.muted & MUTE_IC)
			src << "\red You cannot speak in IC (Muted)."
			return

	if(stat)
		if(stat == 2)
			return say_dead(message)
		return

	var/message_mode = parse_message_mode(message, "headset")

	switch(copytext(message,1,2))
		if("*") return emote(copytext(message,2))
		if("^") return custom_emote(1, copytext(message,2))

	//parse the radio code and consume it
	if (message_mode)
		if (message_mode == "headset")
			message = copytext(message,2)	//it would be really nice if the parse procs could do this for us.
		else
			message = copytext(message,3)

	message = trim_left(message)

	//parse the language code and consume it
	if(!speaking)
		speaking = parse_language(message)
	if(speaking)
		message = copytext(message,2+length(speaking.key))
	else
		speaking = get_default_language()

	// This is broadcast to all mobs with the language,
	// irrespective of distance or anything else.
	if(speaking && (speaking.flags & HIVEMIND))
		speaking.broadcast(src,trim(message))
		return 1

	verb = say_quote(message, speaking)

	if(is_muzzled())
		src << "<span class='danger'>You're muzzled and cannot speak!</span>"
		return

	message = trim_left(message)

	if(!(speaking && (speaking.flags & NO_STUTTER)))
		message = handle_autohiss(message, speaking)

		var/list/handle_s = handle_speech_problems(message, verb)
		message = handle_s[1]
		verb = handle_s[2]

	if(!message || message == "")
		return 0

	var/list/obj/item/used_radios = new
	if(handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name))
		return 1

	var/list/handle_v = handle_speech_sound()
	var/sound/speech_sound = handle_v[1]
	var/sound_vol = handle_v[2]

	var/italics = 0
	var/message_range = world.view

	//speaking into radios
	if(used_radios.len)
		italics = 1
		message_range = 1
		if(speaking)
			message_range = speaking.get_talkinto_msg_range(message)
		var/msg
		if(!speaking || !(speaking.flags & NO_TALK_MSG))
			msg = "<span class='notice'>\The [src] talks into \the [used_radios[1]]</span>"
		for(var/mob/living/M in hearers(5, src))
			if((M != src) && msg)
				M.show_message(msg)
			if (speech_sound)
				sound_vol *= 0.5

	var/turf/T = get_turf(src)

	//handle nonverbal and sign languages here
	if (speaking)
		if (speaking.flags & NONVERBAL)
			if (prob(30))
				src.custom_emote(1, "[pick(speaking.signlang_verb)].")

		if (speaking.flags & SIGNLANG)
			return say_signlang(message, pick(speaking.signlang_verb), speaking)

	var/list/listening = list()
	var/list/listening_obj = list()

	if(T)
		//make sure the air can transmit speech - speaker's side
		var/atom/environment = T.return_air()
		var/pressure = (environment)? environment.return_pressure() : 0
		if(pressure < SOUND_MINIMUM_PRESSURE)
			message_range = 1

		if (pressure < ONE_ATMOSPHERE*0.4) //sound distortion pressure, to help clue people in that the air is thin, even if it isn't a vacuum yet
			italics = 1
			sound_vol *= 0.5 //muffle the sound a bit, so it's like we're actually talking through contact

		//DO NOT FUCKING CHANGE THIS TO GET_OBJ_OR_MOB_AND_BULLSHIT() -- Hugs and Kisses ~Ccomp
		var/list/hear = hear(message_range,T)
		var/list/hearturfs = list()

		for(var/I in hear)
			if(ismob(I))
				var/mob/M = I
				listening += M
				hearturfs += M.locs[1]
			else if(isobj(I))
				var/obj/O = I
				hearturfs += O.locs[1]
				listening_obj |= O


		for(var/mob/M in player_list)
			if(M.stat == DEAD && M.client && (M.client.prefs.toggles & CHAT_GHOSTEARS))
				listening |= M
				continue
			if(M.loc && M.locs[1] in hearturfs)
				listening |= M

	var/speech_bubble_test = say_test(message)
	var/image/speech_bubble = image('icons/mob/creatures/talk.dmi',src,"h[speech_bubble_test]")
	spawn(30) qdel(speech_bubble)

	for(var/mob/M in listening)
		M << speech_bubble
		M.hear_say(message, verb, speaking, alt_name, italics, src, speech_sound, sound_vol)

	for(var/obj/O in listening_obj)
		spawn(0)
			if(O) //It's possible that it could be deleted in the meantime.
				O.hear_talk(src, message, verb, speaking)

	log_say("[name]/[key] : [message]")
	return 1

/mob/living/proc/say_signlang(var/message, var/verb="gestures", var/datum/language/language)
	for (var/mob/O in viewers(src, null))
		O.hear_signlang(message, verb, language, src)
	return 1

/obj/effect/speech_bubble
	var/mob/parent

/mob/proc/GetVoice()
	return name
