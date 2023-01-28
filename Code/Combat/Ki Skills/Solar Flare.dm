var/image/fireOverlay = image(icon = 'Fire Aura.dmi', pixel_y = -19, pixel_x = -16)

var
	//bonus for humans
	humanSolarFlareRange = 2
	humanSolarFlareDuration = 2
	humanSolarFlarePower = 2

mob
	var
		tmp
			using_solar_flare
			last_solar_flare = 0
	proc
		TrySolarFlare()
			if(CanSolarFlare()) SolarFlare()

		CanSolarFlare()
			if(using_solar_flare || attacking || Disabled()) return
			if(world.time - last_solar_flare < 200) return
			return 1

		SolarFlare()
			set waitfor=0
			attacking = 2
			input_disabled++
			using_solar_flare = 1
			last_solar_flare = world.time
			Say("SOLAR FLARE!!!!")
			var/dist = GetSolarFlareRangeMod()
			var/list/mobs = GetSolarFlareAffectees(dist)
			SolarFlareFX(mobs, dist)
			SolarFlareAffectMobs(mobs, dist)
			AddKi(-1000)
			sleep(22)
			attacking = 0
			input_disabled--
			using_solar_flare = 0

		GetSolarFlareRangeMod()
			var/n = 1 * (Eff / 1.5)**0.7
			if(Race == "Human") n *= humanSolarFlareRange
			return sqrt(n) //because width x height its squared and it affects both

		GetSolarFlareAffectees(dist = 1)
			var/list/l = new
			for(var/mob/m in player_view(8 * dist,src))
				if(!m.client) continue
				l += m
			return l

		SolarFlareAffectMobs(list/mobs, dist = 1)
			set waitfor=0
			SolarFlareHurtVampires(mobs)

			//this adds the screen overlay to all affected players
			for(var/mob/m in mobs)
				if(!m.client || m == src) continue
				m << "<font color=yellow><font size=2>You are blinded by [src]'s Solar Flare!"
				m.SolarFlareScreenOverlay(src)

		SolarFlareScreenOverlay(mob/a) //a = attacker
			set waitfor=0
			var/sizeMod = 13
			var/obj/o = GetEffect()
			o.mouse_opacity = 0
			o.icon = 'solar flare.dmi'
			o.alpha = 0
			o.layer = 20
			CenterIcon(o)
			//o.pixel_x *= sizeMod
			//o.pixel_y *= sizeMod
			o.transform *= sizeMod
			var
				screenX = (ViewX - 1) / 2
				screenY = screenX / (16 / 9)
			o.screen_loc = "[screenX],[screenY]"
			client.screen += o
			animate(o, alpha = 255, time = 20, flags = ANIMATION_PARALLEL)
			var/timeMod = (regen / 1.6) ** 0.5
			if(a && a.Race == "Human") timeMod /= humanSolarFlareDuration
			sleep(65 / timeMod)
			animate(o, alpha = 0, time = 20 / timeMod)
			sleep(20 / timeMod)
			client.screen -= o
			del(o)

		SolarFlareFX(list/mobs, dist = 1)
			set waitfor=0
			var/obj/o = GetEffect()
			o.mouse_opacity = 0
			o.icon = 'solar flare.dmi'
			o.alpha = 0
			o.transform *= 0.01
			o.layer = 20
			CenterIcon(o)
			o.SafeTeleport(loc)

			animate(o, transform = matrix(transform) * 8 * dist, time = 5)
			animate(o, alpha = 255, time = 5, flags = ANIMATION_PARALLEL)
			sleep(30)
			animate(o, alpha = 0, time = 20)
			sleep(20)
			del(o)

		SolarFlareHurtVampires(list/mobs)
			set waitfor=0
			for(var/mob/m in mobs)
				if(!m.client) continue
				if(m.Vampire) m.SolarFlareHurtVampire(src)

		SolarFlareHurtVampire(mob/m) //m = attacker
			set waitfor=0
			if(!Vampire) return
			var
				dmg = 3
				loops = 15
			if(Vampire_Monster) dmg *= 2
			if(m.Race == "Human") dmg *= humanSolarFlarePower
			overlays += fireOverlay
			for(var/v in 1 to loops)
				TakeDamage(dmg)
				if(Health <= 0)
					Death(m)
				sleep(10)
			overlays -= fireOverlay