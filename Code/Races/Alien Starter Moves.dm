mob/proc/Auto_color_arm_stretch_icon()
	var/icon/i=new(icon)
	if(i)
		var/rgb=i.GetPixel(x=16,y=16,icon_state="",dir=SOUTH)
		if(rgb) arm_stretch_icon+=rgb

mob/var
	alien_zenkai = 0
	jirenAlien = 0

var
	jirenAlienBPMult = 1.8
	jirenAlienPowerupMult = 0.3
	jirenAlienKBresist = 0.5 //knockback resistance
	jirenTakeDmgMult = 0.6
	jirenAlienCanAnger = 0
	jirenStunResist = 2.5

mob/proc/Alien_Stuff()
	if(!client) return
	var/Starting_SP=round(15*SP_Multiplier**0.5)

	var/Starting_BP=round(Avg_Base*bp_mod)
	if(Starting_BP<6000) Starting_BP=6000 //aliens who choose this should start with more bp than an elite Yasai

	var
		elite_aliens = 0
		total_aliens = 0
	for(var/mob/m in players) if(m.client && m.Race == "Alien")
		if(m.Class == "Elite") elite_aliens++
		total_aliens++
	if(world.time > 5 * 60 * 10)
		if(!elite_aliens || (elite_aliens / total_aliens) * 100 < 4)
			Class = "Elite"
			hbtc_bp += Starting_BP
			alert(src, "You are an Elite Alien. This gives +[Starting_BP] BP (Nothing else)")

	var/Alien_points=100

	var/list/L=list(\
	"Done",\
	"Genius (25 AP)"=25,\
	"Alien transform (15 AP)"=15,\
	"Time freeze (25 AP)"=25,\
	"Limit breaker (15 AP)"=15,\
	"Absorb (20 AP)"=20,\
	"Precognition (25 AP)"=25,\
	"Death regeneration (25 AP)"=25,\
	"[Starting_SP] SP (10 AP)"=10,\
	"Zenkai (15 AP)"=15,\
	"2.5x BP from meditating (15 AP)"=15,\
	"Materialize (10 AP)"=10,\
	"5x skill mastery (12 AP)"=12,\
	"Breath in space (10 AP)"=10,\
	"Split form (10 AP)"=10,\
	//"Elite Alien +[Commas(Starting_BP)] BP (20 AP)"=20,
	"Stretchy arms (10 AP)"=10,\
	"Better blast homing (12 AP)"=12,\
	/*"Less bp loss from low ki (17 AP)"=17,\
	"Less bp loss from low health (10 AP)"=10,\*/
	"Giant Form (15 AP)" = 15,\
	"Imitate (8 AP)" = 8,\
	"Gyren Alien (50 AP)" = 50,\
	"Unlock Potential (25 AP)" = 25,\
	)

	retry

	while(src)
		var/choice=input(src,"Choose your alien skills. You have [Alien_points] alien points (AP) \
		remaining") in L
		if(Alien_points<L[choice])
			alert(src,"You do not have enough AP for this")
		else
			switch(choice)
				if("Done") return
				if("Unlock Potential (25 AP)")
					switch(alert(src, "Unlock Potential is a rare skill that lets you unlock hidden power built up from training in yourself and others", "Options", "Yes", "No"))
						if("No")
							goto retry
					contents += new/obj/Unlock_Potential
					Alien_points-=L[choice]
				if("Gyren Alien (50 AP)")
					switch(alert(src, "This attribute makes you very powerful but has downsides. You get [jirenAlienBPMult]x more BP, [1 / jirenAlienKBresist]x resistance to knockbacks, \
					and take [(1 - jirenTakeDmgMult) * 100]% less damage from all attacks. But your ability to use power up goes down [(1 - jirenAlienPowerupMult) * 100]%, \
					and you do not get a 2nd try from anger because all your power is in your regular form already.", "Options", "Yes", "No"))
						if("No")
							goto retry
					jirenAlien = 1
					Alien_points-=L[choice]
				if("Giant Form (15 AP)")
					switch(alert(src, "Use this to transform into a giant and have more power but some stat disadvantages", "Options", "Yes", "No"))
						if("No")
							goto retry
					contents+=new/obj/Giant_Form
					alert(src, "Giant Form is an ability you can use to grow really big and increase your BP and change your stats")
					Alien_points-=L[choice]
				if("Imitate (8 AP)")
					switch(alert(src, "Imitate allows you to near perfectly take on the name and appearance of any other player you want", "Options", "Yes", "No"))
						if("No")
							goto retry
					contents+=new/obj/Imitation
					Alien_points-=L[choice]
				if("Less bp loss from low ki (17 AP)")
					switch(alert(src, "", "Options", "Yes", "No"))
						if("No")
							goto retry
					bp_loss_from_low_ki/=2
					Alien_points-=L[choice]
				if("Less bp loss from low health (10 AP)")
					switch(alert(src, "", "Options", "Yes", "No"))
						if("No")
							goto retry
					bp_loss_from_low_hp/=2
					Alien_points-=L[choice]
				if("Better blast homing (12 AP)")
					switch(alert(src, "Your blasts will be able to home in on targets much better", "Options", "Yes", "No"))
						if("No")
							goto retry
					blast_homing_mod*=1.5
					Alien_points-=L[choice]
				if("Stretchy arms (10 AP)")
					switch(alert(src, "This allows you to press the Grab button (T) and if anything is in the direction you are facing, a stretchy arm will shoot out and grab it", "Options", "Yes", "No"))
						if("No")
							goto retry
					arm_stretch=1
					arm_stretch_icon='generic arm.dmi'
					arm_stretch_range=150
					Auto_color_arm_stretch_icon()
					Alien_points-=L[choice]
				if("Genius (25 AP)")
					switch(alert(src, "Technology you create is now much cheaper and better quality", "Options", "Yes", "No"))
						if("No")
							goto retry
					Intelligence=0.95
					Alien_points-=L[choice]
				if("Alien transform (15 AP)")
					switch(alert(src, "This gives you the ability to use a transformation that increases BP but drains energy", "Options", "Yes", "No"))
						if("No")
							goto retry
					var/obj/Buff/b=new(src)
					b.teachable=0
					b.name="Alien transform"
					b.desc="This is a transformation that increases BP but drains energy"
					b.buff_attributes+="transformation"
					var/icon/i='Aura Electric.dmi'+rgb(80,180,80)
					b.buff_overlays+=i
					Alien_points-=L[choice]
				if("Time freeze (25 AP)")
					switch(alert(src, "Time Freeze is an ability you can use to freeze everyone around you for a few seconds", "Options", "Yes", "No"))
						if("No")
							goto retry
					contents+=new/obj/Attacks/Time_Freeze
					Alien_points-=L[choice]
				if("Limit breaker (15 AP)")
					switch(alert(src, "This is an ability you can use that will greatly increase your stats and BP but it is a gamble because it could knock you out at any time. \
					It could last 10 seconds or 2 minutes.", "Options", "Yes", "No"))
						if("No")
							goto retry
					contents+=new/obj/Limit_Breaker
					Alien_points-=L[choice]
				if("Absorb (20 AP)")
					switch(alert(src, "You can absorb knocked out players with this and get some of their power", "Options", "Yes", "No"))
						if("No")
							goto retry
					contents+=new/obj/Absorb
					Alien_points-=L[choice]
				if("Precognition (25 AP)")
					switch(alert(src, "You can see slightly into the future which allows your character to automatically step out of the way of blasts, but it needs time to recharge", "Options", "Yes", "No"))
						if("No")
							goto retry
					precog=1
					Alien_points-=L[choice]
				if("Death regeneration (25 AP)")
					switch(alert(src, "If anyone tries to kill you, as long as the attack they killed you with wasn't strong enough, you will regenerate back to life like a Majin", "Options", "Yes", "No"))
						if("No")
							goto retry
					Regenerate+=0.5
					Alien_points-=L[choice]
				if("Zenkai (15 AP)")
					switch(alert(src, "Zenkai is the power Yasais have when they get knocked out or killed, they will sometimes grow stronger from it.", "Options", "Yes", "No"))
						if("No")
							goto retry
					zenkai_mod = 1
					alien_zenkai = 1
					Alien_points-=L[choice]
				if("2.5x BP from meditating (15 AP)")
					switch(alert(src, "", "Options", "Yes", "No"))
						if("No")
							goto retry
					med_mod*=2.5
					Alien_points-=L[choice]
				if("Materialize (10 AP)")
					switch(alert(src, "Materialize is a skill that allows you to create weights and swords from nothing", "Options", "Yes", "No"))
						if("No")
							goto retry
					contents+=new/obj/Materialization
					Alien_points-=L[choice]
				if("5x skill mastery (12 AP)")
					switch(alert(src, "", "Options", "Yes", "No"))
						if("No")
							goto retry
					mastery_mod*=5
					Alien_points-=L[choice]
				if("Breath in space (10 AP)")
					switch(alert(src, "Normally people die in space without an air mask. But not you.", "Options", "Yes", "No"))
						if("No")
							goto retry
					Lungs=1
					Alien_points-=L[choice]
				if("Split form (10 AP)")
					switch(alert(src, "Split Form is an ability to create copies of yourself to spar with or help you fight", "Options", "Yes", "No"))
						if("No")
							goto retry
					contents+=new/obj/SplitForm
					Alien_points-=L[choice]
			if(choice=="Elite Alien +[Commas(Starting_BP)] BP (20 AP)")
				hbtc_bp+=Starting_BP
			if(choice=="[Starting_SP] SP (10 AP)")
				Experience+=Starting_SP
			L-=choice