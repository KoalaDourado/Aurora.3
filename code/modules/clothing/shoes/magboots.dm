/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle. They're large enough to be worn over other footwear."
	name = "magboots"
	icon_state = "magboots0"
	item_state = "magboots"
	center_of_mass = list("x" = 17,"y" = 12)
	species_restricted = null
	force = 5
	overshoes = 1
	item_flags = THICKMATERIAL|AIRTIGHT|INJECTIONPORT
	var/magpulse = 0
	var/icon_base = "magboots"
	action_button_name = "Toggle Magboots"
	var/obj/item/clothing/shoes/shoes = null	//Undershoes
	var/mob/living/carbon/human/wearer = null	//For shoe procs
	drop_sound = 'sound/items/drop/toolbox.ogg'
	pickup_sound = 'sound/items/pickup/toolbox.ogg'

/obj/item/clothing/shoes/magboots/Destroy()
	. = ..()
	src.shoes = null
	src.wearer = null

/obj/item/clothing/shoes/magboots/proc/set_slowdown()
	slowdown = shoes? max(0, shoes.slowdown): 0	//So you can't put on magboots to make you walk faster.
	if (magpulse)
		slowdown += 3

/obj/item/clothing/shoes/magboots/proc/update_wearer()
	if(QDELETED(wearer))
		return

	var/mob/living/carbon/human/H = wearer
	if(shoes && istype(H))
		if(!H.equip_to_slot_if_possible(shoes, slot_shoes))
			shoes.forceMove(get_turf(src))
		src.shoes = null
	wearer.update_floating()
	wearer = null

/obj/item/clothing/shoes/magboots/attack_self(mob/user)
	if(magpulse)
		item_flags &= ~NOSLIP
		magpulse = 0
		set_slowdown()
		force = 3
		if(icon_base) icon_state = "[icon_base]0"
		to_chat(user, "You disable the mag-pulse traction system.")
	else
		item_flags |= NOSLIP
		magpulse = 1
		set_slowdown()
		force = 5
		if(icon_base) icon_state = "[icon_base]1"
		playsound(get_turf(src), 'sound/effects/magnetclamp.ogg', 20)
		to_chat(user, "You enable the mag-pulse traction system.")
	user.update_inv_shoes()	//so our mob-overlays update
	user.update_action_buttons()
	user.update_floating()

/obj/item/clothing/shoes/magboots/negates_gravity()
	if(magpulse)
		return 1
	else
		return 0

/obj/item/clothing/shoes/magboots/mob_can_equip(mob/user, slot, disable_warning = FALSE)
	if(slot != slot_shoes)
		return ..()

	var/mob/living/carbon/human/H = user
	if(H.shoes)
		shoes = H.shoes
		if(shoes.overshoes)
			to_chat(user, "You are unable to wear \the [src] as \the [H.shoes] are in the way.")
			shoes = null
			return 0
		H.drop_from_inventory(shoes,src)	//Remove the old shoes so you can put on the magboots.

	if(!..())
		if(shoes) 	//Put the old shoes back on if the check fails.
			if(H.equip_to_slot_if_possible(shoes, slot_shoes))
				src.shoes = null
		return 0

	if (shoes)
		to_chat(user, "You slip \the [src] on over \the [shoes].")
	set_slowdown()
	wearer = H
	return 1

/obj/item/clothing/shoes/magboots/dropped()
	..()
	INVOKE_ASYNC(src, PROC_REF(update_wearer))

/obj/item/clothing/shoes/magboots/mob_can_unequip()
	. = ..()
	if (.)
		INVOKE_ASYNC(src, PROC_REF(update_wearer))

/obj/item/clothing/shoes/magboots/examine(mob/user)
	..(user)
	var/state = "disabled"
	if(item_flags & NOSLIP)
		state = "enabled"
	to_chat(user, "Its mag-pulse traction system appears to be [state].")

/obj/item/clothing/shoes/magboots/hegemony
	name = "hegemony magboots"
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle. They're large enough to be worn over other footwear. This variant is frequently seen in the Hegemony Navy."
	icon = 'icons/obj/unathi_items.dmi'
	icon_state = "hegemony_magboots0"
	item_state = "hegemony_magboots"
	icon_base = "hegemony_magboots"
	contained_sprite = TRUE
