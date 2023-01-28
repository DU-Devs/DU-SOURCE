mob/proc/Auto_color_arm_stretch_icon()
	var/icon/i=new(icon)
	if(i)
		var/rgb=i.GetPixel(x=16,y=16,icon_state="",dir=SOUTH)
		if(rgb) arm_stretch_icon+=rgb
mob/proc/Alien_Stuff()
	if(!client) return
	var/Starting_SP=round(15*SP_Multiplier**0.5)
	var/Starting_BP=round(Avg_Base*bp_mod)
	if(Starting_BP<3000) Starting_BP=3000
	var/Alien_points=100
	var/list/L=list("Done","Genius (25 AP)"=25,"Alien transform (20 AP)"=20,"Time freeze (25 AP)"=25,\
	"Limit breaker (15 AP)"=15,"Absorb (20 AP)"=20,"Precognition (25 AP)"=25,\
	"Death regeneration (25 AP)"=25,"[Starting_SP] SP (10 AP)"=10,\
	"1.3x more zenkai (15 AP)"=15,"Double BP from meditating (15 AP)"=15,"Materialize (10 AP)"=10,\
	"5x skill mastery (12 AP)"=12,"Breath in space (10 AP)"=10,"Split form (10 AP)"=10,\
	"+[Commas(Starting_BP)] starting BP (20 AP)"=20,"Stretchy arms (10 AP)"=10,\
	"Better blast homing (12 AP)"=12,"Less bp loss from low ki (17 AP)"=17,\
	"Less bp loss from low health (10 AP)"=10)
	while(src)
		var/choice=input(src,"Choose your alien skills. You have [Alien_points] alien points (AP) \
		remaining") in L
		if(Alien_points<L[choice])
			alert(src,"You do not have enough AP for this")
		else
			Alien_points-=L[choice]
			switch(choice)
				if("Done") return
				if("Less bp loss from low ki (17 AP)")
					bp_loss_from_low_ki/=2
				if("Less bp loss from low health (10 AP)")
					bp_loss_from_low_hp/=2
				if("Better blast homing (12 AP)")
					blast_homing_mod*=1.5
				if("Stretchy arms (10 AP)")
					arm_stretch=1
					arm_stretch_icon='generic arm.dmi'
					arm_stretch_range=150
					Auto_color_arm_stretch_icon()
				if("Genius (25 AP)") Intelligence=0.9
				if("Alien transform (20 AP)")
					var/obj/Buff/b=new(src)
					b.teachable=0
					b.name="Alien transform"
					b.desc="This is a transformation that increases BP but drains energy"
					b.buff_attributes+="transformation"
					var/icon/i='Aura Electric.dmi'+rgb(80,180,80)
					b.buff_overlays+=i
				if("Time freeze (25 AP)") contents+=new/obj/Attacks/Time_Freeze
				if("Limit breaker (15 AP)") contents+=new/obj/Limit_Breaker
				if("Absorb (20 AP)") contents+=new/obj/Absorb
				if("Precognition (25 AP)") precog=1
				if("Death regeneration (25 AP)") Regenerate+=0.5
				if("1.3x more zenkai (15 AP)") zenkai_mod*=1.3
				if("Double BP from meditating (15 AP)") med_mod*=2
				if("Materialize (10 AP)") contents+=new/obj/Materialization
				if("5x skill mastery (12 AP)") mastery_mod*=5
				if("Breath in space (10 AP)") Lungs=1
				if("Split form (10 AP)") contents+=new/obj/SplitForm
			if(choice=="+[Commas(Starting_BP)] starting BP (20 AP)") hbtc_bp+=Starting_BP
			if(choice=="[Starting_SP] SP (10 AP)") Experience+=Starting_SP
			L-=choice