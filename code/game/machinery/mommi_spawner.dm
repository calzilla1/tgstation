/obj/machinery/mommi_spawner
	name = "MoMMI Fabricator"
	desc = "A large pad sunk into the ground."
	icon = 'icons/obj/robotics.dmi'
	icon_state = "mommispawner-idle"
	density = 1
	anchored = 1
	var/metal=0
	var/metalPerMoMMI=10
	var/metalPerTick=1
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 5000
	var/obj/effect/mob_spawn/mommi/spawner = null

/obj/machinery/mommi_spawner/power_change()
	if (powered())
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	update_icon()


//Mommi spawner: located inside the machine itself, will spawn an actual mommi when activated.
/obj/effect/mob_spawn/mommi
	name = "mommi spawner"
	desc = "An assembled MoMMI ready to be activated."
	mob_name = "a mommi"
	icon = 'icons/obj/robotics.dmi'
	icon_state = "mommispawner-idle"
	density = FALSE
	death = FALSE
	roundstart = FALSE
	instant = FALSE
	permanent = FALSE
	uses = 1
	ghost_usable = TRUE
	mob_type = /mob/living/silicon/robot/mommi
	banType = "mommi"
	flavour_text = "<span class='big bold'>You are a repair drone assigned to this sector of space.</b>"
	assignedrole = "Repair Drone"
	var/obj/machinery/mommi_spawner/master

/obj/effect/mob_spawn/mommi/special(mob/living/new_spawn)
	if(istype(master))
		master.spawner = null
		master.update_icon()
	new_spawn.forceMove(get_turf(src))
	if(ismommi(new_spawn))
		var/mob/living/silicon/robot/mommi/M = new_spawn
		M.initialize_killswitch()

/obj/effect/mob_spawn/mommi/Initialize()
	. = ..()
	master = loc
	var/area/A = get_area(src)
	if(A)
		notify_ghosts("A MoMMI is ready to be fabricated in [A.name].", 'sound/effects/bin_close.ogg', source = src, action = NOTIFY_ATTACK, flashwindow = FALSE)

/obj/machinery/mommi_spawner/process()
	if(stat & NOPOWER ||  spawner)
		return
	metal+=metalPerTick
	if(metal >= metalPerMoMMI)
		spawner = new(src)
		metal = 0
		update_icon()

/obj/machinery/mommi_spawner/attack_ghost(var/mob/dead/observer/user as mob)
	if(spawner)
		spawner.attack_ghost(user)

/*
/obj/machinery/mommi_spawner/proc/makeMoMMI(var/mob/user)
	if(!user || !user.key)
		building=0
		update_icon()
		return
	var/mob/living/silicon/robot/mommi/M = new /mob/living/silicon/robot/mommi(get_turf(loc))
	if(!M)
		building=0
		update_icon()
		return

	//M.custom_name = created_name

	if(M.key)
		M.ghostize(1)
	M.key = user.key


	M.job = "MoMMI"
	M.generated = 1
	M.invisibility = 0

	M.initialize_killswitch()

	//M.cell = locate(/obj/item/weapon/cell) in contents
	//M.cell.loc = M
	user.loc = M//Should fix cybros run time erroring when blown up. It got deleted before, along with the frame.

	M.mmi = new /obj/item/device/mmi(M)
	M.mmi.transfer_identity(user)//Does not transfer key/client.

	spawn(50) //delay to hopefully prevent mind getting deleted while it still hasn't transfered
		qdel(user)

	metal=0
	building=0
	update_icon()
	M.updateicon()
	M.cell.maxcharge = 15000
	M.cell.charge = 15000
*/
/obj/machinery/mommi_spawner/update_icon()
	if(stat & NOPOWER)
		icon_state="mommispawner-nopower"
	else if((metal < metalPerMoMMI) && !spawner)
		icon_state="mommispawner-recharging"
	else
		icon_state="mommispawner-idle"

/obj/machinery/mommi_spawner/wireless //For uprising event
	use_power = 0
	density = 0
	metalPerMoMMI = 0
	idle_power_usage = 0
	active_power_usage = 0