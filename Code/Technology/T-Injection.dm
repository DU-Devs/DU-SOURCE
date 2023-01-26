mob/var/Flyer

mob/proc
	Undo_all_t_injections()
		Apply_t_spider(1)
		Apply_t_scorpion(1)
		Apply_t_snake(1)
		Apply_t_recovery(1)
		Apply_t_regeneration(1)
		Apply_t_undying(1)

	Apply_t_injections(list/l)
		if(!l||!l.len) return
		for(var/v in l)
			switch(v)
				if("Spider") Apply_t_spider()
				if("Scorpion") Apply_t_scorpion()
				if("Snake") Apply_t_snake()
				if("Recovery") Apply_t_recovery()
				if("Regeneration") Apply_t_regeneration()
				if("Undying") Apply_t_undying()

	Apply_t_spider(remove=0)
		if(remove)
			if("Spider" in T_Injections)
				T_Injections-="Spider"
				Str -= 2
				Off -= 2
				Res -= -3
				Original_Decline/=0.9
				Decline/=0.9
		else
			if(!("Spider" in T_Injections))
				T_Injections+="Spider"
				Str += 2
				Off += 2
				Res += -3
				Original_Decline*=0.9
				Decline*=0.9

	Apply_t_scorpion(remove=0)
		if(remove)
			if("Scorpion" in T_Injections)
				T_Injections-="Scorpion"
				Off -= 2
				Def -= -2
				Original_Decline/=0.9
				Decline/=0.9
		else
			if(!("Scorpion" in T_Injections))
				T_Injections+="Scorpion"
				Off += 2
				Def += -2
				Original_Decline*=0.9
				Decline*=0.9

	Apply_t_snake(remove=0)
		if(remove)
			if("Snake" in T_Injections)
				T_Injections-="Snake"
				Spd -= 2
				Def -= 2
				Original_Decline/=0.9
				Decline/=0.9
		else
			if(!("Snake" in T_Injections))
				T_Injections+="Snake"
				Spd += 2
				Def += 2
				Original_Decline*=0.9
				Decline*=0.9

	Apply_t_recovery(remove=0)
		if(remove)
			if("Recovery" in T_Injections)
				T_Injections-="Recovery"
				recov/=2
				Ki/=0.5
				max_ki/=0.5
				Eff/=0.5
				Original_Decline/=0.8
				Decline/=0.8
		else
			if(!("Recovery" in T_Injections))
				T_Injections+="Recovery"
				recov*=2
				Ki*=0.5
				max_ki*=0.5
				Eff*=0.5
				Original_Decline*=0.8
				Decline*=0.8

	Apply_t_regeneration(remove=0)
		if(remove)
			if("Regeneration" in T_Injections)
				T_Injections-="Regeneration"
				regen /= 2
				Pow -= -3
				Original_Decline/=0.8
				Decline/=0.8
		else
			if(!("Regeneration" in T_Injections))
				T_Injections+="Regeneration"
				regen *= 2
				Pow += -3
				Original_Decline*=0.8
				Decline*=0.8
	Apply_t_undying(remove=0)
		if(remove)
			if("Undying" in T_Injections)
				T_Injections-="Undying"
				Regenerate -= 1.3
				Res -= -3
				Original_Decline/=0.8
				Decline/=0.8
		else
			if(!("Undying" in T_Injections))
				T_Injections+="Undying"
				Regenerate += 1.3
				Res += -3
				Original_Decline*=0.8
				Decline*=0.8
obj/items/T_Spider
	Stealable=1
	desc="x1.2 Strength. 1.2x Accuracy. /1.44 Resistance. Get the advantage and disadvantage of a spider! \
	Also gives a BP boost roughly worth 20 minutes of sparring."
	icon='Item, Needle.dmi'
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Use()
	verb/Use()
		var/mob/A=usr.get_inject()
		if(!A) return
		if(A.Redoing_Stats)
			usr<<"They must finish redoing their stats first"
			return
		if(A.Android)
			usr<<"This has no effect on androids"
			return
		if(!("Spider" in A.T_Injections))
			A.Apply_t_spider()
			player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"
obj/items/T_Scorpion
	Stealable=1
	desc="x1.2 Accuracy. /1.2 Reflex. Get the advantage and disadvantage of a scorpion! Also gives a BP boost \
	roughly worth 20 minutes of sparring."
	icon='Item, Needle.dmi'
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Use()
	verb/Use()
		var/mob/A=usr.get_inject()
		if(!A) return
		if(A.Redoing_Stats)
			usr<<"They must finish redoing their stats first"
			return
		if(!("Scorpion" in A.T_Injections))
			A.Apply_t_scorpion()
			player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"
obj/items/T_Snake
	Stealable=1
	desc="x1.2 Speed. /1.2 Reflex. Get the advantage and disadvantage of a snake! Also gives a BP boost roughly \
	worth 20 minutes of sparring."
	icon='Item, Needle.dmi'
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Use()
	verb/Use()
		var/mob/A=usr.get_inject()
		if(!A) return
		if(A.Redoing_Stats)
			usr<<"They must finish redoing their stats first"
			return
		if(!("Snake" in A.T_Injections))
			A.Apply_t_snake()
			player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"
obj/items/T_Recovery
	Stealable=1
	desc="Doubles recovery but halves energy."
	icon='Item, Needle.dmi'
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Use()
	verb/Use()
		var/mob/A=usr.get_inject()
		if(!A) return
		if(A.Redoing_Stats)
			usr<<"They must finish redoing their stats first"
			return
		if(A.Android)
			usr<<"This has no effect on androids"
			return
		if(!("Recovery" in A.T_Injections))
			A.Apply_t_recovery()
			player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"
obj/items/T_Regeneration
	Stealable=1
	desc="Doubles regeneration and divides force by 4 permanently making energy almost useless."
	icon='Item, Needle.dmi'
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Use()
	verb/Use()
		var/mob/A=usr.get_inject()
		if(!A) return
		if(A.Redoing_Stats)
			usr<<"They must finish redoing their stats first"
			return
		if(!("Regeneration" in A.T_Injections))
			A.Apply_t_regeneration()
			player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"
obj/items/T_Energy
	Stealable=1
	desc="Raises energy to a certain level if it is below that level."
	icon='Item, Needle.dmi'
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Use()
	verb/Use()
		var/mob/A=usr.get_inject()
		if(!A) return
		if(A.Redoing_Stats)
			usr<<"They must finish redoing their stats first"
			return
		if(A.max_ki<4000*A.Eff)
			A.max_ki=4000*A.Eff
			A.Original_Decline*=0.8
			A.Decline*=0.8
			player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A]'s energy is too high already to use this, it will do nothing for them"

obj/items/T_Undying
	Stealable=1
	desc="This will boost your death regeneration by 1.3 points (which is a lot), but result in a 25% loss of resistance."
	icon='Item, Needle.dmi'
	verb/Hotbar_use()
		set hidden=1
		Use()
	verb/Use()
		var/mob/A=usr.get_inject()
		if(!A) return
		if(A.Redoing_Stats)
			usr<<"They must finish redoing their stats first"
			return
		if(A.Android)
			usr<<"This has no effect on androids"
			return
		if(!("Undying" in A.T_Injections))
			A.Apply_t_undying()
			player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"
obj/items/T_Life
	Stealable=1
	desc="This will slow your decline IMMENSELY. Decreasing power loss by nearly 4x its normal amount. However, your decline age will be slightly earlier than before."
	icon='Item, Needle.dmi'
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Use()
	verb/Use(mob/A in view(1,usr)) if(A) if(A==usr||A.Frozen||A.KO)
		if(A.Redoing_Stats)
			usr<<"They must finish redoing their stats first"
			return
		if(A.Android)
			usr<<"This has no effect on androids"
			return
		if(!("Life" in A.T_Injections))
			A.T_Injections+="Life"
			A.Decline_Rate*=0.25
			A.Original_Decline*=0.8
			A.Decline*=0.8
			player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"
mob/var/list/T_Injections=new

obj/items/Antivirus
	icon='Antivirus.dmi'
	Stealable=1
	Level=1
	clonable = 0
	Cost=3000000

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Use()

	verb/Use()
		var/mob/A=usr.get_inject()
		if(!A) return
		player_view(15,usr)<<"[usr] uses the [src] on [A] and all infection disappears"
		del(src)

	verb/Synthesize()
		set src in view(1)
		var/list/L=list("Cancel")
		var/int_price_mod=0.4
		//if(usr.Res()>=10000000/usr.Intelligence()**int_price_mod) L[new/obj/Bio_Field_Generator]=10000000/usr.Intelligence()**int_price_mod
		if(usr.Res()>=2000000/usr.Intelligence()**int_price_mod) L[new/obj/items/T_Energy]=2000000/usr.Intelligence()**int_price_mod
		if(usr.Res()>=5000000/usr.Intelligence()**int_price_mod) L[new/obj/items/T_Undying]=5000000/usr.Intelligence()**int_price_mod
		if(usr.Res()>=3000000/usr.Intelligence()**int_price_mod) L[new/obj/items/T_Life]=3000000/usr.Intelligence()**int_price_mod
		if(usr.Res()>=5000000/usr.Intelligence()**int_price_mod) L[new/obj/items/T_Regeneration]=5000000/usr.Intelligence()**int_price_mod
		if(usr.Res()>=5000000/usr.Intelligence()**int_price_mod) L[new/obj/items/T_Recovery]=5000000/usr.Intelligence()**int_price_mod
		if(usr.Res()>=5000000/usr.Intelligence()**int_price_mod) L[new/obj/items/T_Snake]=5000000/usr.Intelligence()**int_price_mod
		if(usr.Res()>=5000000/usr.Intelligence()**int_price_mod) L[new/obj/items/T_Scorpion]=5000000/usr.Intelligence()**int_price_mod
		if(usr.Res()>=5000000/usr.Intelligence()**int_price_mod) L[new/obj/items/T_Spider]=5000000/usr.Intelligence()**int_price_mod

		if(L.len<=1)
			usr<<"You can not afford any of the options within this."
			return

		var/obj/O = input("You can synthesize and mutate this into many different uses. Choose one below. \
		NOTE: Only ones you can afford appear in this list") in L
		if(!O||O=="Cancel"||usr.Res()<L[O]) return
		switch(alert("[O] costs [Commas(L[O])] resources. Accept?","Options","Yes","No"))
			if("No") return
		if(usr.Res()<L[O])
			usr<<"You no longer have the resources needed"
			return
		usr.Alter_Res(-L[O])
		if(istype(O,/obj/items))
			var/obj/o=new O.type
			o.Move(usr)
		else O.SafeTeleport(usr.loc)