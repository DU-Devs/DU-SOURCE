proc/Switch_Bodies(mob/A,mob/P,save_override)
	if(!A.client) return
	var/Key1=A.key
	var/Key2
	if(P.client) Key2=P.key
	//switch imprisonments
	var/A_imprisonments=A.Imprisonments
	A.Imprisonments=P.Imprisonments
	P.Imprisonments=A_imprisonments

	var/list/a_curse=new
	var/list/p_curse=new
	for(var/obj/o in A) if(o.type==/obj/Prisoner_Mark || o.type==/obj/Curse) a_curse+=o
	for(var/obj/o in P) if(o.type==/obj/Prisoner_Mark || o.type==/obj/Curse) p_curse+=o
	for(var/obj/o in a_curse) o.loc=P
	for(var/obj/o in p_curse) o.loc=A
	//---
	var/view_x=A.ViewX
	var/view_y=A.ViewY
	A.ViewX=P.ViewX
	A.ViewY=P.ViewY
	P.ViewX=view_x
	P.ViewY=view_y
	P.Savable_NPC=1
	A.Savable_NPC=1
	P.FullHeal()
	A.FullHeal()
	P.logout_timer=0
	A.logout_timer=0
	P.Auto_Attack=0
	A.Auto_Attack=0
	players.Remove(A,P)
	var/profileA = A.charProfile
	var/profileB = P.charProfile
	if(!P.client) P.PrimaryPlayerLoop(Time.FromSeconds(10))
	var/mob/Temp=new
	if(Key2) Temp.key=Key2
	P.key=Key1
	if(Key2) A.key=Key2

	if(P&&P.client)
		P.charProfile = profileA
		P.client.show_verb_panel=1
		P.Savable_NPC=0
		P.Tabs=2
		P.LoadFeats()
		P.PopulateTraitsList()
		if(!(P in players)) players+=P
		if(!save_override)
			P.Savable=1
			P.Save()
		P.StuffThatRunsIfYouClickNewOrLoad()

	if(A&&A.client)
		A.charProfile = profileB
		P.client.show_verb_panel=1
		A.Savable_NPC=0
		A.Tabs=2
		A.LoadFeats()
		A.PopulateTraitsList()
		if(!(A in players)) players+=A
		if(!save_override)
			A.Savable=1
			A.Save()
		A.StuffThatRunsIfYouClickNewOrLoad()