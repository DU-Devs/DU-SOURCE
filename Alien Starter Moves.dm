mob/proc/Alien_Stuff(Skills=3)
	if(!client) return
	var/list/Choices=list("Genius","Alien Transformation","Time Freeze","Limit Breaker","Absorb",\
	"Precognition","Death Regeneration",\
	"Attack Barrier","Death Ball","Give Power","Heal","Regeneration (Puran Style)","Self Destruct",\
	"Zanzoken","Split Form","Breath in Space")
	while(Skills)
		switch(input(src,"Now you get to choose [Skills] skills from this list") in Choices)
			if("Alien Transformation")
				Choices-="Alien Transformation"
				var/obj/Buff/B=new(src)
				B.teachable=0
				B.name="Alien Transform"
				B.desc="This is a transformation for aliens which increases their power but has some drain"
				B.buff_attributes+="transformation"
				var/icon/i='Aura Electric.dmi'+rgb(80,180,80)
				B.buff_overlays+=i
			if("Breath in Space")
				Choices-="Breath in Space"
				Lungs+=1
			if("Split Form")
				Choices-="Split Form"
				contents+=new/obj/SplitForm
				alert(src,"Splitform lets you create copies of yourself which you can give orders to and spar with.")
			if("Zanzoken")
				Choices-="Zanzoken"
				contents+=new/obj/Zanzoken
				alert(src,"An important but not very rare ability. It is necessary to do Zanzoken Combos. You can also \
				click a spot on the ground to Zanzoken to it.")
			if("Self Destruct")
				Choices-="Self Destruct"
				contents+=new/obj/Self_Destruct
				alert(src,"This is an extremely powerful and wide-range attack. It will kill you if you use it. If you \
				have Death Regeneration you will not die.")
			if("Regeneration (Puran Style)")
				Choices-="Regeneration (Puran Style)"
				contents+=new/obj/Regeneration
				alert(src,"When you activate this, you will trade energy for health. This will also gradually heal \
				injuries.")
			if("Heal")
				Choices-="Heal"
				contents+=new/obj/Heal
				alert(src,"This allows you to heal others using your health and energy.")
			if("Give Power")
				Choices-="Give Power"
				contents+=new/obj/Give_Power
				alert(src,"This ability lets you give your power to someone else temporarily. You will be knocked out \
				when you use it.")
			if("Death Ball")
				Choices-="Death Ball"
				contents+=new/obj/Attacks/Death_Ball
				alert(src,"Death Ball is based on Freeza's move, a big ball of energy will appear over your character, \
				and when you release it you can guide it to your target using the directional keys.")
			if("Attack Barrier")
				Choices-="Attack Barrier"
				contents+=new/obj/Attacks/Attack_Barrier
				alert(src,"Attack Barrier is a unique ki attack which fires many tiny blasts which swarm around you, \
				creating a sort of shield. If anyone gets to close to you the tiny blasts will attack them. The more you \
				master this skill the more tiny blasts will be created, and faster.")
			if("Genius")
				Choices-="Genius"
				Intelligence=0.8
				alert(src,"Genius increases your intelligence drastically, allowing for easier creation of technology.")
			if("Death Regeneration")
				Regenerate+=0.5
				alert(src,"Death Regeneration is like what Majin Buu and Cell had. If an attack 'kills' you, you will \
				regenerate from it after a certain amount of time. This makes you very hard to kill. Only someone who \
				uses a ki attack that is extremely powerful can kill you. You CAN stack this by choosing this skill \
				again. Stacking will increase the regeneration speed and also make it take an even more powerful blast \
				to kill you.")
			if("Time Freeze")
				Choices-="Time Freeze"
				contents+=new/obj/Attacks/Time_Freeze
				alert(src,"Time Freeze allows you to psychically paralyze everyone around you, as if they are frozen in \
				time.")
			if("Limit Breaker")
				Choices-="Limit Breaker"
				contents+=new/obj/Limit_Breaker
				alert(src,"Limit Breaker is an extremely powerful buff. Once you turn it on, your BP/stats will increase \
				dramatically. It's a gamble tho, because it only stays active for a random amount of time, and once \
				the time is up, you will be knocked out.")
			if("Absorb")
				Choices-="Absorb"
				contents+=new/obj/Absorb
				alert(src,"Absorb can be used to absorb knocked out people. Just face them and hit Absorb. Absorbing \
				someone will give you a power increase.")
			if("Precognition")
				Choices-="Precognition"
				Precognition=1
				alert(src,"This ability lets you psychically predict incoming blasts and automatically dodge them. \
				This ability takes energy for every blast you dodge. It is based on the Kanassa ability to predict the \
				future, in this case your character has predicted exactly when and where the enemy will fire the blast at \
				them.")
		Skills-=1