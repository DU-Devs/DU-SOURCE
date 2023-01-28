mob/Admin5/verb/test_underlays()
	switch(input("what kind of test?") in list("basic","detailed"))
		if("basic")
			for(var/atom/a)
				if(a.underlays.len>=10)
					alert("[a] has [a.underlays.len] underlays")
		if("detailed")
			for(var/atom/a)
				if(a.underlays.len>=10)
					src<<"Next"
					for(var/image/i as anything in a.underlays)
						src<<"icon = [i.icon]. state = [i.icon_state]"
					alert("[a] has [a.underlays.len] underlays")

mob/Admin5/verb/test_overlays()
	switch(input("what kind of test?") in list("basic","detailed"))
		if("basic")
			for(var/atom/a)
				if(a.overlays.len>=10)
					alert("[a] has [a.overlays.len] overlays")
		if("detailed")
			for(var/atom/a)
				if(a.overlays.len>=10)
					src<<"Next"
					for(var/image/i as anything in a.overlays)
						src<<"icon = [i.icon]. state = [i.icon_state]"
					alert("[a] has [a.overlays.len] overlays")

//make cant build pods in battle they escape that way

//if people spam powerup and meditate in just the right way they make spam shockwaves that lag the server
//explosive bounce shurikens against walls on all sides of the char lag bad?

mob/proc/Input(mob/m,msg,title,default,_type,list/l)
	north=0
	south=0
	east=0
	west=0
	keys_down=new/list

	var/r

	switch(_type)
		if(null)
			r=input(m,msg,title,default) in l
		if("mob")
			r=input(m,msg,title,default) as mob in l
		if("obj")
			r=input(m,msg,title,default) as obj in l
		if("turf")
			r=input(m,msg,title,default) as turf in l
		if("area")
			r=input(m,msg,title,default) as mob in l

	return r


	//input(Usr=usr,Message,Title,Default) as Type in List



//make my own custom Input() and Alert() procs so that I can cancel out a mob's movement with them to fix the moving macro bug?

//make threaten to blow up planet actually work

//make dbs invis when inert indistinguishable from anything else

//add interactive tutorial

mob/var/tmp
	being_chased=0
	chaser_mob
var
	chase_start_dist=10

mob/proc/Opponent_move_slower_if_you_are_chasing_them()
	var/mob/m=last_mob_attacked
	if(m && ismob(m) && current_area==m.current_area && !m.KB && world.time-m.last_knockbacked>20)
		if(getdist(src,m)>=chase_start_dist)
			if(get_dir(src,m) in list(dir,turn(dir,45),turn(dir,-45)))
				m.being_chased=world.time
				m.chaser_mob=src

mob/proc/Being_chased()
	var/mob/c=chaser_mob
	if(c)
		if(getdist(src,c)>=chase_start_dist || world.time-being_chased<25)
			if(!(get_dir(src,c) in list(dir,turn(dir,45),turn(dir,-45))) || world.time-being_chased<10)
				if(world.time-being_chased<50) return 1
			else being_chased=0
		else being_chased=0





proc/To_tick_lag_multiple(n=1)
	if(n<=0) return 0
	var/rounded=round(n,world.tick_lag)
	if(rounded>n) rounded-=world.tick_lag
	var/decimals=n-rounded
	if(prob(decimals * 100 / world.tick_lag)) rounded+=world.tick_lag
	return rounded

proc/To_multiple_of_one(Delay=1)
	var/decimals=Delay-round(Delay)
	if(prob(decimals*100)) Delay++
	return round(Delay)

turf/Jagged_edge_fillers
	Buildable=0
	Wall18
		icon='JEF cliff.dmi'
		density=1
		_1
			icon_state="NE"
		_2
			icon_state="NW"
		_3
			icon_state="SW"
		_4
			icon_state="SE"
	Grass10
		icon='JEF green grass.dmi'
		Grass10_1
			icon_state="NE"
		Grass10_2
			icon_state="NW"
		Grass10_3
			icon_state="SW"
		Grass10_4
			icon_state="SE"
		_5
			icon_state="N"
		_6
			icon_state="S"
		_7
			icon_state="E"
		_8
			icon_state="W"


//MAKE THE NEW BP GAIN SYSTEM WHERE THE GAIN MOD DETERMINES HOW MANY TIMES THE LIMIT MULTIPLIES A DAY AND ALSO MAKE WHATEVER THAT IS ON
//IMPACT DRONE BP MULTIPLIER BECAUSE THEY WILL BECOME IRRELEVENT QUICKER IF BP IS EXPONENTIALLY RISING FASTER
//turrets and door hackers need to scale too
//make family lines matter more

/*
NOTE: animate() does not yield, any code below it will be executed immediately without waiting
*/

/*
mob/Move(NewLoc,Dir=0,step_x=0,step_y=0)
	var/old_step_x=step_x
	var/old_step_y=step_y
	var/old_loc=loc
	var/pixels_moved=..()
	Pixel_movement(Dir,pixels_moved)

atom/movable/proc/Pixel_movement(d,pixels_moved)
	if(!pixels_moved) return
	animate(src)
	Set_transform_at_previous_position(d,pixels_moved)
	Interpolate_pixel_step()

atom/movable/proc/Set_transform_at_previous_position(d,pixels_moved)
	var
		matrix/m=matrix(transform)
		X=0
		Y=0
	switch(d)
		if(NORTH) Y=-pixels_moved
		if(SOUTH) Y=pixels_moved
		if(EAST) X=-pixels_moved
		if(WEST) X=pixels_moved
		if(NORTHEAST)
			Y=-pixels_moved
			X=-pixels_moved
		if(SOUTHEAST)
			Y=pixels_moved
			X=-pixels_moved
		if(NORTHWEST)
			Y=-pixels_moved
			X=pixels_moved
		if(SOUTHWEST)
			Y=pixels_moved
			X=pixels_moved
	m.Translate(X,Y)
	transform=m

atom/movable/proc/Interpolate_pixel_step()
	var/matrix/m=matrix()
	//m.Translate(0,0)
	transform=m

	//animate(src,transform=null,time=3)
*/

/*
at the hell altar, give demons a list of demonic attributes they can select, such as weaknesses to one thing but strength in return
demon powers - some may come with downsides to balance out the advantages:
	turn to smoke, toxic?
	possession, cause people significantly weaaker than you to fight whoever you fight
	chaos magic
	demon absorbtion?
	arm spell, arms pop up under the ground following the target underground attempting to root them
	summoning spell
	a special demon-only attack? deals extra damage on evil people?
	demons deal extra damage on evil people regardless?
	drain energy - like give power but red and damages a person while restoring you - maybe only in hell
	imitate others
	poison attacks - poison melee?
	spew acid, lays a trail of acid on the ground anyone who touches it gets hurt except you
	also acid AoE attack
	feed off others anger
	control angry people - make them go berserk
	can cause bad luck
	can cause "apocalypses" of various kinds
		including weather alteration - acid rain - hurricane that blows objs everywhere if they hit you major kb and damage the wind can move you
			slowly
	fire attacks taht do the same damage to any enemy regardless of power
		fire breath
		fire AoE
	janemba teleport punch

make "father son kamehameha" beam assist thing, not fire the other persons beam, just send amessage that they are helping and
strengthen that beam, making it much more powerful

a way to play the game like batman, more tech like that, stealth tech etc. smoke bombs. traps

make power up and power down toggles. press G to pwoer up, press G again to stop. press H to start powering down. press H again to stop

fix the bug where people grab beamer they cant do nothin

fix kaioken to transform after x20

what if your character lunges into their attacks and offense and/or speed impacts the homing which is based on where the opponent was and not
is, how far it lags behind depends on the offense/speed

if you attack someone within 4 seconds of ITing to them, apply a debuff against that person which decreases damage by like 15%

make the hair graying and declining system more calibrated

lewis thinks theres a pack stacking bug cuz sarutopi had 13 auto ss and 13 omega kb etc. and it kept saying LOGIN: mob (God Like You)

add deployable force field trap mines which can function as little mini prisons it takes like the strongest person 1 minute to break out,
someone half their power takes like 8 minutes, etc. repairable. upgradable. can be sent straight to jail from it wihtout KO, can turn it on
and off from the outside only. explosion cant harm someone in it, no attack can. set turf to is_forcefield_trap=1 they cant leave
that turf. in blast move check if the new loc's var changed if so delete the blast cuz it can not cross in or out, but also do
damage to the field. do for melee too. and explosion. and set all teleport moves to check that and set accordingly. make the trap
completely unmovable while active.

if you have a lv2 and lv1 robo tool on you you can get lv2 ugprade for lv1 cost

doors are now easier to break than walls?

make clicking tab toggle focus between the input and map

save window positions?

make explosion can 1 hit kill

make sure 1 hit kills are possible with the strong ki attacks and bypass anger

we can use last cave entered time for the fear system probably

dragging people out of tournament now lets them win again

diarea rare death your dead body shoots a rocket stream of shit out of it propeling it into the nearest obstacle and it explodes

add pixel movement where the fastest person moves 32 and it gets slower from there maybe the slowest person is 16

vegito wants cant open sense tab of someone who is hiding power because bug lets you open sense tab of someone with cyber bp even if
they hide power

people are bypassing the give power vulnerability by only giving power in short bursts then stopping before you can hit them for the
high damage

vampire cure should work thru blood bags

turn explosion to double click, and regular click zanzokens after like sleep(2)
	or should zanzo be the double click?

rework drones to be more expensive but more profitable but the same in combat ability or maybe less in teams
	maybe higher rebuild chance but less combat effectiveness but close in faster towards a target after being rebuilt
make drones rebuild if they end up in the core. make them avoid entering the core with the cave entry system.

add auto open sense tab of whoever attacking you
	maybe not a tab, but something else. interface map overlay?

Saru has weaker resistance than durability and 0 defense, he uses a 1.5x energy sword, his offense is 12,000

exgen wants wall break power to be supported on modded

BUG: people put drone ai on themself then use dash attack after ordering themselves to attack someone and it gives them a perfectly
homing dash attack, people shouldn't be able to install drone ai on themself

overdrive needs to use get_bp() to refresh as soon as it turns on
nanite repair refills health even with overdrive active

when someone destroys android scraps the android doesnt die they just stay in FR

mob/Move is now massively laggy

put a thing that keeps track of what the highest player count was on that day

ran a lag check on drones, its all pretty much drone_step, and the fact that they punch every wall they bump into for no good reason
drone_step uses 30 self cpu and 65 total cpu

drones seem to get stuck attacking a KO'd person. i had them set to patrol, they attacked defensively only.  and they would keep attacking the
KO'd person even at the checkpoint spawn where dead people spawn
it should have at least been lethal but i dont think they were set to lethal

the spar gains checker still doesnt work right, i checked it for consistency against punching bags and pbags actually gave significantly more than
split sparring
i noticed on pbags at least that if your afk over like 20 seconds your gains drop to about half

to do multiplier stacking on strength:
	Sword, Custom Buff, T-Spider, T-Snake, T-Scorpion, Brute
if we nerf the multiplier stacking we can make the scaling better for damage,
also you can stack strength far higher than force making force inferior

to buff defense:
	make it so you can escape knockbacks by clicking attack to zanzoken back to your opponent
	make it so you can reverse a strangle and do a counter attack that does lots of damage
	make side stepping viable and defense based probably with more knockback than usual

WHEN DROIDS DIE SEND THEM TO CYBERSPACE MAP AND THEY MUST PAY RESOURCES OUT OF A BANK TO REBUILD THEM, OTHERS CAN PAY TO REBUILD THEM TOO

drones when ordered to enter ship should only do so while the ship remains in getdist(15) so if the ship moves to another map they dont endlessly follow

lewis wants a var on bluprints to prevent resetting
turrents are firing thru walls
make turrets respect robotics tools
rename all drones option
make demon vampires get hungry far less etc
make meditate deactivate overdrive for convenience
make drones not try to break INF walls they stuck there pointlessly - and dont break owner's walls
mind swapping leaves the person with no hotkeys
make androids cant use revive altar etc, instead they must pay to be rebuilt
giant module need to use transform scale
BUG: you can move and wait on kai teleport at the same time making it easy to run away
BUG: blast absorb abosrbs turret bullets
make bans not start timing down til the person sees the ban
new decline gain system
make door keys biometric
make splits more intuitive for battle
replace learn with a nice menu to just click what you want out of it? and only things that you have enough SP for appear
buff taiyoken
make entering pod more intuitive when you enter it ask if you want to launch. if you click pod it also ask and give options
	bumping a pod should give option to enter it
	press fly to exit
let bios regress  to larval form
make can grab while medding
make refuel spacepod streamlined by just having it auto refill 100% or none at all
when spacepod runs out of fuel with you in it, have it ask if you want to refuel
make door hacker take like 3 seconds to actually let you  go thru the wall
make 1 hour in between planets blowing up

advanced freeza npc

PLANET VEGETA FITNESS:
	add boom box
	and disco dance party
	FBI guy at front desk sk if u want cheese pizza u say yes and 12 fbi guys swarm u and u go to jail but its easy to break out of this jail

make fruits work differently and replace them with tree of might

make good people have +5% durability on earth or something so it draws aall good to earth

a new purpose for speed, target reaction time, with low speed the changes raise that your character will sleep(1) before actually
hitting a target that has appeared in front of them, the faster opponent will NOT sleep(1), therefore gets the hit in before their
slower counterpart.

make a system where people can load different chars from the same key

people can move while spin blasting making a huge volley of blasts that go wherever they walk its a bug

rename doesnt work now that i changed it?

people can go mystic ssj4 if they use mystic while golden oozaru

give all demons soul contract since nobody plays them?

make evil people cant see the crystal on they own heads

fixx the cave diving faggotry during fights

IMPORTANT: when people steal from someone it seems to swap all their macros. might happen when you drop an item too

upgrade regenerator to de-age?

fix powering up with auto attack on it shouldnt kb people from powerup

peple who SD dont drop DBS when item drop toggle off

make can use ussj in ssj2? 3? 4??

jewel drop on death even if drops toggled off

every dragon ball should be a adventure, a feat, and achievement, a story, not just laying around

give evil a way to get ssj besides death anger that is competitive with the ease of death anger for good

why does era reset destroy banked items? only destroy the ones that arent era immune

double anger bug: get energy to 0% with sheild to get anger from that then you'll get anger again when your health reaches 0% from whoever
youre fighting

offline gains might be the source of the insane bp spikes because it uses the average and stuff and if few people are on but theyre strong
and you log on maybe you get insane multplier

make dead evil people spawn in hell?

find out how people are teleporting out of beam struggle stun

make lethal back on if was on before tourny

REALLY BAD BP BUG:
power down to 1% with 3x anger
get angered
then activate transform buff
it'll multiply your bp by like 300x

SUPPOSED BUG:
wish for power in hbtc gives insane bp

make how capped your knowledge is influence prices?

make built turfs not regenerate in ship_area

if you spam t heal you start automatically getting injuries?

FIX FEAR

*/














//put auction system onto bank

//make shield immune to being grabbed
//maybe bumping someone who is shielding makes you be knocked away
//maybe you cant move when sheidling
//cant activate sheild if currently are grabbed

//bug: majins cant regain untapped potential...ever

//make good can not heal evil!!!

//reconsider the full heals of anger, people can abuse it by running around getting angered by a diff person to refill health

//fear applies to wrong person and sometimes doesnt apply to anyone at all i think its cuz it doesnt see the person as having the opponent

//i lose villain even tho i dont have teh rank somehow still

//let bios revert to imperfect form whenever they want

//era resets occur on blank android bodies and stuff as soon as you enter them

//use that new transform scaling thing to make spirit bomb bigger, instead of the current way

//if a player is climbing a cliff (going north and hitting dense turfs) then slow their movement

//reduce player loops - a good way to do so is ctrl+H find all while()s - and remember npcs have a lot of loops too

//banks player made?

//you cant initiate stealing on a logged out body

//what if clicking an object brings up a list of all available verbs you can use on it

//the game can detect evil people. evil actions:
//giving an evil person power who is fighting someone good
//good and evil have same extrapolated enemy and the evil person binds/kills/absorbs etc that person then the good person is marked for helping
//once there is good auto detection remove mark as evil

//make radar updating different where there is a global list and it creates an associative entry for that type of object the radar if detecting
//then creates a list of area names within that then in those area names it will store a list of every object of that type and the radar
//stat tab will loop thru that instead of recreating its own radar list on the player every time, and if the object changes areas it will
//remove it from the list and place it in the correct one, but we only need to check that every 10 seconds max

//make gravity more lethal on pvp mode

//a guy bug abused in tournament where he got anger then i hadnt gotten anger yet and he just sat there powering up while i was weakened and
//waited on the match to end where he won due to having more health. make it so if the match times out and there is a person who didnt get
//anger yet they win regardless of health

//make jail altar will unbind you but will turn you into a Baneling or some such thing where zombies will spawn around you and not attack you
//for 1 hour

//make so can click many things in inventory to use them such as fruits senzus

//make jail guards and you can break free of jail if you kill them all but maybe no one person by themself can do it

//cyborgs can be sensed for some reason

//if highest base bp saved and restored itself on reboots then the problem with era reset would be fixed

//create wrapper functions for built in byond functions

//expand checkpoint - less clouds, more land

//beam stun doesnt work

//make a mode where you only get 3 random races you can be and to get more you must wish for them

//ship interriors switch to diff ships each reboot

//make npc freeza and npc hitler

//stabilize Avg_BP I saw it go from 70 mil to 700 mil

//maybe instead of having offline gains use the strongest person it is some amalgamation or average of many players instead of just the best
//because that saps all that person's training and makes it worthless
//but if we do that we have to make offline gains only apply like 5 minutes after a reboot or something

//change zombie behavior to seek land if they are stuck out at sea
//and have them desire to be in a hoarde if they are all by themself
//make zombies cant attack when grabbed
//nukes need to be 100% effective against zombies - aka stop missing them
//zombies seem to never get up from KO? rather than get KO'd in the first place they should just die

//add splitform attack verb which spawns up to 3 splits and they attack whoever you are
//androids can go under 0 regen/recov by first spending 2 points then taking them out of regen/recov
//make race choosing menu
//allow changing directions whil doing shockwave
//allow WASD movement by adding movement obj proxies and adding LEFT/UP/DOWN/RIGHT slots to the hotkey menu
//when someone goes super saiyan for the first time make it a planet wide event with graphical effects everywhere and goku's ssj theme plays
//redo play music so nobody can stop your music but they can cancel it for themself and there is an option to not hear other's music at all
//i think when both fighters log out it bugs the tournament
//make allow keep bank thru wipe
//bug: if you turn on regenerate then install auto repair you become unkillable except for 1 shots?
//give majins the ability to insta absorb anyone less tahn half their power by sending a peice of themself
//enable flash step but perhaps changed
//fix fear. it actually doesnt seem to inflict fear on anyone any more, is it off?
//namek db bug treat z2 as home make it use area only
//saibaman race
//change unlock potential to not be a leech off anyone else but rather either give a certain multiple of static bp or as a person trains
//they build up unlockable BP. maybe half saiyans start out with like 5000 unlockable BP
//exgen goes from 900 mil to 8 bil bp on kaioken x5 because he meds in kaioken constantly. change how kaioken bp capping works

//add option to auto open sense tab of anyone you hit, prob who your opponent is

//make legendary saiyans occasionally go insane and kill everyone around them but only in pvp mode

//let people keep modules on death?

//let people set their drones to let league members bypass ilelgal activity

//make villain league retain itself offline by setting a var in the league obj villain_league=1 and members will continue having the
//benefits but they diminish the longer the villain is offline

var/era_resets=0
var/era_bp_division=1
var/era_target_bp=7500
var/highest_era_bp=0

mob/var/era=0

obj/var/era_reset_immune=1

mob/Admin4/verb/Reset_bp_to_early_levels()
	if(!highest_era_bp)
		alert("Wait for loading to complete")
		return
	switch(alert(src,"This will reset everyone's BP to early levels and remove super saiyan and all that stuff","Options","Yes","No"))
		if("Yes")
			Log(src,"[key] reset BP to early levels")
			Era_reset()

proc/Era_reset()

	Wipe_bug_logs()
	Save_Bugs()

	destroyed_planets=new/list
	for(var/obj/Egg/e)
		e.loc=null //leftover eggs hatching makes people OP?
		del(e)

	era_resets++
	//banked_items=new/list

	for(var/k in banked_items)
		var/list/l=banked_items[k]
		if(l)
			for(var/obj/o in l)
				if(!o.era_reset_immune)
					l-=o
					o.loc=null
				if(istype(o,/obj/items/Android_Blueprint)&&o:Body)
					var/obj/items/Android_Blueprint/ab=o
					var/obj/b=ab.Body
					if(ismob(ab.Body)||(isobj(ab.Body)&&!b.era_reset_immune))
						l-=o
						o.loc=null
			banked_items[k]=l

	era_bp_division=highest_era_bp/era_target_bp
	Tech_BP/=era_bp_division
	if(Tech_BP<100) Tech_BP=100

	for(var/turf/t in Turfs) t.Health/=era_bp_division
	for(var/obj/Turfs/Door/d in Built_Objs) d.Health/=era_bp_division
	for(var/obj/o) if(o.z && !o.era_reset_immune) o.loc=null

	for(var/mob/m in players)
		m.Revert()
		m.Save()
	player_saving_on=0

	SaveWorld(save_map=1,allow_auto_reboot=0,delete_pending_objs=0)

	sleep(5)

	fdel("ItemSave")
	fdel("Bodies")
	fdel("NPCs")

	world.Reboot()

mob/Admin5/verb/Era_reset_test_information()
	src<<"Era bp division: [era_bp_division]<br>\
	Era resets: [era_resets]<br>\
	Highest base: [Commas(highest_base_and_hbtc_bp)] ([highest_base_and_hbtc_bp_mob])"

mob/proc/Check_era_reset()
	if(era<era_resets||era>era_resets) //if era>era_resets you must be bugged or something so just reset

		if(Is_Tens()) src<<"Era resetting"

		era=era_resets

		for(var/obj/Mate/m in src)
			del(m)
			contents+=new/obj/Mate

		for(var/obj/items/i in src)
			if(!i.era_reset_immune)
				item_list-=i
				del(i)
			if(istype(i,/obj/items/Android_Blueprint)&&i:Body)
				var/obj/items/Android_Blueprint/ab=i
				var/obj/b=ab.Body
				if(ismob(ab.Body)||(isobj(ab.Body)&&!b.era_reset_immune))
					item_list-=i
					del(i)

		for(var/obj/Contract_Soul/cs in src)
			cs.Max_BP=1
			del(cs)

		Revert()
		if(Class=="Legendary Saiyan") ssjadd=10000
		offline_gains_info=0
		offline_int_gains_info=0
		base_bp /= era_bp_division / bp_mod * Get_race_starting_bp_mod() / 2 //divided by 2 beacuse base+hbtc can be twice the target bp
		hbtc_bp /= era_bp_division / bp_mod * Get_race_starting_bp_mod() / 2
		cyber_bp/=era_bp_division / 2
		kaioken_boost/=era_bp_division / 2
		Zombie_Power/=era_bp_division / 2
		Knowledge/=era_bp_division
		highest_bp_ever_had=1
		bp_mod=Get_race_starting_bp_mod()
		SSjAble=0
		SSj2Able=0
		SSj3Able=0
		SSj4Able=0
		ssj_inspired=0
		Restore_Youth=0
		Former_Vampire=0 //remove the cured blood
		BP=1

		//remove this block it is to fix a bug when era reset was first added and i had to spam era resets to get it to work
		if(base_bp<500) base_bp=500
		if(base_bp>era_target_bp) base_bp=era_target_bp
		if(hbtc_bp>era_target_bp) hbtc_bp=era_target_bp
		if(cyber_bp>era_target_bp) cyber_bp=era_target_bp
		if(kaioken_boost>era_target_bp) kaioken_boost=era_target_bp
		if(Zombie_Power>era_target_bp) Zombie_Power=era_target_bp

		if(Str>20000)
			Str/=10
			End/=10
			Spd/=10
			Pow/=10
			Res/=10
			Off/=10
			Def/=10

		if(Class=="Elite") hbtc_bp+=4000

		src<<"<font color=green><font size=4>An 'era reset' has occurred, this means your BP has been reset. This was probably player voted."

		if(Is_Tens()) src<<"returning 1"

		return 1
	else if(Is_Tens()) src<<"no era reset for you"



















mob/var/hotbar_proxies_added

mob/proc/Add_hotbar_proxies()
	//if(key=="Tens of DU") src<<"Add_hotbar_proxies"
	if(hotbar_proxies_added==4) return
	contents.Add(new/obj/Manual_Attack,new/obj/Train,new/obj/Meditate,new/obj/Power_Up,new/obj/Power_Down,new/obj/Grab,\
	new/obj/Local_chat,new/obj/World_chat,new/obj/Emote,new/obj/Countdown,new/obj/Learn,new/obj/Teach,new/obj/Injure,\
	new/obj/Lethal_toggle,new/obj/Dig_for_resources,new/obj/Use_object,new/obj/Play_Music)
	hotbar_proxies_added=4

obj/Use_object
	hotbar_type="Other"
	can_hotbar=1
	verb/Hotbar_use()
		set hidden=1
		if(!usr||!usr.client) return
		var/list/usables=new
		for(var/obj/o in view(1,usr))
			if(text2path("[o.type]/verb/Use") in o.verbs)
				usables+=o
		for(var/obj/o in usr.item_list)
			if(text2path("[o.type]/verb/Use") in o.verbs)
				usables+=o
		if(isobj(usr.loc))
			var/obj/o=usr.loc
			if(text2path("[o.type]/verb/Use") in o.verbs)
				usables+=o
		var/obj/o=input("Which object do you want to use?") in usables as obj|null
		if(!o||o=="Cancel"||!isobj(o)) return
		o:Use()

obj/Play_Music
	hotbar_type="Other"
	can_hotbar=1
	verb/Hotbar_use()
		set hidden=1
		usr.Play_Music()

obj/Injure
	hotbar_type="Melee"
	can_hotbar=1
	verb/Hotbar_use()
		set hidden=1
		usr.Injure()

obj/Lethal_toggle
	hotbar_type="Other"
	can_hotbar=1
	verb/Hotbar_use()
		set hidden=1
		usr.Ki_Toggle()

obj/Dig_for_resources
	hotbar_type="Other"
	can_hotbar=1
	verb/Hotbar_use()
		set hidden=1
		usr.Dig()

obj/Local_chat
	hotbar_type="Other"
	can_hotbar=1
	verb/Hotbar_use()
		set hidden=1
		usr.Say()

obj/World_chat
	hotbar_type="Other"
	can_hotbar=1
	verb/Hotbar_use()
		set hidden=1
		usr.OOC()

obj/Emote
	hotbar_type="Other"
	can_hotbar=1
	verb/Hotbar_use()
		set hidden=1
		usr.Emote()

obj/Countdown
	hotbar_type="Other"
	can_hotbar=1
	verb/Hotbar_use()
		set hidden=1
		usr.Countdown()

obj/Learn
	hotbar_type="Ability"
	can_hotbar=1
	verb/Hotbar_use()
		set hidden=1
		usr.Learn()

obj/Teach
	hotbar_type="Ability"
	can_hotbar=1
	verb/Hotbar_use()
		set hidden=1
		usr.Teach()

obj/Grab
	hotbar_type="Melee"
	can_hotbar=1
	verb/Hotbar_use()
		set hidden=1
		usr.Grab()

obj/Manual_Attack
	hotbar_type="Melee"
	can_hotbar=1
	verb/Hotbar_use()
		set hidden=1
		usr.Melee()

obj/Train
	hotbar_type="Training method"
	can_hotbar=1
	verb/Hotbar_use()
		set hidden=1
		usr.Train()

obj/Meditate
	hotbar_type="Training method"
	can_hotbar=1
	verb/Hotbar_use()
		set hidden=1
		usr.Meditate()

obj/Power_Up
	hotbar_type="Buff"
	can_hotbar=1
	verb/Hotbar_use()
		set hidden=1
		if(!usr.powerup_obj)
			usr<<"You have not yet learned this ability"
			return
		usr.Power_up()

obj/Power_Down
	hotbar_type="Buff"
	can_hotbar=1
	verb/Hotbar_use()
		set hidden=1
		if(!usr.powerup_obj)
			usr<<"You have not yet learned this ability"
			return
		usr.powerup_obj.Power_Down()

//client/control_freak=CONTROL_FREAK_MACROS

obj/Attacks
	hotbar_type="Blast"
	can_hotbar=1
obj/items
	hotbar_type="Item"
	can_hotbar=1

obj/var
	can_hotbar
	hotbar_type="Melee"
	hotbar_id //used for saving and restoring the hotbar from a savefile and re-assigning appropriate objects by ID

mob/var/tmp/list
	hotbar=new //every object the player has on the hot bar
	hotbar_ids=new //a savable list of IDs which can be used to restore the hotbar upon loading

var/list/hotbar_types=list("Melee","Blast","Beam","Buff","Defensive","Support","Ability","Transformation",\
"Combat item","Training method","Item","Other","Empty")

var/list/hotbar_type_icons

mob/proc/Get_hotbar_obj_by_key_pressed(kp)
	if(key=="Tens of DU") src<<"Get_hotbar_obj_by_key_pressed"
	var/index=0
	for(var/k in keys)
		index++
		if(k==kp) break
	if(hotbar.len<index) return
	var/obj/o=hotbar[index]
	return o

mob/proc/Get_hotbar_ability_key(obj/o)
	if(key=="Tens of DU") src<<"Get_hotbar_ability_key"
	var/index=0
	for(var/o2 in hotbar)
		index++
		if(isobj(o2)&&o2==o) break
	if(keys.len<index) return
	return keys[index]

proc/Get_hotbar_type_icon(t)
	if(!hotbar_type_icons) Generate_hotbar_type_icons()
	for(var/obj/o in hotbar_type_icons) if(o.name==t) return o

obj/hotbar_type_icon

proc/Generate_hotbar_type_icons()
	hotbar_type_icons=new/list
	for(var/t in hotbar_types)
		var/obj/hotbar_type_icon/o=new
		o.name=t
		switch(t)
			if("Empty") o.icon='Empty hotbar icon.dmi'
			if("Melee") o.icon='melee.jpg'
			if("Blast") o.icon='blast.jpg'
			if("Beam") o.icon='beam.jpg'
			if("Buff") o.icon='buff.jpg'
			if("Defensive") o.icon='defensive.jpg'
			if("Support") o.icon='support.jpg'
			if("Other") o.icon='other.jpg'
			if("Ability") o.icon='ability.jpg'
			if("Transformation") o.icon='transformation.jpg'
			if("Combat item") o.icon='combat item.jpg'
			if("Training method") o.icon='training.png'
			if("Item") o.icon='item.jpg'
		hotbar_type_icons+=o

proc/Grid_pos_to_list_pos(gp)
	var/comma_pos=findtext(gp,",")
	if(comma_pos) gp=copytext(gp,comma_pos+1,length(gp)+1)
	return gp

client/MouseDrop(obj/src_object,over_object,src_location,over_location,src_control,over_control,params)
	if(mob&&isobj(src_object)&&over_location&&over_control=="hotbar.key_grid")

		//what was dragged is only an icon representing an object, so get the actual object from it
		if(istype(src_object,/obj/hotbar_type_icon))
			var/list_pos=Grid_pos_to_list_pos(src_location)
			list_pos=text2num(list_pos)
			if(mob.hotbar_objects.len>=list_pos)
				src_object=mob.hotbar_objects[list_pos]

		if(src_object.loc==mob&&src_object.can_hotbar)
			if(key=="Tens of DU") src<<"MouseDrop"
			var/list_pos=Grid_pos_to_list_pos(over_location)
			list_pos=text2num(list_pos)
			if(mob.hotbar.len<list_pos) mob.hotbar.len=list_pos

			mob.hotbar[list_pos]=src_object
			src_object.hotbar_id=Assign_hotbar_ID()
			mob.Register_hotbar_ID(src_object.type,src_object.hotbar_id,list_pos)

			mob.Refresh_hotbar_key_grid()

proc/Assign_hotbar_ID()
	return "[rand(1,999999999)]"

mob/proc/Register_hotbar_ID(t,i,hotbar_pos=1)
	if(key=="Tens of DU") src<<"Register_hotbar_ID"
	if(istext(hotbar_pos)) hotbar_pos=text2num(hotbar_pos)
	if(isnum(i)) i=num2text(i)
	for(var/id in hotbar_ids) if(istext(id))
		var/list/id_info=hotbar_ids[id]
		if(id_info["hotbar position"]==hotbar_pos)
			hotbar_ids-=id
	hotbar_ids[i]=list("hotbar position"=hotbar_pos,"object type"=t)

//this fixes a bug with the original system. should be able to be removed after a while
mob/proc/Hotbar_IDs_valid()
	//if(key=="Tens of DU") src<<"Hotbar_IDs_valid"
	//if(!hotbar_ids.len) return
	if(istext(hotbar_ids))
		src<<"HOTBAR INFORMATION INVALID. RESETTING"
		return
	for(var/v in hotbar_ids) if(istext(v))
		var/list/l=hotbar_ids[v]
		if(!("hotbar position" in l))
			src<<"HOTBAR INFORMATION INVALID. RESETTING"
			return
		if(!("object type" in l))
			src<<"HOTBAR INFORMATION INVALID. RESETTING"
			return
	return 1

mob/verb/Delete_hotbar()
	set hidden=1
	set name=".Delete_hotbar"
	if(key=="Tens of DU") src<<"Delete_hotbar"
	hotbar=new/list
	hotbar_ids=new/list
	Refresh_hotbar_grids()

mob/var/starter_hotbar_generated

mob/verb/Restore_starter_hotbar()
	set hidden=1
	set name=".Restore_starter_hotbar"
	hotbar_ids=new/list
	starter_hotbar_generated=0
	Generate_starter_hotbar()
	Refresh_hotbar_grids()

mob/proc/Generate_starter_hotbar()
	if(key=="Tens of DU") src<<"Generate_starter_hotbar"
	if(hotbar_ids.len) return
	if(starter_hotbar_generated) return
	starter_hotbar_generated=1
	hotbar=new/list
	hotbar_ids=new/list
	var/index=0
	for(var/k in keys)
		index++
		var/object_type
		switch(k)
			if("C") object_type=/obj/Use_object
			if("A") object_type=/obj/Attacks/Shockwave
			if("S") object_type=/obj/Attacks/Beam
			if("D") object_type=/obj/Attacks/Charge
			if("F") object_type=/obj/Attacks/Blast
			if("G") object_type=/obj/Power_Up
			if("H") object_type=/obj/Power_Down
			if("Q") object_type=/obj/Train
			if("W") object_type=/obj/Meditate
			if("E") object_type=/obj/Shadow_Spar
			if("R") object_type=/obj/Fly
			if("T") object_type=/obj/Grab
			if("Space") object_type=/obj/Manual_Attack
			if("B") object_type=/obj/World_chat
			if("V") object_type=/obj/Local_chat
			if("N") object_type=/obj/Emote
			if("X") object_type=/obj/Learn
			if("Z") object_type=/obj/Teach
			if("U") object_type=/obj/Dig_for_resources
			if("I") object_type=/obj/Injure
			if("O") object_type=/obj/Lethal_toggle
			if("Y") object_type=/obj/Auto_Attack
		if(object_type)
			Register_hotbar_ID(object_type,Assign_hotbar_ID(),index)
	Restore_hotbar_from_IDs()

mob/proc/Restore_hotbar_from_IDs()

	if(!client) return

	if(key=="Tens of DU") src<<"Restore_hotbar_from_IDs"

	if(!Hotbar_IDs_valid())
		hotbar=new/list
		hotbar_ids=new/list

	if(!hotbar_ids.len&&Has_hotkey_server_backup())
		src<<"ERROR: Loading hotkeys from backup stored on server. Report this error please."
		Hotkey_server_backup_load()

	hotbar=new/list

	var/list/hotbarrables=new
	for(var/obj/o in src) if(o.can_hotbar) hotbarrables+=o

	for(var/id in hotbar_ids) if(istext(id))

		var/obj_found
		var/list/hotbar_id_info=hotbar_ids[id]
		var/list_pos=hotbar_id_info["hotbar position"]
		var/obj_type=hotbar_id_info["object type"]

		for(var/obj/o in hotbarrables) if(o.hotbar_id==id)
			obj_found=1
			if(hotbar.len<list_pos) hotbar.len=list_pos
			hotbar[list_pos]=o
			break

		if(!obj_found) for(var/obj/o in hotbarrables) if(o.type==obj_type)
			if(!(o in hotbar))
				o.hotbar_id=Assign_hotbar_ID()
				hotbar_ids-=id
				Register_hotbar_ID(o.type,o.hotbar_id,list_pos)
				if(hotbar.len<list_pos) hotbar.len=list_pos
				hotbar[list_pos]=o
				break

	Refresh_hotbar_grids()

mob/proc/Refresh_hotbar_grids()
	if(key=="Tens of DU") src<<"Refresh_hotbar_grids"
	if(!client) return
	if(winget(src,"hotbar","is-visible")!="true") return
	Refresh_hotbar_ability_grid()
	Refresh_hotbar_key_grid()

mob/var/tmp/list/hotbar_objects

mob/proc/Refresh_hotbar_ability_grid()
	if(key=="Tens of DU") src<<"Refresh_hotbar_ability_grid"

	if(!client) return

	if(winget(src,"hotbar","is-visible")!="true") return
	hotbar_objects=new/list
	for(var/obj/o in src) if(o.can_hotbar) hotbar_objects+=o
	hotbar_objects=Sort_hotbar_objects(hotbar_objects)
	winset(src,"hotbar.ability_grid","cells=2x[hotbar_objects.len]")
	var/cell=1
	for(var/obj/o in hotbar_objects)

		winset(src,"hotbar.ability_grid","current-cell=1,[cell]")
		src<<output(Get_hotbar_type_icon(o.hotbar_type),"hotbar.ability_grid")

		winset(src,"hotbar.ability_grid","current-cell=2,[cell]")
		src<<output(o,"hotbar.ability_grid")

		cell++

var/list/keys=list("Space","0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R",\
"S","T","U","V","W","X","Y","Z")

var/list/hotbar_letter_icons

proc/Generate_hotbar_letter_icons()
	hotbar_letter_icons=new/list
	for(var/k in keys)
		var/obj/key_icon=new
		key_icon.icon=Get_hotbar_letter_icon(k)
		key_icon.name=k
		hotbar_letter_icons+=key_icon

proc/Get_hotbar_letter_obj(k)
	if(!hotbar_letter_icons) Generate_hotbar_letter_icons()
	for(var/obj/o in hotbar_letter_icons) if(o.name==k) return o

proc/Get_hotbar_letter_icon(k)
	switch(k)
		if("Space") return 'Spacebar hotbar icon.jpg'
		if("0") return '0 hotbar icon.jpg'
		if("1") return '1 hotbar icon.jpg'
		if("2") return '2 hotbar icon.jpg'
		if("3") return '3 hotbar icon.jpg'
		if("4") return '4 hotbar icon.jpg'
		if("5") return '5 hotbar icon.jpg'
		if("6") return '6 hotbar icon.jpg'
		if("7") return '7 hotbar icon.jpg'
		if("8") return '8 hotbar icon.jpg'
		if("9") return '9 hotbar icon.jpg'
		if("A") return 'A hotbar icon.jpg'
		if("B") return 'B hotbar icon.jpg'
		if("C") return 'C hotbar icon.jpg'
		if("D") return 'D hotbar icon.jpg'
		if("E") return 'E hotbar icon.jpg'
		if("F") return 'F hotbar icon.jpg'
		if("G") return 'G hotbar icon.jpg'
		if("H") return 'H hotbar icon.jpg'
		if("I") return 'I hotbar icon.jpg'
		if("J") return 'J hotbar icon.jpg'
		if("K") return 'K hotbar icon.jpg'
		if("L") return 'L hotbar icon.jpg'
		if("M") return 'M hotbar icon.jpg'
		if("N") return 'N hotbar icon.jpg'
		if("O") return 'O hotbar icon.jpg'
		if("P") return 'P hotbar icon.jpg'
		if("Q") return 'Q hotbar icon.jpg'
		if("R") return 'R hotbar icon.jpg'
		if("S") return 'S hotbar icon.jpg'
		if("T") return 'T hotbar icon.jpg'
		if("U") return 'U hotbar icon.jpg'
		if("V") return 'V hotbar icon.jpg'
		if("W") return 'W hotbar icon.jpg'
		if("X") return 'X hotbar icon.jpg'
		if("Y") return 'Y hotbar icon.jpg'
		if("Z") return 'Z hotbar icon.jpg'

mob/proc/Refresh_hotbar_key_grid()
	if(key=="Tens of DU") src<<"Refresh_hotbar_key_grid"

	if(!client) return

	if(winget(src,"hotbar","is-visible")!="true") return
	winset(src,"hotbar.key_grid","cells=3x[keys.len]")
	var/cell=1
	for(var/k in keys)

		winset(src,"hotbar.key_grid","current-cell=1,[cell]")
		src<<output(Get_hotbar_letter_obj(k),"hotbar.key_grid")

		winset(src,"hotbar.key_grid","current-cell=2,[cell]")
		src<<output(Get_hotbar_type_icon("Empty"),"hotbar.key_grid")

		winset(src,"hotbar.key_grid","current-cell=3,[cell]")
		src<<output("Nothing","hotbar.key_grid")

		cell++
	cell=1
	for(var/v in hotbar)
		if(isobj(v))
			var/obj/o=v
			if(o.loc==src)

				winset(src,"hotbar.key_grid","current-cell=2,[cell]")
				src<<output(Get_hotbar_type_icon(o.hotbar_type),"hotbar.key_grid")

				winset(src,"hotbar.key_grid","current-cell=3,[cell]")
				src<<output(o.name,"hotbar.key_grid")

			else hotbar[cell]=null
		cell++

proc/Sort_hotbar_objects(list/original_list)
	if(!original_list.len) return original_list
	var/list/sorted_list=new
	for(var/t in hotbar_types)
		for(var/obj/o in original_list) if(o.hotbar_type==t)
			sorted_list+=o
			original_list-=o
	return sorted_list

mob/verb/Show_hotbar_grid()
	set hidden=1
	if(key=="Tens of DU") src<<"Show_hotbar_grid"
	if(!client) return
	Remove_Duplicate_Moves()
	winset(src,"hotbar","is-visible=true")
	Restore_hotbar_from_IDs()
	Refresh_hotbar_grids()

mob/verb/Hide_hotbar_grid()
	set hidden=1
	set name=".Hide_hotbar_grid"
	if(key=="Tens of DU") src<<"Hide_hotbar_grid"
	if(!client) return
	winset(src,"hotbar.ability_grid","cells=0x0") //clear the grid
	winset(src,"hotbar.key_grid","cells=0x0")
	winset(src,"hotbar","is-visible=false")
	save_player_settings()
/*
exgen says npcs drop hbtc keys even if its off

is there a way to stop abusing death anger for ssj and make it more legit to get it?

make drones not go thru cave/entrances if their target theyre moving towards is on the same map as them
because players intentionally position themselves to mislead the drone into an exit and save themselves

make toggle that prevents all building near a cave/entrance

make kienzan/sokidan safer to use by making it go around the user as long it the collision occurs in the frontal arc of the user

when you mind swap you cant see ooc/say

make leeching faster in jail for prisoners

fix sonic bomb in tourny

give androids 0 melee energy drain because they have shit recov and stuff

add exit to core but when someone comes thru it it disappears for 3 minutes so you cant exit thru it til then

Good people need a tool to enforce ORDER. There are tons of things to produce chaos and evil. Something that can protect an entire planet
from evil, so good can live in peace.
	Preferably something NON-TECHNOLOGICAL, that involves fighting
		maybe just a way for Good people to ally with themselves on a deeper level

people spam reincarnate prompt in combat

make base guardians which are far cheaper than drones and will ward off tresspassers

(Telepathy)the admin guy: (The main problem with Guns is, 10 Refire, 5 Explosion and you can crash servers.)
Telepathy)the admin guy: (Spread Fire + 10 Refire = 30 shots a second. 5 Explosion makes 5 radius explosions per shot.)

fix dust jumping around and spazzing

make able to command drones to kill only evil or good people

does auto attack not work properly if both fighters are moving a lot? maybe make melee() activate every move if auto attack is on

when storing nukes in a bank set the nuke loc to the bank so it can be detonated from there

teleport null doesnt work if the player gets in a ship, people are abusing this bug

ok tests reveal that when all mobs are deleted the ram goes from 730 mb to 330 mb so they account for majority of memory, probably
due to some giant references and huge lists on them
stop storing npc items on them and generate them upon death based on npc type
reduce npc total count
then without the map, memory usage drops to 23 mb
so lets set the map size to 400x400, and compact some tiny maps together

re-delete the "edges" and "surf" objects from the maps to bring the total object count at runtime from 46k to 13k to help with garbage
collection being so slow because it has a squared effect because every time an object deletes it has to check every other object for
references to itself and replace them with null

i think player logs stored on a var in the mob is one reason mobs take so much memory

cache diarea so it can be used again

make people have to be a multiple of average bp to blow up terrain, it prob lessens memory some

new module: ambient absorb. absorb ambient aura energy if someone within 1 tile of you is powering up, possibly actually draining their power
making powering up against this kind of android useless

make new stuff only appear in science if you learn how to make that specific item, AND, you can forget that item to clear space in the
science tab so it isnt so junky








ssj jenny says hair 43's ssj3 icon is broke and sucks

admin verb to start at the % of the strongest players BP

kiting system doesnt seem to work

if you are attacking someone who is running from you then a 3rd person comes in and attacks you then the person
running from you escapes, they dont get fear because you are attacking someone else now.

if you dont attack the person you are supposedly teaming for 30 seconds you should no longer
be considered a teamer
if YOU become KO or die, you are no longer a teamer, or a kiter, or fearful or is_runner

make changes to turf strength update all walls based on the new value

exgen says bug:  If you attempt to use Redo Stats on a packager, it semi-passes packs. To the point that, if the packager who was redone by the non packager uses AI Training, it will make the non packager run the AI Train loop

explosion destroys turrets in like 1 hit and also i think they are using explosion + spacepod or somethign so
turrets dont harm them

mob/Del still the biggest source of lag prob from players loggging so perhaps keep  their chars cached

ship interiors switch each reboot?

give makyos a planet and let them spawn there and its makyo star 24/7

make drones not genocide people in hell who are dead + binded

make dbs invis when inactive

make a system where i can lower everyone and every save's bp divided by whatever i want so its sort of
like a wipe but not

remove giant form + oozaru

senzu pots? maybe just 1 senzu pot on korin's tower and if anyone wants beans they gotta get them there

more ship interiors

make decline work so that you only lose power while logged on so that if you log out a long time you dont leave
with 1000 bp and come back with 500

core demons are bugged they dont realy move and are weak

11k bp alien with 44k force beat my 18k bp 23k resist saiyan in under 10 seconds using god damned stun blast
kiting
	kiting like that should classify them as runners or something, or a kiter debuff
		like have a var called kite_count and for every amount you zanzoken away it gets +1 and the higher it is
		past 2 the more debuffed you become

apply zenkai with every injury, and injury healed

a modeul that makes ki attacks not drain at all for androids?

nmake android no can use powerup

make it so being in the same league like both being good so they cant kill etc

dbs allowing inf wishes now?

make can use moon in contents it auto drops

make it so when you redo stats from genetics comp you can put regen/recov to 1x

make it so people in fear can not get angry and they lose any current anger boost

saibaman pets

rage is now useless cuz anger is always 100%, but what if it makes you angry 2 minutes instead of 1?

3 ooc channels with ability to see/talk in all channels if desired

finish threaten

instead of claim bounties from computer, bounty robot pay you directly

also only the person who sent the guy to jail should be able to claim a bounty

make giant form handle overlays better
and let you change the icon of it

give nameks special better blast deflection

tournament owner should be able to stop tournaments from happening

can shoot makosen thru walls?

cache meteors
Senzu_Grow lags remove it and use a global loop that makes a new one at a steady rate
	add beans to senzu_list
Attack_Gain_Loop lags, instead of having it run all the time, only run it when Opponent is set, and make all
	sets to Opponent use set_opponent
update_radar_loop is really laggy now
EMP_mine_loop really laggy now

instead of generating tons of senzu objects, just use a number for how many there are, and they are grown in pots
and the number increases representing how many are in there. and you can withdraw them.

if you grab someone who is charging a beam it bugs them

maybe the further you go into the hbtc the more intense it is

maybe only 2people at once can enter hbtc

make cyborgs and alts not draw down the knowledge cap make it only consider the strongest alt

i think drone deleting only lags if a person has been in their body
when i make drones that have not had anyone been in there body they dont lag when they die
it could be their buffs deleting
or only if someone with packs gets in the body

add a list of people that drones will not attack because theyre special or something

if a person logs out without making a character instead of letting their mob delete just keep it for if they
reconnect. make sure its not in the players list

somehow make area/Enter work so that each area can have an obj_list where each object type is stored
associatively by its initial(name)

make space mask auto equip/unequip upon entering/exiting space and add the overlay back

redoing stats after being hurt then relogging makes a clone of you?

UP should grant 5% more hbtc bp guaranteed up to +5 million

add leader following to npc respawning so there is like a 80% chance they follow whoever they spawn from

fix play music so people cant cancel your music and if someon near you palyed music in the last 60 sec you
cant override theirs

for drill shares we could just make the most expensive drill get 80% of the resources and 20% distributed among the
reamining drills

armor attribute: spiked armor. if people strangle you they take lots of damage in return
	maybe they take damage by hitting you too

Feats system?

give swords heaviness, sleakness, fluidity, sharpness

make drones have to bind death regeners or absorb instead of insta kill

drones go thru walls/doors when they shouldnt?

drones can perma stay in transform buff attribute

make can hack drones to reprogram to your freqency for free if you have a door hacker

when drones steal from you make sure the other drones patrolling at you know that you have complied and dont just
attack you cuz 1 drone got the res first

let drones jail people especially if theyre dead and need to be killed but theyre already dead

ability to add people who are immune to drone laws

drones spam overdrive because of drone_attack being repeatedly overwritten and called again

drones can use overdrive now but i forgot to actually activate the overdrive loop on them??

an advanced combat module for drones that basicly just makes them side step their enemy

declare android scraps illegal

technology that alerts you when a door or wall gets destroyed

drones are flying over doors
	are doors even actually dense?

make scrap repair work on drones too

rename buffs to fighting styles
new buff attribute to do more melee damage by punching harder than you safely can thus damaging yourself too

bring back drill shares because now it doesnt matter if someone has monopoly over planet resources there are other
ways to make a decent living
	a drill's share could be its value ^ 0.2 compared to every other drill's value ^ 2
		not only does this limit the effectiveness of packs but also gives the little guy a little chance to catch up
			with a new drill

if i move current_area updating to area/Enter() also move check_if_on_destroyed_planet there too so
people cant stay on destroyed planets

auto wall upgraders upgrade ever rand(1,3) hours

radar detect bodies

on earth in a pod you get attacked by cached npcs
sense should only show mobs that have a loc that way cached npcs dont show

update rsc values on players more

sort radar entries by distance

a wish to destroy all technology and make new technology unmakeable til someone undoes it
 aka, wish that electricity doesnt exist?

add non-vampire option to drone genocide
	and an unidentified drone option

make drones able to patrol thru warps

ordering all drones to self destruct lags badly
	so cache android scraps

core demons / shitbeasts / zombies deleting are causing a lot of lag with mob/Del()
	actually i think a lot of it is g_step mobs!

something is wrong with zombie mutating sometimes there will be 300 regular zombies with not a single mutated one

hokuto sucks balls

make player view / etc use true loc so pepoe in pods get msg

add bp soft cap system

pods get stuck on any dense obj

explosive blasts destroy items dropped by npcs they kill

auto wall upgraders. upgrades every 2 hours to 90% of the tech cap

db wishes to change laws of physics and the universe
	wish for whores to be better
	wish for balanced to be better
		3 levels only. low, medium, high. choose between them.

cars still destroy caves

bug: nano repair only repairs to 50% health

bug: when you body sweap someone they lose all their items and stuff but their money is kept

bank account hacking - maybe after someone hacks a bank account the bank auto upgrades itself so it cant be double
hacked - and when hacking you can only hack 1 account

lssj insanity like oozaru goes berserk
	maybe the higher you power up the less control of yourself you have
	you have to obey the voices in your head of you'll have an aneurism and die
	insanity develops over a lssj's life time...% chance per year maybe

shield dash. just like dash attack but with a shield that deals ki damage instead
	perhaps it is different than dash attack as you can move in any direction freely and it auto travels at
	high speed, leaves no after image, and goes til you toggle it off, but drains an amount of ki every step
	you take, and is weaker because you can go around inflicting multiple hits

perhaps like majins androids do not train and have the ability to digitally scan what makes someone powerful and
replicate it for themself

remove the % ki drain of dash attack but add a cooldown

make it so you join tournaments thru the settings button

check time to next tournament in server info

a type of shield where as long as you dont move it will repel a person from getting close to you when they punch it

add secrets to the game that the dragon will tell you if you wish

make jewel unbankaeleble

add pokeballs and pokemon as pets and you gotta catch em all

dragon race - every time someone wishes they get power too?

radars could probably update faster if they are inserted into an area's list in area/Enter

a dungeon where portals for it spawn randomly like those random resources do and when you go into it its a maze
like series of rooms with a challenge each harder than the last but with greater rewards each time especially
resources

stat bug:
	KO zombie
	take zombie dna
	stat imprint from zombie dna
	OP stats 100x the cap sometimes
may have to get in thanatos dead body or cloned body

a new method of training called active meditation where you go to the astral plane and fight with no risk of dying
but slower leeching and a power more equalized to your opponents?

occasionally the oldest zombies should die off to allow the rest to propagate on other planets

maybe make dead zone an actual makyo technique. and give them a makyo planet where they are really strong there
AND they need to be able to become huge like garlic does, their own special technique

replace as many of the view()<<'s as possible with player_view()
<<sound

give admins option to disable banks

50cent showed me a picture of like 200 core demons on his screen at once

asteroids still aren't cached and are showing as the #1 lag source
followed by wall upgrading despite the 30 second wait

fix stretch arm get in base bug

people use super weak alts to use give pwoer and get a ton of BP but BP should factor into how much you get when
people give you power

when u take npc body and relog u log back in with the same bp but a 1 bp mod, and many npcs got more than 1,
idk if this always or just sometimes happens tho

loops that can be triggered as needed:

sword possible attributes
	heavy: attack refire suffers, damage increased
	sharpness: like it already is, sharper it is the more they dodge it but it does more damage
	maybe swords make you dodge worse since you cant block as good as you could using martial arts you have to block
		with the sword

what if you could make different sides of your body more protected than others, like front, back, and sides
protection. it could be part of a fighting style.

supposedly if you wish for power you get more based on if you power up really high and supposedly give power too

turrets go thru walls

icer forms dont get vamp boost

could make offline gains only apply to people who stayed offline a loooong time and missed a lot. like 18 hours
offline

zenkai recharge faster but full power zenkai weaker

The wait time on wall upgrading and all the lag from it could be gone if we just use an associative list to put the
turfs in based on the key of the person who made it. And, save each person's built things to a separate save file.
	remove set background=1 from the wall upgrading procs and remove the sleeps when i do this

separate AL and LW more. make energy regenerator not work for dead people in LW, also give power not work. live people
cant stay in AL. kai / demon only stay alive in AL

how long you stay dead depends how strong you are compared to the strongest person so if your really weak you can
come back in like 5 minutes!

separate AL and LW tournaments if Earth destroy no LW tournament

improve armor to use a point system that you can decrease energy, speed, and defense to increase protection factor,
and the option to spread that protection across durability only, resistance only, or both.

db wish undo all radiation

bug: can people be SC teleported while in a spacepod and KO'd?
Gun5 says its SC kill, that it summons them to the person who killed them instead of sending to checkpoint

make door hackers able to retrieve passwords from things and give Naoya credit

fix pod landing locs

make so moving cancels nav destination

2 flying people fly thru each other

holy pendant spend more time dead in living world?

a way for players to check the time til the next tournament
also whether it is a skill or regular

make body swap expire because some people use it to trap others in their body forever

look into doing pixel movement with the slowest person having a step size of like 12 and the fastest 32

make some npcs can shoot projectiles. stands still for a few seconds after. spider shoots venom for
example.
	bandits shoot guns
		give bandits overlays like trolls

a needle that you inject and gives you a temporary power boost but afterwards you die and some
potential is hidden

viewers has shown that it is about 25-33% faster than view

sokidan is bugged it hits you and deflects if you shoot it downwards

with dynamic npc respawn locations make each npc have a 30% chance to spawn next to another npc
of its own type, that way, saibaman can travel in packs, and stuff
	and, npcs will only spawn on the same type of turf they initially spawned on.

tree of might seed
	spawns on jungle
	also in science

grab someone who beaming they cant struggle

figure out some way to make nukes have bigger range. a better way to loop thru turfs

launch nukes in missile form
	can send to randomly picked coordinates for thermonuclear apocalypse scenario

redo turrets with the concept of repelling people away from the base
	perhaps other tech that repels?

turret blasts need to cache its laggy

become death claw

get attacked, use redo stats, log off, it makes a clone of you, you can get inf stuff

make cnat take dna if you body swap someone

grab door, put it on bank, nobody can use bank or destroy door

grab someone who charging beam they cant move

make 2 sets of shurikens, macro each, fire 2x fast

orbital cannons just dont seem to work

people abuse SC kill to summon them to the demon because it bypasses telenulls

make brain transplant switch soul contracts

splitforms are too fragile

make holy pendant protect you against soul contract

telenull item does not work
rebuild doesnt work

bank transfers

people abuse kaioken to break walls because:
	if you have death regen you can spam it to max then break the wall right before you die
	you can go to max near the well
	or if your dead cuz it doesnt matter if you re-die

turrets are totally useless if someone has a force field. force field should not block physical damage

SC needs some sort of danger or risk right now its risk free instant power
maybe something like how a vampire has to bite people

a wish to make every item cost way way more for like 5 hours

warp gate system where players pay to go somewhere and a player owns it and makes money from it

let alien choose reproduction method

in prison if you try to break a wall or fight someone the guards stop you. fighting them is like
survival training and gives good gains. start prison riots for training
	a player can make money by joining the guards and beating the fuck out of prisoners

force field doesnt protect agianst SD

meteors aren't cached yet

dead people at checkpoint spam kaioken for INF bp because they just die and be restored over and over

what if there is a way to opt-in to a tier ladder system in the normal wipe?

a way to gain power thru a "feats" system, maybe a dungeon where each room has a boss stronger than the
last. defeat it and your power is raised to a % of the strongest person's online
PERFECT IDEA: Pendulum room, lets you fight dbz villains, from King Piccolo, Frieza, Raditz, etc

1 nuke makes the game from 25% to 165% cpu. there has got to be a better way
	for nuke damage, instead of per tile checking, have the nuke activate a loop on all mobs in the area
	it was detonated on, which will check damage for a minute or two before stopping
		so when a turf is nuked put a timestamp on it and it is radioactive and will damage anyone standing
		on it
			put an overlay on it to signify it is radioactive

bug: apparently when you disconnect your beam objs stay behind

lag:
	#1 = beam()
	#2 = mob/Del() from players mass killing npcs
	everything else was way lower than those two

things to fuck with people:
	when you get KO'd with a sword there is a 1% chance to accidently stab your self and die
	car randomly runs over you
	aliens abduct you
	aids
	cancer

make leagues have a forced overlay like for example a blue cape and remove overlays even cant get rid
of it

re-add wing chun dummies but to prevent that bug abuse make it keep a reference of the last mob who hit
it

Phantom Cr: So yeah basically the bugg i found is if you remake your stats with the gen
comp and that you had modules that would /2 your recov regen or any stats wel once you actualyl
 remade you still ahve them equipped and thus your stats just doubled
  and once you remove the module your stats goes crazy high

give popo rank a special ability
	pendulum room

for every attack there should be a defensive tactic available if one knows how to use it. perhaps like
using physics to counter.
defensive/counter tactic ideas:
	spam blasting
		shooting a beam sucks all the blasts into the beam and redirects them at the enemy?
		shockwave reverses the direction of blasts? and you can spam it?

make it cost like an extra 8 mil resources to detect dragon balls

and BP altering should perhaps be hbtc bp

make the server spawn a shikon jewel at the start of a wipe. no admins involved
and if the shikon jewel hasnt been online in over 24 hours it is deleted from the save and a new
one is made

make destroyed turfs repair themself again but this time do it in a non-laggy way, like all destroyed
turfs added to a list to be repaired to their initial type but it only will repair 1 every 3 seconds
or something

make dragon balls have normal pixel x/y til you drop them all in the same spot

if you fly into a regen it wont work
check out the regen code in mob/move

1 bp bug fixed for skill tourny but sitll happens for regular, i think only if dead?

you can shoot blast or shockwave to get out of beam stun?

i think knockbacking a troll who is beaming/charging a beam bugs them now that knockbacks cancel beams

automatically restore planets that have been destroyed for 3 hours

what if there were some purpose to family names and bloodlines.

bug: npcs have no stats. far below cap

you can get inside any base by using a friend, shoot an extendo arm at them as they zanzoken to the other
side of the base, the extendo arm will go thru the walls and grab them, pull them into the base then
you let go while they are inside

db wishes:
	wish for scare
	wish for everyone shit themself
	wish for core demons to spawn and attack everyone
	wish for more npcs to spawn
	wish for less npcs to spawn
	wish planets have more gravity
	wishes to change the importance/value of a certain stat
	invert power, where low bp is good and high bp is bad

FUSION:
	after the graphics make a shockwave that knocks everyone away

wall breaker tricks:
	steroids, 3x anger, lb, give power, powerup + beam, regenerator
roid_power = 1.75x
3x anger = 2.41x
LB = +0.5 bp mult

admin command to prevent ssj

make a new way to come back to life at the altar by sacrificing another player there. they can not be
an alt, and must have good power. dont forget to add it to the guide. the altar CHOOSES who it wants you
to sacrifice, to prevent abuse.

maybe demon altar will revive demons for no cost but theres like a 2 hour wait in between

perhaps a heaven altar, where you can be revived if you dedicate yourself to the service of good
somehow. how about it means you can not kill anyone else who is a warrior of heaven, but anyone
not in it is considered automatically evil. and, you do more damage against vampires and demons!

new heaven altar choice: you can get revived by helping the weak. perhaps by unlocking or reviving
5 weak people. perhaps to prevent abuse, the altar CHOOSES who you must help, and how, randomly

you can get revived if you choose to be binded to a single planet for some reason, and if you leave you
just die

apparently all death regeners have a bug where they go to their spawn upon regenerating instead of
where they died??

new method of faggotry: make spacepod mid fight to escape because spacepods are the fastest moving things
so maybe make it so you cant make technology if you were damaged in the last minute?

BUG:
	if you grab someone charging a beam they can not struggle
	you can still sokidan when grabbed
	when you relog with a radar equipped the radar tab doesnt show unless you reequip it
	pods going to like 10k% health again
	you can flash step while charging big bang apparently
		attack barrier too?

make people stop beaming when their match ends

meditate is no longer stopping powering up for some reason, really annoying

i think repetitively sparring the same person should have its limits when it comes to gains, switching
up every once in a while would provide more
perhaps with KB on would provide more gains too
so that you could forge your character's power thru real combat

AIDs

a doctor npc that randomly roams around and if he gets next to you he tests you for cancer and
you always have it lol

maybe the prison takes 20% of the bounty so even if your the one who placed it and claim it you do
so at a loss. the 20% goes to prison owner

all valuables a person has on them upon being imprisoned should be auto scrapped

the prison owner gets all the money

the game should auto place bounties on some people

there should be incentive to be an actual bounty hunter somehow

prisoners should be incapable of breaking walls

prison owner should be able to free people at will










npcs need to respawn in random places

add that reverse engineer system

scrappable hbtc keys?

look into making a global Take_damage() proc

bio fields in core big problem

rage still insta heals with no cooldown at all

makosen is the new most laggy thing when it is used and calls Beam() like a million times

make flash step only target the last person you hit?

precog needs nerf, or some sort of cost for using?

alien stats OP?

make android upgrade go higher upon ssj era?

cache for re-use instead of deleting:
	dust
	craters
	body parts
	npcs

	meteors
	resource bags
	bodies
	core demons
	bounty drones
	senzus!!

Player_Loops() (2 self, 100 total)

make precog work on dash attack and extendo arm

knockback resistance mods for races?
and knockback hit mod for like lssj knock people further back than normal each hit

Four Star can not be revived because they were revived less than 60 minutes ago. They must wait another
21504 minutes and 24 seconds to be revived again by the revive skill

check error logs

genki dama is the most laggiest thing when someone is using it, by 7x. maybe the new transform
system can be used to scale it instead?

you can beam while hundred crack fisting someone its a bug

use ctrl F to look up all for() loops in the game and cache them all

SLEEP obviously is one of the biggest causes of lag in this game, and it isn't logged in the cpu
profiler, so procs that use long sleeps when they are inactive, maybe need to be changed so that the
entire proc itself is not even running or waiting and is only activated when needed when triggered
	and, its obviously mostly the sleeping procs that run on the players, that is why they really need
	to only run if triggered

some of the things in Beam() seem like they only need to happen once per move in beam_move_loop rather
than 10 times per second. For example deflecting the beam only needs checked per move I believe.

use ctrl F to look up "in src" and see if any of the results can be cached

make pods can bump other players and damage the player but also itself

hokuto sucks

add diagonal movement to holding 2 arrow keys down

add something to do in prison. like vegeta's core for example, a special active method of training?

make unbuilable near jail spawn

bug:
	if you grab someone who is charing a beam they cant move any more?

could make a new ability for when a blast is coming at you a rock pops out of the ground and the blast
hits it instead and explodes it, could put it in blast homing.

use the new byond transform variable for all size changes, not only does it look better, but seems to
perform much faster. use it instead of enlarge icon

something needs done about all these kienzans sticking around

make powering up helps break free of time freeze. like if your bppcnt is 130 you break free 1.3x sooner

make cant spam stun chip...and only works in proximity. its not meant for griefing people

optimize these and make them only run on the buff itself while activated
	Buff_Drain_Loop
	buff_transform_drain

make spawns can not be made in hbtc

is there any way around redo stats setting all stats back to 100?

make pod fly over roof

redo soul contract's life stealing to have diminishing returns

if possible, make it so when beam stunned, you can still walk into the beam, so if your powerful enough
you can fly thru it and punch the person

BUG: how to get inf bp: grab an npc with a bp mod above one, transplant into it, imprint
some bp onto it. relog and sometimes you log back in named as your key with the same bp, but
at a 1 bp mod. therefore you created bp

dojos that a player can charge for entry, and they teach special fighting styles or something
	poison style
	slowen style
	deterrent style
	grappling where neither can run from battle and have to just stand and hit each other

add a way to lower someones bp to 1 with dna

make trees, and surf, and other buildables not suck into dead zone
and make objs sucked into deadzone spread around

the core concepts of this game seem to all be negative and there are some important missing concepts
that would completely make the game a gajillion times better.
	currently:
		conquest
		power
		greed
		technology
		exploring (underused)
		freedom (needs fleshed out more?)
	missing:
		heroism
			in most games you are the hero in this game heroism is impossible. cant do it if you tried
		friendship? (idk what this means)
		government
		economy

add government shit

give demons extra power over people who are in their domain

in sagas, let their be sub heroes and villains too. or multiple heroes and villains.

ability to craft shit outside of science, stuff that is not technology, like mystical shit
	a pendant that summons a demon player and gives you some power over them and demons cant hurt you
	a portal to AL and back
maybe you can craft some of this shit out of corpses

if you bury a bunch of bodies and make a graveyard it becomes haunted and shit and some kind of
magic effects and shit

maybe less sets of dbs but they respawn faster

make it so you can mount bombs onto practicaly anything. give bombs a mount verb that will mount it into
the contents of anything in front of you. and blows the fuck up

give demons a stone spit ability that works off str/dura its just a clone of time freeze maybe but
with tweaks

a place you can go where you devote your character to good. you can not kill anyone else who devoted
themself to good. but you gain a buff when fighting anyone else because they are heathens that are all
considered to be evil since they arent devoted to good

a fucken sword that slays evil and can only be used by good

SERIOUS REAL BUG: put telepad in front of door, put pod behind telepad, destroy pod, telepad shoots thru
door. get in anyone's base.

bug: observe someone inside a building then observe yourself while spam clicking explosion inside
to blow everything up inside

exgen wants me to change all names back to lizard sphere x mode because he has a friend who can
live stream the game and has 40k viewers and they would play maybe

turrets fucking suck make them more powerful


saiyans are still spawning on the saiyan spawn even if it has a redirector on it.
could it be that reincarnating ignores redirectors? (not even sure they were reincarnating)


add where you can force inject for a resource cost even tho it makes no logical sense add the option
because it makes no logical sense to not be able to force inject someone either

make it so you can character steal again (force their brain to another weak body) but it cost a ton
people dont take shit seriously and wont obey rulers if they knew they the final outcome would
be they lose their character they would obey. right now no threat a ruler can make will ever be
taken seriously. there needs to be expensive ways to fuck someone up.


bug: get focusin while you have a soul contract alt. alter bp to 1 and focusin near a strong guy.
 i think focusin bp is hbtc so you should be able to then alter yourself back up and have double
 bp

let signs and info panels be blueprinted

should be able to get rsc by scrapping weights made thru science. currently you get none of the upgrade
value

leeching too fast

SC bp altering is gaying up the place. limit to 70%?

in addition to having a timer between teaching moves, make it so a person can only learn so much at once
depending on the complexity of the move. and maybe a learning mod for each race

get rid of make fruit and instead add a yemma tree that only produces like
1 fruit every 15 minutes. people will camp it and fight for it and block it off trying to control it

make pods/ships have less launch time but cant move during launch process

make scrapping take some time and say like "blah is scrapping the blah" so there is time to fuck them up
cuz scrapping turrets is a problem


bugs:
	clone nameks and alter its bp up with sc, fuse a fused
	namek with the clone, make another clone, fuse clone with new clone
	for inifnite fusion bp as high as you want

	1) get ascended low class 2) make fresh elite and SC alter its
	bp up and it will equal what the lowie's bp is then ascend the elite
	and it creates and infinite 3x SC alter bp loop
*/
mob/proc
	Get_bp_loss_from_low_ki()
		switch(Race)
			if("Namek") return 0.5
			if("Half Saiyan") return 0.85
			if("Bio-Android") return 0.9
			if("Human") return 0.8
			if("Tsujin") return 0.8
			if("Spirit Doll") return 0.7
		return 1
	Get_bp_loss_from_low_hp()
		switch(Race)
			if("Namek") return 0.5
			if("Saiyan") return 0.8
			if("Demon") return 0.7
			if("Human") return 0.8
		return 1

mob/proc/Power_Effects(obj/Power_Control/A) while(A&&A.Powerup>=1)
	var/Sleep=300/bp_mod
	if(Sleep<100) Sleep=100
	for(var/turf/B in range(10,src)) if(prob(5)&&A&&A.Powerup>=1)
		B.Rising_Rocks()
		sleep(10)
	sleep(Sleep)
turf/proc/Rising_Rocks()
	var/image/I=image(icon='Rising Rocks.dmi',pixel_x=rand(-32,32),pixel_y=rand(-32,32))
	overlays-=I
	overlays+=I
	spawn(200) if(src) overlays-=I






mob/var/tmp
	mob/flash_step_mob
	flash_stepping
	turf/last_cave_entered
	last_cave_entered_time=0
mob/proc
	Set_flash_step_mob(mob/m)
		flash_step_mob=m
	Can_flash_step()
		if(!Can_Move()||grabbed_mob||grabber||dash_attacking||beaming||charging_beam||Beam_stunned()||\
		flash_stepping) return
		return 1
	Get_flash_step_target(mob/m)
		if(Is_valid_flash_step_target(m)) return m
		m=flash_step_mob
		if(Is_valid_flash_step_target(m)) return m
		m=Manually_find_flash_step_target()
		if(Is_valid_flash_step_target(m)) return m
	Is_valid_flash_step_target(mob/m)
		if(!m||m==src) return
		if(m.last_cave_entered&&m.last_cave_entered.z==z&&getdist(src,m.last_cave_entered)<20)
			//if(viewable(src,m.last_cave_entered))
			loc=m.last_cave_entered
			m.last_cave_entered.Enter(src)
			return 1
		if(m==flash_step_mob&&m.z==z&&getdist(src,m)<50) return 1
		if(m!=flash_step_mob&&m.z==z&&getdist(src,m)<22&&(get_dir(src,m) in list(dir,turn(dir,45),turn(dir,-45))))
			return 1
	Manually_find_flash_step_target()
		for(var/mob/m in players) if(Is_valid_flash_step_target(m)) return m
	Get_flash_step_delay()
		var/n=To_tick_lag_multiple(Speed_delay_mult(severity=0.5) * 2.5)
		return n
	Flash_Step()
		if(!Can_flash_step()) return
		var/max_dist=To_multiple_of_one(4*(Spd/Max_Speed)**0.35)
		if(max_dist<2) max_dist=2
		if(!flash_step_mob||!Is_valid_flash_step_target(flash_step_mob))
			flash_step_mob=Get_flash_step_target(Opponent)
		if(!flash_step_mob) return
		var/turf/old_loc=loc
		flash_stepping=1
		spawn(Get_flash_step_delay()) flash_stepping=0
		for(var/steps in 1 to max_dist)
			if(getdist(src,flash_step_mob)==1)

				return //the whole spinning around your target spamming shit is now removed

				var/list/turf_list
				for(var/turf/t in oview(1,flash_step_mob)) if(!t.density&&t.Enter(src))
					if(!turf_list) turf_list=new/list
					turf_list+=t
				if(turf_list)
					loc=pick(turf_list)
					dir=get_dir(src,flash_step_mob)
					var/face_chance=100 * (flash_step_mob.BP/BP)**0.5 * (flash_step_mob.Def/Off)**0.5
					if(prob(face_chance)) flash_step_mob.dir=get_dir(flash_step_mob,src)
				break
			else
				Instant=1
				step_towards(src,flash_step_mob)
				if(steps==max_dist) step(src,pick(dir,turn(dir,90),turn(dir,-90)))
				Instant=0
				dir=get_dir(src,flash_step_mob)
		if(loc!=old_loc)
			flick('Zanzoken.dmi',src)
			Ki-=Zanzoken_Drain()*3
			Zanzoken_Mastery(0.2)
/*
manually set splits to 100% health upon creation in case that is why they instantly die

Xirre had an idea for anger where, the chance for anger is like 100%, but like if your anger is 2x,
then when it kicks in you get somewhere between 1.5x and 2.5x, and the boost you get also affects the
cooldown til you can get angry again

make so chars slide around obstacles, like if a tree is in front of you and you hit the direction toward
the tree you will instead go diagonal to bypass it

make person who placed bounty not able to claim it

make diarea needle exempt from forced inject

make it so building a dense turf on a spawn disables the race from being chosen

beams arent cancelling when you get grabbed sot he bug is still there

why does cyber bp lower so much with low ki?

a machine that tells you when a dragon ball is about to become active

a machien that tells you what stat-info tells you

instead of tiers trading upon defeat there could be a mode where what stage you make it to in the
tournament decides what tier you are, but you cant go down. so stage 1 = tier 1, stage 2 = tier 2, etc
skill tournaments only obviously

make absorb can sort of absorb hbtc but giving you the same base_bp to hbtc_bp ratio as the person
you are absorbing if it is less, but at the same time capping it because if your 2000 base bp and 0
hbtc and you absorb someone with 100 base bp and 1900 hbtc bp, you would go to like 100k

ability to absorb a spirit bomb to go to 150% health and energy but a large cooldown on it

make anger mod determine how much health you get restored, like make it 100-(30/anger_mod), so
1x anger = +70% health. 1.5x = +80%, 2x = +85%, 3x = +90%

you can break out of a beam struggle by stop firing a beam and fire blast instead because for some
reason normal blasts cut thru any beam

make tournament record damage taken and decide match based on that if it doesnt end by KO

guy teleport into my pod and tried to kill me
it happens if you SI to someone then they get in the pod after you SI'd

add nyoibo

add poison expire time right now its perm

add a way to lower/raise reg/rec on gen comp in exchange for stat cap, only on modless mode

somehow make it so the longer you charge a beam the bigger it gets!

fix rename spam

make a toggle for trolls join tourny

make KO revert kaioken people death avoid with it

make it so your body can not log out in death regen zone

make it so mass revives only apply to weak people

fix reincarnate so that it can be used to become another race again but you can make it so it completely
deletes your old mob and disconnects you and forces you to remake, but the stats you will inherit
are stored in a global list with your key telling how much your new char will inherit

maybe you can force reincarnate a knocked out person somehow to make them choose a different race

make ships in ships impossible

build ship, build pod in ship, get in pod, build ship in pod, ship is now in pod, infinite ships somehow
make cant build any tech in pod

make it so by the time you reach 100 million bp you just have 500x gravity auto mastered

add free for all tournament

make it so you have to stand still to use the regenerate ability, but make it better

find out why splits and sims cant take 1 hit

rebuild module did not rebuild me. i also have scrap repair at the same time. neither worked

limit t fusions to a certain boost and give it some sort of downside like really increased ki drain
or something
i spammed t fusions to 900k when the strognest person was 40k

npcs are melee attacking edge objs and wasting cpu

if someone grabs you when beaming you cant stop beaming and it ends with you drained of all your ki

stat cap becomes too low for people who put points in regen/recov they become useless!

make bp mult combined with ki>100 combined with BPpcnt ADDITIVE instead of multiplying together
make powering up in oozaru impossible or something

make people who use the majin ability take 15% more damage from demons

the secret that wall breakers are hiding from me is kaioken

optimize bio field generators

make it so that the higher you power up in ussj the slower yet stronger you become

fix people spawning in the same place in AL

add another version of makosen and call it Super Final Flash. its like makosen but takes longer to
charge and is much more powerful and you cant move

perhaps change makosen to be more of a regular blast but with a trail, that takes long to charge, and
when it makes contact with the enemy it creates a massive sustained explosion, maybe like a makosen
moving over them, and knocks them back

remove the 3 sense objs and instead have these separate multiple-time upgradable abilities
sense range
sense accuracy
sense details
third eye can amplify these attributes and nameks and kais are great at it etc

fix amulet spam

make cant meditate when strangled

redo anger

i saw a real bug where a person injects some t injections and gets nothing but when they die
they still get their stats divided

make injure/absorb on logged out people possible

you lose 50% of your rsc upon logging in even tho its not 10 mins

add janemba's ability to send a blast thru a portal and it comes out and hits the person who fired
it

make it so it is pretty much impossible to make weights any higher than a certain amount, perhaps
after 3 million bp they start to outlive their usefulness, although someone could choose to still
wear them simply because any amount of weight adds a little bit of gains

slow down spacepod diagonals

add scaledown to bp gains after being afk a long time

make scattershot if(blast in Get_step(dir)) then it steps around it instead of colliding with it and
exploding

make majin have less regen/recov BUT they have less loss from damage/exhaustion

i saw it happen people who fly directly into oncoming charges will go straight thru them unharmed
like 40% of the time

fix SI zanzo it wont work now

BUG: relog during death regen to avoid KO, but make sure your body disappears, wait the 1 minute!

(Telepathy)WAT WAT WAT: dead bodies have a x1 bp mod according to ex, so if you die with a x13 bp mod the body has a x1 bp mod and retains your BP, you then imprint it for a x13 BP boost

blasts need to not explode if you blast absorb it because if you absorbed the blast how is it
exploding?

androids dont lose ki but cant powerup at all?

check if gains scale down with how long you have been afk because they should to an extent since
its what you do while your active that should count

learnable majin/mystic for kais/demons

race restrict certain abilities. saiyans for example are meant for fighting they should only be able
to use their ki in ways that pertain to fighting, so no reviving, materializing, unlocking, etc.
maybe they can learn to heal but their heal mod should be pretty low, or maybe average, while something
like nameks would be high

they voted this
	materialize and unlock potential for namek/kai/alien/demon only and others have hard time getting it

NAMEK THINGS
	namek fusion
	ranged grab
	namek regenerate
	better blast deflection
	super hearing
	giant attribute
	paralysis ki attack
	better homing for their ki attacks?
	only race who makes dragon balls
	counterpart system
	better 'heal mod' for healing others
	easy access for materialize and unlock potential and perhaps better mods for them



if you get knockedbacked it seems like it bypasses the waiting time between melee attacks and
i see people attacking super rapidly
fix the thing where if you punch someone they auto face you and score a hit of their own

regenerate still bugs overlays

make so if you dont move you power up faster and it has flashy effects

get killed when charging genki dama and cant move ever gotta remake

remove limit to vampire smell range

supposedly if you crash yourself during death regen, whyen you regenerate you will not be subject to
the paralysis and regenerate animation. come back full power instantly

find out why nukes don't destroy doors

add free for all tourny

make explosion a charge up attack where there is a delay before it happens but it is actually powerful
enough to be useful

make bounties only placeable on evil people when alignment is on

put ATMs in the game, they are banks, you make deposits and withdraws. no more alt banking because if
you log out with the resources then they decline in value.
	maybe you can make a profit from interest on the ATM but it is limited to +100k an hour?

manual block ability, toggle on, cant move, cant attack, but defend very well
	maybe cant heal, or have energy drain, so majins cant abuse it

fix the bug where if you get KB'd while beaming your stuck with the animation

anger chance 100%, no timer in between angers, but anger refills in between angers like grab power
does, and there is anger_refill_mod
how full your anger is will also have to determine how much health/ki you get restored or it could be
abused, if i even still give full restores

add toggle on/off to ki jammers

make prison cost 20 mil, which imprisons someone for an hour. you can get up to 1.5 hours I guess by
doing a higher bounty. prison time does not go up with successive imprisonments

make beam deflection a player reaction instead of automatic

make shockwaving while grabbed as if struggling

replace nuke graphics with the new explosions

put a meteor storm around earth so it is harder to get to

combine bio form req with a base bp req of 2.5 mil

force people to leave prison when their sentence is up, and dont let outsiders enter the prison

rethink coming back to life:
	to revive someone you must give up your own life (in addition to the timer)
	make mass reviving on dbs worth it

make no power difference between dead people with keep body and those without, but the advantage
is being able to stay longer in living world and stuff?
or remove keep body. and gives a grant permission verb to Kaioshins to travel to living world
for limited time. UNTEACHABLE. KAI ONLY PERHAPS.

maybe make living people in afterlife have energy drain too.
neither can stay where they dont belong for very long.
except kais and demons and demigods?

make nameks able to stun others

A way to become King of Hell and benefit from Altar uses and stuff?

add Ritual of Power to Hell Altar and you accept it and you get less energy drain for an hour,
then more energy drain for 1 hours after that

WHY ARE SPLITS AND SIMS DELETING??

redo auto repair module

bp scanner module needs to detect droids
also im told it doesnt even work

redo overdrive module's drain to consider the ratio of natural bp to cyber bp

make it if there is a shikon jewel then the save directory of the person who has it is kept saved
so that if they log out for over 24 hours the shikon jewel goes to someone else and is removed from
their save so that it isnt lost forever

add reincarnate choice to hell altar?

add buu transes

add Geti Star
	make it able to insta dig all the res out of any planet it goes to

give majins the cookie ray thing

as long as bounding boxes are in multiples of world.icon_size, pixel movement will not be enabled

anger needs to be something other than a % chance cuz if you take 2 equally skilled fighters anger will
decide the fight

make it so when you attempt to move while strangling someone you throw them
make cant move when SD
people bypass SC by brain switching with another key. may have to make it by comp id too
regenerate bugs overlays
and getting repeat killed makes you stuck as goo

redo the powering up effects. these lag anyway

people are getting huge, huge zenkai off of being blasted

redo sacred water

give ships meteor defense lasers

fix pods always landing around the same place


force field item and module need redone
	the item, should have a set amount of BP, but the scaling should be dramatic if a person attacks
	who has more than that bp. like (ff.bp/attacker.bp)**3. but normal scaling if they have less.

ki whores have no defense, boosting their shield power even further, make defense affect shield
	but I tested a balanced build with 12760 all stats, lowering defense to 1 made the other stats
	go to 14003, only a 10% increase. Meaning only a 10% shield increase too I guess.

the ki whore can have decent dura by stacking armor, cyber armor, and majin, then lower their dura
to normal levels and pump the rest into their other stats
	I tested it here are results
		balanced guy
			12760 all stats
		guy with armor+cyber armor+majin, defense lowered to 1, using buff with -2 def, +1 str/end
			16022 all stats, except 1 defense
			25.5% higher than balanced guy

people switch back and forth between shield and blast absorb the nerf i did was useless?

why ki whore shield is so OP:
	blast absorb refills it
	generator module
	cyber bp does scale down as much from ki loss, so the sustain more damage on shield from that
	refill it themself by absorbing their own beam
	turn shitty dura into decent dura by putting on armor + cyber armor + majin
	the sacrificed base dura gets channeled into more other stats including resist
	sacrifice all defense for more dura/resist

skills that have cooldowns of realtime can use modulo to display it better!

SERIOUS BUG: Xtremedave: Using redo stats but relogging before pressing Ok keeps the stats you distributed

we may be able to remove that whole thing where your force/resist ratio can lower your blast damage

there is some kind of bug with beam velocity and blast caching. final flash will sometimes move as
fast as a piercer. and there is some breakup in the beam due to sudden velocity changes.

make telepads in hbtc not work
make people in ships in hbtc age really fast people hide ships there
fix cave on arconia that is unsensable because of wrong area

make so you can still sense tab yourself when hiding power

make meteors drop like 100k resources when destroyed?

anger seems to not work right, some people say it doesnt kick in, and sometimes it spams itself

maybe have alignment without the evil penalty, but instead add some kind of good advantage
	right now they are the only ones who can get death anger
	maybe they get something the more evil people they kill who are strong to them
	faster leeching maybe
	something that promotes helping each other in times of need or danger. saving people

you can telepad into TFR by putting a telepad in EG tower and one in TFR because they have same area

self destruct is missing people too easily if they just move 1 tile

self destructing needs to hurt hte person grabbing you

kienzan doesnt work

if you use shield you can death avoid because you never lost any health?

make flying transition you out of train/meditate
make trying to move transition you out too

black holes in space that suck you in and put you in a different part of space maybe drop you
onto another planet

all OP people are shield users. shield needs rebalanced interactions with certain builds maybe

androids use shield + blast absorb because of the powerful interaction where taking damage drains
ki instead of health but blast absorb gives back the ki so its like they arent losing anything
	force field item can be used simultaneously with blast absorb too

FTP IP: 209.141.38.222

Final Realm BP bug abuse: stay in FR shoot a piercer at someone and they gain insane bp

make a One Peice, Naruto, and Bleach version of DU on different hubs for more income streams

when people are given admin make it link them to this: http://www.byond.com/forum/?post=850741
http://www.byond.com/forum/?post=707368

make an undelete cache for when admins accidently use delete on something?
or just make a confirmation

remove utra_pack var from edit so people cant get the gain bonuses using admin
	except for me and exgen
remove AI training from give?

@Tens: Ultra Pack is bugged. It's not giving 100% anger chance. I believe its not triggering the anger proc at 0% health, at least not consistently. Sometimes it can trigger like 10 times before a person is KOd too.

bio-warrior technology. low decline but effective short term warriors

exgen says when someone uses replace its logged in the error log not the admin log

<--(6:20 pm) Atmos sphere: Ok,I was going to post this to exgen but he hasn't been on.
 Basically the "inf resource" bug isnt really infinite,it basically x2 all items in
 inventory as well as resources.

How it works is you need three people;
An android wi
 th body swap.
A plain character to get body swapped with
and i standby character.

W
 hat you do is that you body swap with the plain character with the items and resou
 rces on the android,Log out with the android while body swapped and this is what hap
 pens, It leaves behind a clone of the android and once it is destroyed by the stand
 by character it drops all items and resources on it. When you log back on with the
 android it will be unharmed and will still be in the plain character's body; Android
  ends body swap to pick up resources and items then it can be repeated over and ove
  r until you have the desired amount.

This bug x2 all inv and resources. I found o
  ut from ezio not too long ago but honestly i've been on vacation in england and g
  ot on a couple days ago so here you go man. Any questions?




plan to trap everyone on vegeta
	put spawn redirectors at all spawns off vegeta
	put resource destroyer, orbital cannon, and teleport nullifier on vegeta
	people can still escape thru jail, death, and atlantis so:
		idk yet

world/Export(Addr,File,Persist,Clients)
	var/old_log=log
	log=file("LSX.log")
	log<<Addr
	log=old_log
	return ..()

offense of the player should affect gun offense because it affects aiming due to accuracy and precision

make it so if a roof is built on top of a spawn that spawn becomes unavailable

orbital cannon needs a defense system

going into cache needs to reset stun var thats why ki blasts was stunning!
prison needs to be safer it is not a place to be endlessly harassed
	dont allow outsiders to just enter the prison
		make them pay a hefty price?
	prison isnt a punishment, it is just to keep the person out of your way
		so there needs to be worthwhile things to do in prison
	if you attack another prisoner in prison you get KO'd as if stun chipped?
		when you first appear in prison a drone appears next to you and it says "prison bot stun chips you"
	cant make technology as a prisoner?

	put multiple prison spawns inside the prison, and when a person uses Im Trapped in the prison,
	it teleports them to random prison entrance, so that nobody can trap them in little cubicles and
	harass them.
		and you cant build within a certain distance of prison spawns

THE 404 ERROR THAT CRASHES THE SERVER
	is not caused by...
		player preferences
		OutputPlayerInformation
		Run_Remote_Check
	remaining things that use Export
		Get_Packs
		Ruin

people keep force field blueprints on them since they cant upgrade force fields while fighting, they
just quickly make a new one and grab it. make it so you cant deploy blueprints til 1 min after a fight
or make it take time and you cant move
credit sheep for the idea

remove changing regen/recov with custom buff because faggots use a 16x regen/recov buff to rapidly heal
when they are near losing as they run like little bitches then instantly come back to own you

remove take all soul contracts people alt abuse it so nobody can break their slavery

BUG: supposedly you can force someone to accept a SC while body swapped

replace pod trails with Aura Blast Size 1.dmi

guns need to update their force sometimes because an old gun will lose power compared to new guns built
on higher force

add a bank to each planet (or just in space) and a person has to actually go there to make deposits
and withdrawals, where they could be ambushed, also access points could be blocked off

make it so people can be bailed out of jail but if they kill anyone they are sent back

make door hackers only able to hack like once per minute so they need to recharge or something

death_cures_vampires isnt saving?

vamps
	more power
	weak to holy amulet
	weak in heaven
	dont start getting hungry until 10 minutes after they last fed

bug: if you have a splitform around you you become a valid target of your own scattershot

an uncharged genki dama does 2x the damage of a death ball, and its nearly invis, put a minimum
charge time til it is at least visible yet small

doors are practicly nuke immune people are building door only bases

make no grab in FR

npcs are dropping hbtc keys even when that is off?

/turf/Waterfall can not be destroyed by ki supposedly

dead people only zone where they dont be wtfpwned by living people constantly

make it so you cant be instantly revived upon dying with the revive skill

cloning tanks only work if you die while dead im told

exgen believes to get bugged str mod that ruined the wipe you get a licker dna and clone it
or imprint it or something
1) clone dead zombie 2) get in it 3) cure it with antivirus 4) re-zombie it 5) now you have
infiite stacked zombie bonuses?
CONFIRMED: 1) kill zombie 2) re-inject dead body 3) zombie bonuses stack
1) inject zombie with t recov 2) kill it 3) inject body with t recov 4) INF recov

people use blast absorb to power up extremely high

make it so when you inject a living npc with zombie virus it dies and turns into a zombie instead
of having to kill it then inject the dead body

reincarnate doesnt remove injuries/vampire/etc

make it so you dont have to be in base form to go golden oozaru make it revert you

make buffs not influence bind power

victims of body swap can SI out of the droid and dupe themselves

disable building in FR

people are still telewatching or SCing to final realm and staying there in a base like faggots
and bounty droning

add ultra super saiyan, perhaps it has near the same bp as a ssj2, but halves ki, speed, offense,
defense, and recovery, and perhaps increased ssj drain

make it so a person can only learn 1 new skill per minute

the beam canceling thing when you punch someone doesnt work when they are using shield and it is
annoying that they can still do the old "noob beam spamming" technique

afk people should take less damage because attacking afk people is cowardly

make zombies die after they get to a certain age, this will help when there is like 99 zombies on a
planet, but 1 on another, and the cap is 100, the 1 will have a chance to reproduce when an old one dies

people voted 9 to 3 to make beams grow in power the further they travel

check error log it might be why the server crashes often

fix extendo arm

on shurikens, it would seem that knockback is being called before the explosion, sending the target
out of the explosion's range, and not causing the extra damage

add a passive buff to people who are being attacked by more than 1 person
make the initial hits of a fight regenerate over a 10 second period as if they never occurred to
	nerf ambushes
nerf running by making it so that if a person runs more than a certain distance from where the origin
of the fight occurred, they take additional damage, but add an exception to knockbacks, and if they
attack back i guess take the additional damage curse off

make it harder to run away successfully

meditate to heal injuries skill

people voted overwhelmingly to make it so people have to ask permission to copy icon

BUG: Requires Alt : Make A Character With Maxxed Out Ene Mod , Then have a alt with non in ene ,
rest in force ,resistence etc etc , Then Dna  The Alt And Imprint On The Character With Maxxed Out
Ene Mod  = U have MAxxed Out mod With Balanced Build

to tame the mindless killfest I could
	make death zenkai better, sometimes it seems to not even detect you were killed and kick in, that way
	if you kill someone its bad for you because you made them stronger

	a bank or some place for people's money so that they dont have to run around with it and people
	rob them for it and kill them

insane powerup bug 150x bp. can get 300 recovery almost by making full recov alien, + mystic +
t recovery + recovery buff
get in a regenerator and it will send you to like 1200% ki. you can powerup to insane bp
NOTE: I fixed regenerators overcharing ki beyond 100%

cache weights()

redo blast homing it uses a lot of cpu sometimes

time skip wish, skips ahead 10 years, gives everyone some power as if theyve been training

turfs can repair themselves to their initial type without any lag, just when a turf is destroyed add it
to a list and have a global loop go thru the list repairing each one with a delay in between

guns, nukes, and turrets need to use set_stats() it is very important

put a curve on grav leeching, one that slows severely

critical hits inflict a temporary injury. durability reduces injury chance, durability vs offense?

exgen bugs
	if you use the SI zanzo thing during a dash attack you can magnify the damage calculation by
	adding 100 extra tiles to the distance

the beam proc should be divided into seperate loops because each loop needs different delays. the
beam appearance only needs to be updated once per move, the damage loop for players should be
pretty fast looping, the damage loop for turfs only needs to happen once per move, etc

make so droids cant power control and repair at the same time because they can take out any wall
that way

med scan should tell you if your infected with zombie virus and be more expensive

1) body swap into alt 2) log out android 3) drop alt's resources 4) log android back in 5)
press body swap 6) now there is 2 androids 7) kill one android 8) grab the resources it drops

offense sucks so make critical hits and the chance if based on offense only, no influence from other
stats except for BP, make 5% base chance, 1.5x damage, big knockback, apply slowdown effect to enemy

make Who list class for admins

door hackers are too effective
	maybe they can be overloaded if you use it wrong or if the wall has some sort of defense system
	engaged.
	then they could be made cheaper too
	the ratio between the hacker's upgrade level and the wall defense system's upgrade level will
	determine the difficulty the hacker has hacking the wall and if it fails it overloads and must
	take 5 minutes to reboot
	auto wall upgraders that upgrade once per hour to the full extent of the tech cap

make walls (not roofs) be like roofs so that nobody can fly/zanzo over them and cant shoot scattershots
etc or hokuto

arm stretch hardly ever works its bugged
and it can still grab drills thru walls

kaioken raises tech cap
they go in FR and spam kaioken infinitely

SC can summon people to FR and they stay there

remove forms of global leeching. things like dragon balls idk how they would work maybe get it in hbtc bp

portal to kaioshin planet that only lets 3 people in at once then takes 30 minutes to reset

people kai teleport others out of tourny and steal their stuff

make so need force to fly so melee whores cant fly good

maybe to prevent the 100 drills at once thing to get all resources you can make it allocate resources
based on the drill's value again, but each new drill divides how much the planet generates, that way
there is no point making many many drills even with the allocation system

have a way to sacrifice bp mod for intelligence

walls can be made of strange materials. like vibranium, if you attack it you take damage, some materials
regenerate health faster, others have more max health, etc

make walls quickly regenerate health so that if you cant break them really fast you cant get past them
maybe all stats need to count toward whether you can break the wall instead of just BP
and make BPpcnt count less to breaking walls

admin verb to disable building so there can be a clusterfuck of chaos

resource vacuum needs to suck resources out of all nearby drills too so that if you have a ton of drills
you can withdraw from them all at once

learn to materialize new basic tools after enough weight tiers such as
	hand drills
	shovel

new way to master power up, your mastery represents how hig you can power up. if its 134 you can go to
134% full speed but after that it only goes up really slow

using RAGE on no anger people still lowers their bp

make getting hit cancel senzu/fruit effect or something because using it mid battle
is so lame

right now you dont actually see any speed increases unless you train speed past 20% of the highest
speed on or something like that. but what if you would see increases no matter your speed. like
speed_ratio = 1 + (speed/highest_speed)
	so if highest_speed=1000
		1 speed = 1.001 speed ratio
		50 speed = 1.05 speed ratio
		100 speed = 1.1 speed ratio
		500 speed = 1.5 speed ratio

make sword not actually change strength

people's houses cant even last 1 fucking night. rethink the damn system

people need to either choose if theyre going to train knowledge or power they cant do both, knowledge
should cap slower. maybe the knowledge cap isnt a cap any more but the further you go past it
the slower you gain knowledge by far.
maybe make knowledge raise by upgrading things


newbs are leaving because they get binded and jailed every second. make bind can be illegal and jail too

anyone who kills you is added to a list on your mob and you deal extra damage against them as
revenge. should only apply to good people if alignment is on

elites need higher ssj3 bp reqs right now they are the same as low class

make sacred water give a 1 time power boost of some kind. maybe energy boost

when you die, lose immortality

make cloning machines more viable, but clones are weaker in a permanent way and only live 10 years

dragon ball z revolves mostly around 1 on 1 duels, 2 on 1 is dishonorable and an advantage should be
give to someone who is having to fight more than 1 person at once
	1) maybe only good people should get the advantage when alignment is on
	2) you should only get the advantage if you didn't attack first
	3) you should only get the advantage if your outmatched otherwise

	so if you attack someone while their opponent is equal to someone else they take less damage from you
	so if that happens, make their opponent deal less damage too

things like unlock potential and zenkai or whatever else gives leeching of the strongest
player should be redone to not use the Leech proc, instead a new proc needs developed specificly
for handling catchup to the strongest bp. and it should only give BP, not any of the other things
Leech gives when you use it.
in fact why even let them leech the strongest person? they should only leech people they come into
contact with. get rid of global leeching

maybe leeching bp should use that system where the closer you get to matching your opponent's bp
the slower it gets. like with gravity.

namek fusion could grant the equivalent of a training session in the hbtc
like if hbtc_bp<base_bp/2, hbtc_bp=base_bp/2. so that it gives UP TO a 50% power increase

people didnt just change bodies in DBZ, there should be some sort of penalty for not sticking to the
body you were born with. maybe clones have 0.9 bp multiplier. it is a fucking full on brain transplant
after all you cant just function 100% after doing that shit. if they want the flexibility of changing
bodies any time they want, there needs to be a drawback

make cant SI to androids

could a Freeza-like Planet Trade Organization be added somehow? It would have to be highly
incentivized and made rare so only very few can take part in it. Maybe there could be tiny planetoids
with rare resources that only very few people can make use of. Because why sell a planet if anyone
can make use of it? Just own it yourself. The planetoids could be dissassembled. There could be endless
amounts of them that spawn only once in a while. There may be a need for wormholes to different
galaxies (space maps) where these planetoids can be harvest

cloning a ssj the instantly having ssj is a problem, make it so they dont have ssj and their
req is 20% higher than whatever base bp they have or something

BUG: redo stats on android, relog before clicking done. put modules on and do redo stats and stuff
happens

switching buffs instantly is a HUGE FUCKING PROBLEM.
people in dbz didnt move while transing and it took a bit of time, moving should cancel

make no built at AL spawn dead spawn

optimize blasts and melee more,blasts used 3.3x more cpu than melee and melee used 10x more than
anything else

make no rename hbtc key

make dead bodies record the realtime they were made and delete 2 hours after

make ko anger no cause ssj

fix teach timer bug

make it so people in a league can get thru doors that use the league's door passwords that the leader
sets up. Like the leader can put in the league that rank 1 can open doors with password "pw1", "pw2",
and "pw3". so its a list of passwords

make it so people cant fall thru AL clouds if the spot theyll land in is a house

bios still suck. give higher bp mod? 2.1? stronger static boost. cyber bp boost?

its too easy to get insane decline. as a saiyan i got 82 decline, 205 lifespan. fix the scaling
but i had ultra pack, meaning upon making my decline went from 30 to 60, does that mean without it
i would have 52 decline and 130 lifespan? even so that is too high for how little energy training i
did. i had 6600 energy with 1.5 mod

why do pods always land in almost the same spot on every planet?

shield when used with anger is OP, its like being invincible til you run out of ki. anger already
refills ki, isn't that good enough? if you waste it all again you shouldn't stay at full power
and if your busy holding up a shield, that takes a lot of focus, should it slow down your movement or
your attack speed?

give spacepods back the dbz spacepod icon

fix the bug where people spam KO each other to get spam KO anger to go ssj without actually bing
in a fight and bypassing the timer

SOLUTION FOR GRAB CHEATING BUG
	Make it so both the grabber and grabbee take full damage
	Make it so the grabber can not attack while they have someone grabbed

---------------
a realm that only magic users can access, it has 3 zones, each zone more dangerous than the last,
survive the dangers and pass the tests in each zone to access more advanced magic abilities
	and at points in the dungeon you would have to face off against other players
	maybe this magical trial only happens once an hour and any other times this magic realm
	is basicly a hangout

	maybe to use magic you need a sort of currency that can only be gotten in the magic realm,
	its like resources, instead of having resources it has magic currency/rocks/things

new gameplay dimensions to prevent stagnation
	players being the wardens of prisons
	true planet conquest
	being a benevolent tribal leader of a species (King of Saiyans, Namek Elder)
	magic that involves summoning, illusion, and manipulation of things in strange ways that ki can not do
		such as casting a spell that makes someone go berserk and unable to fight properly
			invisibility, create an enclosed arena around you and your enemy so nobody can run away
			Chaos manipulation, such as causing blasts to move randomly in different directions when someone
				fires them, it could hit you, the target, or anything else, it creates chaos and negates power
				differences
	something important that players can get other than resources and power if they choose to
		power is used for fighting
		resources is used to get technology
		but what would this third thing be used to get? magic access? do you get it from
			being a prison warden? a king? a conquerer? a magician?

Summoning (for magic)
	you can summon npcs but you can also summon players who agree to be in your summon list,
	they need to get something out of it too of course. Soul contract can do this too but this
	is a more limited version that doesn't give you so much control over the person because it is
	meant to be a mutual thing. It could be the soul contract, but the person could only agree to
	certain parts of it to limit the power of the contract holder.

New gameplay dimensions possibilities summary
	fighter
	scientist
	warden
	conquerer
	leader (king, tribal leader of your species)
	magician
		It would seem that each should have unique rewards, fighters have power, scientists have resources,
		but what other things can be invented?
----------------

make so your char doesnt attack league members unless friendly fire is on

people should not just be able to change buffs instantly there needs to be some time to transform
like in dbz

players voted like 15 to 4 to close the gap between med/train and sparring, so nerf sparring

kienzan/sokidan/etc can still go over walls 1) get below the wall 2) face it 3) observe it
4) use the attack and it goes over the wall

ki jammer doesnt block explsoisns

make buff transorm attribute bp boost not fluctuate, make it stored in a players buff_trans_bp var
and it only rises not falls

shoot 2 extendo arms out at once both homing in different directions but try not to overlap each other

krillin's homing attack, its very slow and if it is deflected or the enemy is outrunning it, it breaks
into a bunch of smaller blasts and tries again

make extendo arm ignore landscape stuff
make extendo arm choose players over objects if available

put earth area on kami lookout cuz it doesnt get PD'd

make a way for people to change their extendo arm icons

extendo attack

make a vote to turn on crazy for 5 mins

grappling hook item that is basicly extendo arm for anyone, but no homing, and shorter range

bios can have extendo arm, but its a tail, and only goes 5 tiles
icers too
but bios and icers can only use it as an attack not a grab, except for items maybe

bios should have ranged tail absorb to drain energy/health from enemies for themselves

ssj spread so fast because clones of ssjs auto have ssj

put majin gum absorb where they send out the gums to absorb either KO'd people or people significantly
weaker than themselves

android paralysis ability that turns someone into metal?
majin paralysis ability turns people into candy?

make so cant hokuto someone while you have them grabbed

ascension happens too fast

rebuild rsc cuz lssj aura is bugged

ignore tournaments setting

make the stretchy arms work for punching people too if you hit attack instead of grab

make skill tourny have higher prize than regular

make knowledge cap NOT fluctuate, instead make it as if its a player and it gradually goes up if the
average bp is higher, and then does not go down

people spawn with 0 energy its annoying

android planet should repair androids there with nanites automaticly

should be able to SI to people if they are in a house you built

orbital cannons need a defense system if anyone attacks them they need to go crazy killing anything
nearby with lasers

make 3rd eye users weaker against taiyoken
and be able to see with eye injuries

some noob was grabbing someone during a fight to be invincible, you should not be able to attack while
you have someone grabbed

i need to be able to hear people im observing

maybe androids need to train off 0.75 cyber for each +1 base bp

make majins get some unleechable bp from absorbing and they must work it off legitly

if tabs are hidden they should stop updating to save cpu

there needs to be goals beyond getting powerful then hoarding everyone's shit for yourself
	maybe benefits toward being a sensei to others

bug: omega kb goes on cooldown even if you miss
cooldown too long?

give modules/cyber bp a slight bp gain penalty again

cardinal kai gets limit breaker maybe replace it since its alien only

hate engine module where if people get angry near an android the hate energy is converted to health/ki

admin controlled unteachable skill list

add whether a race can breath in space to race guide

race restrict these skills so certain races cant use them
	splitform
	materialize

put ascension mods in race guide


bios suck so give their forms some hbtc bp like upon absorbing any android that androids cyber bp is
added to the bios hbtc bp as long as their hbtc bp is under a certain amount

spirit room where you choose the planet you want to go to and you are taken to a map where npcs
are generated that are powerful and you must fight them

bring back the play music command to play built in dbz songs for dramatic effect at times of their
choosing

add the target practice training that vegeta did in the gravity training and also it fires back and if
you dodge it you gain defense. if you hit it you gain offense.

improve multi sparring by making it so you dont gain if your last attacked is more than 20 sec ago

redo the blast obj's beam() and bump() functions

people arent suffocating in space any more

code an artificially intelligent Freeza!
	actions
		recruit henchmen and remember them
		let henchmen have small amounts of his power as rewards, up to a certain amount
		kill anyone who attacks him, maybe send them to jail
		make henchmen hunt bounties
		conquer planets
		declare himself emperor of the galaxy so everyone knows
		put signs around that say he is emperor
		attempt to respond to things people say to him
		blow up planets if they become too much trouble

manual absorb does nothing because borgs dont leech

remove the specific bp requirement of planet destroy's message and just say
"you are not strong enough" because people figure out the strongest person's bp using it

when you try to inject a dead body with t virus it says they must be knocked out

write the perks of alignment somewhere in a guide

a dragon race, each time dragon balls are used they are unlocked, and they gain power from each use
of the dragon balls

remove make fruit timer

put geki and kaaken in learn by default
andmajin and mystic and others

add potential mods

make a skill's taught var = the person who taught it instead of 0 to 1

you can stack binds on smoeone by forgetting then relearning bind

what if walls had health again but they also quickly regenerate that health in like 3 seconds so
if you cant bring its health to 0 with that system you cant break it

let admins set revive skill timer

enable hell penalties but tone them down so people can still function some

stabilize the tech cap

can stay in FR if you telewatch to someone in FR who has telewatch on them

the highest lag causing thigns with 100 players
	Blast/Del
	mob/proc/Stat_Sense
	text_overlay

make ai training use a zenkai like cooldown system

admin verb to customize db inert time

exgen leeched my entire 300k base without ever coming into contact with me using UP and fruits
rethink that

make blood bags support cured blood to turn them to normal

make npc hbtc drops more noticeable, flashy

Vote Purpose: this game has become too much about who afk trains the long
est
Vote Results:
Yes: 5
No: 1

make unbind timer not use years

change logout timer to use last attacked not whether you got damaged

30 / 76 had kaio teleport

make majins cant be cyborg and have no dna

10 to 4 voted for kaio tleeport for kaios only
but regular kais need to be able to get it, not just ranks
but then people will just use kai alts to travel

give races an absorb mod and races that arent natrual absorber have <1 mod
put that info in race guide

splosions from PD destroy turfs but those should be turned back to normal after PD completes
use overlays

1) redo stats on droid 2) put points in stuff 3) relog without hitting done 4) you now have more
stat mods

explosive rapid blasts are bugged because you fire 2 at once and they collide with each other
immediately and explode

teach timer mod verb admins

make cant amulet when KO

make cant SI away when KO. make SI cancel if KO'd

make destroying vegeta destroy atlantis too and vice versa

you can bypass nearly any level of death regen by applying full injuries before absorbing them

let people keep dna containers when they extract t injections because otherwise its like paying 20m
per use

dont let KO people use SI

make moving cancel im trapped

add falcon punch type chargeable melee attack

save all player settings to a file that applies to all servers so they dont have to keep redoing it

the cave on arconia is immune to sense cuz it doesnt have arconia area. the cave is in the southwest
on a small island

put atlantis on kaio teleport list

make precog only kick in if normal dodging fails

a potential mod for unlock potential for different races could work like, if its 1.5, it cycles
thru all players on the server and the first one it finds that is closest to 1.5 theyre your UP
target

make telepathy and observe use the SI list so that you cant just use it on anyone

diminishing hbtc returns based on the ratio of your base bp and hbtc bp?

when people spam rage their anger goes below 100?

technology that is like kaio teleport. bolt it in public and people can use it to go to any planet.
make it cost a lot tho. public teleport network

make troll respond to 'go away' and 'leave'

bring back that system where turfs repair themselves?

make trolls rape people
and grab people

make troll show resources and have retardedly huge amounts

fix troll npc spam response

buff ascension
	saiyan base 100m
	saiyan ssj2 470m
	saiyan ssj3 775.5m
	ascended 400m

deadzone seperate map, dangerous npcs or other conditions, dont age while there, and recover fast,
dont stay KO'd long, etc

give kais natural mystic unlocks? and demons natural majin unlocks?

people become immune to dna extraction if they click yes to join tourny even if the tourny hasnt
begun yet

remove shrapnel check from blast del to see if it helps somehow

make absorbing take a bit of time

make it so that if anyone has higher knowledge than you then you can still increase your knowledge
past the "cap"

make cant attack if grabbing someone they use people as shields

supposedly when you make jungle alien you put points in def but you wont receive raised def

why is sense tab using so much cpu when 100 players are on?

fix telepathy spam

absorb/sd shows real key not disp key

if someone attacks their master while they are still in happy mode the troll defends their master

custom ki attacks

nerf stun guns
	make them slow down the person each shot not freeze them

admin verb to set how long til binds expire

admin teach time modifier

admin toggle dust

put a optional prompt asking new players if they are here for RP or PVP

make PVP verb set pvp=1

put a timer on the +300k rsc that if you made a char in the last 10 min you dont get it so people
cant just remake drop the rsc then do it again

dash attack bypasses precog

name the admin observe TO admin observe

super hearing for namek/aliens lets you optionally hear all talk on a planet

doniu bugs
	body swap into a logged out body and it duplicates that body when the person logs back in including
		items and resources
	make no inject people at tourny
	if someone with dbs gets body swapped the dbs disappear

fix turrets being at tournament

make so can never reach full grav mastery its an endless process ever slower

non pw doors arent bolted

remove long vampire message

disable force fields in skill tourny they are OP

auto face opponent when zanzokening around

upgrade for scouters to show actual stats of the target

transition from train/med to fly

bolt biofields

dragon ball wish to restore youth

ki needs just as much knockback as melee so there can be some actual back and forth in a melee vs
ki fight, instead of the ki user getting walled over and over from the melee knockbacks.

league expel dont work

cap attack barrier blasts at once if you go in regen that heals energy you can crash server

infinitely upgradable dojos with diminishing returns to draw people to that location

think up ways to make people gather to certain planets whether by force or because they want to

AIDs

scientific ways to keep people on a desired planet, positive and negative
	expensive technology that will, upon a person's death, prevent them from going to the afterlife,
	keeping them on that planet

	an orbital cannon that can be built to hover around a particular planet and blow up ships
	to prevent people from leaving

creation/destruction of blasts uses 6x more cpu than the next highest thing an optimization could be
that instead of destroying, send the blast to the void, and instead of creating, just use a currently
unused blast from the void
maybe each character has a tmp list of 100 blasts that rapid fire attacks will just use over and over

bring the stats of all ki attacks closer together for example blast does like 5% damage and charge
does like 100% it's too crazy, some ki attacks are just useless

limit each custom buff stat to 2x to reduce the whoring of all stats into just 1 mega stat
nerf 91% force whores

new passive skills in learn:
	immune to time freeze: 200 sp
	immune to paralysis: 150 sp
	immune to poison: 50 sp

a hard way to escape prison that only the strongest + most skilled can achieve

bail people out of prison by paying way more than the bounty price to the prison?

make someone able to be the prison owner.

admin ability to disable planets

make it so players can build their own prisons
	anything that displays coordinates in a prison malfunctions
	teleports cease to work
	cant see what area your in when right clicking
	observe doesnt work in prison or for people trying to observe anyone in the prison from outside




a verb to disable friendly fire on fellow leaguey weagueys

when villain is killed personwho killed him get villain

make telepads upgradable to 1x average bp

maybe SC dont lower base bp but you lower their potential

make kaioshin who a Who tab maybe only on kaioshin planet

make things made in science tab inherit changes edited into items in the science tab that admins did.
basicly make blueprint of it when making somehtiing out of science

when an explosive shuriken collides with one in front of it it doesnt ignore collision and pass over
it like its supposed to. the explosion is interfering, causing it to explode and delete

you can shuriken when ko'd

bug: projectiles that hit walls they cant break thru are just staying there

blood bag suffix = drinks left

 .Gun_Points "+" "Points" bug?

when you swap into a packer's dna you keep their ai training. make fruit too?

admin adjust global npc strength
let host adjust teach timer length and bind time length, and disbable im trapped, for RP reasons
upgrade cap modifier for admins
add the option to give custom buffs static bp in edit so that RP people can have custom trans

demons kaislearn mystic majin on their own without needing ranks

you can spam attack someone byholding attack during hokuto cuz theres no timer so you can KO
someone easily

make time freeze more like show. a field that if you step into it you are frozen

make jail time carry between characters

each time a kienzan slices thru someone it needs to lose power til it cant slice thru them any more

people crash servers with drills limit them to 500 and trying to create them in a stack cant happen

make cant get first ssjon tier mode til year 15, 30, 45, 60, or something like that

make immortality go away when killed

turn blast/shuriken into a toggle so that you can run and shoot at the same time

buff
	make time freeze not scale so much to whatever stats it uses
	mystic
	majin

make same guy cant have hero and villain

bios cant get forms on tier mode

 I've told ya like five times now but melee pack leeches unleechable BP Mod.
 Also, the mating bug where you can get any race with 2.7x BP Mod still exists.

can telewatch to someone in FR

shuriken set refire. slower = more damage

USSj can be once you reach a certain base bp but dont yet have ssj2 you can power up twice again
and go USSj like an entirely new transformation, and, USSj2 maybe?

bug to grab ungrabbable things: rename eomsething grabbable to same name as ungrabbable thing put
it on top of it then you can grab it

fix scatter shot so you cant shoot yourself with it without a prompt

dead bodies are deflecting beams

final match never happens on uneven tournaments

triple wide beams
beams take a steady % of ki like beam takes 0.1% per sec /kimod so piercer is 90x more so 9% per sec
maybe all ki attacks do that. rapid blast probably only 0.01%

restore youth, db immortality, and sc life stealing, makes people able to live forever, especially
when they can just sc life steal an alt who just remakes a second later

turn sc into decline stealing and like if your decline is 30 and you take 30 decline from someone then
you get 30 so your decline is 60 but then you steal 30 more decline you only get 15 so your decline is
75, etc, that way they cant be immortal forever

racial bp mod tiers like alien would have same bp mod as saiyan but start with higher bp but when
saiyan reaches like 10k bp their bp mod goes to tier 2 so they are better than aliens then nameks
become better than saiyan at like 100k or somethin

telewatch cheats regen timer?

non-stun ki attacks should cancel stuns done by the ki attacks before them! melee should cancel stun
too?

make SD not go off so fast so people can actually avoid it sometimes

fix hover chairs, instead of equipping them, when you bump into them, your char's hover_chair var is
set to it, when you hit a movement key it moves the chair instead of you, and when the chair moves
your teleport to it

make having multiple force fields active (sheild, ff mod, ff item) causes none of them to activate
due to interference. including carrying more than 1 ff item at a time.

steroids/lsd/t injetions need their dynamics changed to where they are shorter lasting, effects
arent permanent they go away when you die or can otherwise be undone, perhaps have addictive withdrawal
symptoms for steroids etc

make t injections undone with death, either that or remove forced injections that ruin chars

defense should auto dodge grabs

display grab power in stats tab and moving will take away a set amount of grab power so you escape

if you grab someone from behind the grab will be strong,otherwise itll be weak

if someone grabs you then you shockwave it will cancel their grab regardless of how much more powerful
they are than you. its a bug

redo grab graphics so that depending on if you grab someone from behind itll look like you grabbed
them from behind, usepixel offsets.

make moving slower when grabbing someone

make so when someone revert a buff they cant use another for 1 min

make spam killed pople not KO

make scattered dbs not land on water

maybe int booster doubles learning rate?

convert ssjable to real time

if you log out mid hokuto your mods get buggedpermanently

make pixel movement at least work?

make exgen invis in admin who

leaving science tab open is dumb add some kind of knowledge training like meditation basicly

spacepodsdont show the key of who killed a person

athy)the adasda: Make Unban All, Unban Single and View Bans as illegal names.

obj expire_time var, which is set to the realtime that the object should delete itself. expire time
can be assigned on death drop and manual drop. then when item save happens it deletes all items
that have expire times past expiration

Oh cool, thanks.
Btw, uhm.. There was a problem earlier.
Cus.. you can crash servers.
With pods.
And explosive guns.
10x Refire, 5x Explosion, put 5 on a pod
shoot 30 super explosive rounds a second.

k so
get devil mat
med on it
get an auto clicker
set to 1ms
stat-focus on speed
then turn it on to click meditate 1000x a second
and your speed goes negative
breaking the speed cap and stat cap
thats the closes explaination i can give cus
the person who found it
has a mouse with a "triple click" button
and thats how they found it
i think thats how its done one sec
Also, countdowns need to be on logs.
Spacepods still dont show the real identity of the killer.

admin choice to disable im trapped

teach_mod, how good a teacher that race is, decreases teach timer, humans the best, better than
tuffles.
decline lowers teach timer a bit?

rank-who shows who has what ranks

admin toggle weather

hbtc increaseknowlegegain

bp mod "stages" could be used to make things more fun, like stage 1 aliens could be stronger than
stage 1 saiyans by a bit, but then saiyans get better than them at around 10k bp

make bp multiplier and other bp "gain" increasing things show up in the stat panel bp mod thing

admin ability to modify severity of move delays

instead of randomly dying in space, have air displayed in stats tab
t virus injection to make you breath 5x longer

cyber force field sucks ass. it uninstalls itself each time its drained too. make it a timer instead like
ki shield
cyber force field could do 50% health damage and 50% ki damage, instead of channeling 100% to ki damage
also instead of inheriting its effecitveness thru energy mod it could inherit it thru something else

Also, disable grabbing in TFR.
Also, make it so you cant teleport to people in TFR via drones.

.Customize_Gun "-" "Points"

admin disable genocide

make majins take on characteristics of those they absorb and depending on the race of the person they
absorb their icon changes to one of the other majin icons too
if they gain any power from the absorb, they lose regen/recov to compensate. store that extra power
in a var called majin_power

convert Saiyan leeching to real time OR just remove the timer and require the Saiyan to reach like 85% the
same base bp as the Saiyan they are trying to leech it from

automatic wall upgrading machine. can reach 85% of the upgrading cap then upgradeyour walls
cost 15b

make ships not can_blueprint cuz it wipes interior and turrets to abuse into the ship

you can open kaio teleport prompt then as your fighting teleport away even with low energy

prompt stack change alignment to bypass timer

make shockwave use half str half force for damage so melee specialists can use it in the same
way that superman does

give someone a dragon ball in sz and you can kill them

dash attack ignoring shield
shockwave too

convert unbind to realtime instead of years

dash attack and SI and beam SI need to update SZ status

candy ray. can forcefully absorb anyone less than half your base bp AND bp at the time of absorbing.
can absorb crowds of people at once too.

mass curing diarea wont help cuz people next to it instantly get it again

make it so when grabbing someone you can not attack or blast because noobs bug abuse to hold an alt
during a battle so that they can not be harmed

make genocide not go to people in tournament

when is hero has 100% chance for ssj4 instead of 50% when black moon is used

make ai training spar a real player if they are in front of you

body swappers are getting the soul contracts of people they swap into

body swappers are keeping the temporary bodies of the people they swap into when they relog

when a victim of body swap relogs they get rollbacked and "bugged"

supposedly when you body swap into someone then use an alt to offer the temporary body a soul contract
you get the soul of the actual victim not the soul of the person inhabiting the temporary body

i tested it and when someone swaps you then logs out you have your original body but then when the
swapper logs back in your immediately sucked back into them again. this stems from the problem that
upon relogging they arent supposed to even have the temporary body any more in the first place

ssj3 is the strongest thing in the game because it stacks with transform + 2x bp buff and then when you
get angry the drain from both of those things don't matter

when you log in (idk if new or load) you dont get SZ protection til you move they say

bug: make a ship get in it have an alt destroy it then log back in it and make another ship in the ship
and now you have a ship inside a ship of the same ship that was destroyed

make im trapped fail if your mob is in another mobs contents like body swap

anger breaks free from paralysis effects?

if you kill someone before SD kills them they double die and lose potential

nukes NEED to be planet wide!

the range of usefulness for weights is too narrow. even if you can lift 5000 pounds you should still
get even a minor boost from 20 pounds even if its +1%

there are too many npcs cut them down by at least half even players voted its true

people clone jewels by putting them in droid bodies them duplicating the droid.

BUG: jewels can be combined past the 1.5x boost. 1.5 + 1.5 creates a 2.25 jewel

no build certain dist of sz if on

make race spawns not change so easily Saiyan keep spawning in heaven

a new way to gain knowledge other than leaving the science tab open and also you cant train physically
while gaining knowledge its one or the other
maybe if you meditate next to a study desk/book thing, then instead of meditate being physical
training it becomes for knowledge

maybe remove the evil penalty and hard cap the ratio between good and evil and remove mark as evil
hardcap it because the penalty is obviously not enough to prevent people from overflooding evil

save fps to misc.

make no change icon fighter spot and tourny chair

nobody uses clone tanks to come back to life because they are worthless make them better. like
perhaps they make you 1% potential and have less permanent negative effects
its the only scientific way to come back to life and its not worth crap

INF sound comes from shields

exgen says kaioken is worthless because you can do the same thing by making a power up buff
and it will actually be better

make scatter shot not target yourself without confirmation

make kaiok teleport steachable

when angry, full potential is accessed temporarily

put a timer on using mark as evil

you can absorb/bind/bite people in tournament if its your turn. right after your enemy gets knocked out
you got about 5 seconds to do it before the next match starts. I think this means you can still
shockwave in tournament too

when mark as evil is used make it expire after like 12 hours

when turds reach their destination their moving loop doesnt stop

with shield up, kikoho does damage twice, presumably cuz of the multi tile collision

time freeze should be disabled or have much reduced effect when borgs/droids use it because
their cyber bp isnt lowered by it

king yemma rank, decides the rules of heaven and hell

you can stack teach prompts to bypass teach timer supposedly

when evil people spar good, leeching is halved?
maybe when any opposite alignment fighters, leeching is halved

let evil alignments get a small power boost from makyo star?

when hell vamps bite someone with cured blood it should not cure them but also the person
they bit should not become infected either

make some new t injections with more varied uses than the current ones
ones that affect leech, zenkai, etc maybe

make upgrading weights cost exponentially more based on how much weight your giving it

when you press fly you should auto stop med/train

make ai training work with peebags and sims

make sparring alts be like sparring npcs

tournament for some reasons concludes with some people not even being able to fight

make so even if you appear dead if your body is still intact you will come back to life like a 20% chance

multi tile beams

a reincarnation altar in heaven but the catch is that you must not kill anyone who didnt attack you
first for 1 hour if you die your binded to hell

finish the demon altar where you can come back to life as long as you kill 1 living person per hour
when you die the contract is again broken

more alien perk choices
like ability to distribute stats among leech rate, zenkai, mediation bp, etc

during alien perk choices not all perks are equal so instead of only being able to choose 3
you have perk points each one drains different amounts til you cant afford any more

make peebags better nobody uses them

ability to give bots orders like:
[bot name] kill [player name]
[bot name] rob [player name]

you can stack limit breaker by using it then swapping to another body then back to the original
and hitting limit breaker again to get insane temp bp. Bios use it to trans at year 0

you can apparently stack "sacrifice your own life" prompts when reviving multiple people way more than
intended

death ball works even when ki is all disabled

you can supposedly stack dash attack by using a 2 tile zanzo macro and do it back and forth
over the player in the middle

make shockwave only work on the tournament opponent not the nonfighters

splitforms can attack you if they have the same x and y but diff z

people click redo stats 10 times then keep putting points in energy to have perma bugged INF energy

put character limit on telepathy so you can see who is spamming you

sz no longer prevents body swapping

people use redo stats to put ki mod to 6.5 then lower it to 1 so they have 650% energy to have insane
temp bp

make robotics tool menus not stack

bp bug
make sim
sim bps can go so high
get in sims body
you have sims epic bp now
make it so you cant brain transplant into sims/splitforms/other mobs that shouldnt be able
and also not able to get dna from them

make tournament tiles have INF health so cant be destroyed cuz it interferes with keeping people out the
arena

fix race fusion

fix scatter shot if the blasts get stacked on top of you they just dont do anything

make after images not saveable

add a topic on ascension to the guide

on modless the race guide says all races have stat mods of 1 fix that

make dea dpeople no can get inuured

you can remove modules if you dont have enough money it lets you anyway you go to neg rsc

make nuke not work in tourny

make nuke not destruct space tiles

make can put nav IN the ship so you dont have to carry them on you

player made tournaments?

make it so a player can own the tournament and own the prison and make money that way

UP no longer works properly cuz it doesnt do attack gain so when someone loses potential from
reincarnation they dont get any back. maybe make it so you cant use UP til 5 years after you learned it

redo nukes instead of using the icon it currently uses make them use the sunfield geneator
big circle icon and efficientize how they work so they arent laggy any more
MAKE NUKES NOT LAST LONG BUT SPREAD RAPIDLY AND GET IT OVER WITH AS SOON AS POSSIBLE
THEY DONT HAVE TO LAST 10 MINUTES TO COVER THE ENTIRE PLANET AND DO THEIR JOB
GOOD IDEA: do a thing where nuke fire starts at the turf the bomb is on then spreads to the immediate
turfs around that one then to the ones around those, exponentially, disappearing along the way

make attack barrier kb togglable

when you die of zombie infection not only does your body become infected but you shit out
like 5 mini zombies who cant reproduce

namek start sense

make only 15% of population need vote not 30%

make cant brain trans to splitform etc

you can lower person stats by leaving prompt open even if they are miles away you can wait an
hour then lower it

make so dna containers in a person's contents arent cloned using dna/blueprints

you can prompt stack learn to teach things with no cooldown to multiple people

if you swap really quick between an android then back to your original body it bugs and thinks you had
packs on the body you swapped out of

code player npcs that are indistinguishable from real players. speaking more intelligently than trolls

if you relog during wishing you get more wishes?

make alt leeching toggleable by hosts

make hbtc time leechable so that it cant be spread?

(Admin)EXGenesis: There's another android bug.
(Admin)Tens of DU: k
(Admin)EXGenesis:
 If you Limit Breaker than swap into another body
(Admin)EXGenesis: then keep repeating
  that between 2 bodies
(Admin)EXGenesis: you can hit inf bp

make hokuto kill death regeners if powerful enough

if your inside hbtc and you build stuff as you exit it'll replace the entrance or exit and nobody can
get in

dupe items by putting them in a blank android, blueprint it, then destroy it
hokuto still doesnt work

BP BUG: generational hbtc gains. basicly train a char in hbtc, make a new char, leech the old one with
soul contract, and repeat


when using a homing attack make the camera go to the attack so you control it as if it is you

make people with eye injuries less affected by taiyoken

ability to view prisoners using bounty computer

admins can disable use of alts

the IP is..
199.19.115.180
also, I have multiple backup IPs for the shell if you want to code them in.
just so the game has fallback methods in case one IP is turtling.
208.93.154.47
208.93.154.37
Both backup IPs.
turtling means it is blocking connections to that IP because of a ddos attack but the backups are still
good to use

melee pack leeches unleechable bp mod?

Just a suggestion on balancing defensive builds.
Currently, tank builds are ineffective because of the diminishing returns on damage resistance
Maybe if dur/res is higher than the str/for then it should swap back to the linear formula?
Which would encourage people not to build glass cannon?
Gabe Schoonover says
yea that may work ill put it in notes
Lewis Spiers says
Also, alot of ability descriptions are outdated.
And Makosen needs a shorter charge time.
Oh yeha.
Also, knockback works even if blast is deflected.







0.1 refire blast is having a squared effect because higher damage and higher offense says Lewis

fix afk tournament bug
rp council boost verb highly ineffective

a thing to label someone as an event character they will gain no bp and not count toward upgrade cap

vary races some more like more preset stats
disable zanzo during dash
ai training needs to account for when you are knocked out
make shockwave bust out of grabs

cybernetic absorb where you grab someone and hit absorb and it drains their energy until they escape

fix add log note

host a text file on my byond account to ban peoples keys and ips and computer ids

make drones stay away from safezone

make auto pilot navigate around undesired planets

make guns rename their shoot verb like buffs rename their verbs its way mo betta

admin able remove skill from learn

absorb desc is wrong and rethink it anyway

make so if tab changes out of build you stop building

make sure im trapped will not send dead people to their living world spawns

when you punch npcs they dont die if your have it on nonlethal they should die anyway

admin verb change bp leech modifier

put a system where depending how long you stay logged out you get a boost to training because it
should be about -how- you train not -how long- you train

ginyu body change could be made possible using a similar proc to duplicate except it is an exact_copy
and it is stored in a var on the temp mob and 10 mins after the swap you go back to your normal body
stored in that var

make sure you have to be alive for decline bonuses

recode the power control loop/etc
old way:
	guy with 1x recov/energy mod has optimum powerup of +30%
	2x in both is +120%
	4x in both is +480%
	5x in both is +750%
when it should be:
	1x in both is +30%
	2x in both is +60%
	4x in both is +120%
	5x in both is +150%

shield doesnt block dash attack

recode majin and mystic, possibly to be custom buffs. mystic can use a 'no trans drain' attribute.
put a var on custom buffs for 'unchangeable' buffs such as mystic etc

test power up for OPness

people start giving power before tournament and cheat

FUSION

fix admin tab not showing if people hide energy or are droids

make kaioken aura a bit bigger

make kienzan not able to kill death regeners. it only cuts people in half it cant kill death regeners.

make sparring alts with same comp id not work

absorb is useless for people with cyber bp. absorb needs a perk for cyber beings

kill counter

afk in tourny bugs it
in spacepod when tourny start bug you

everyone should be able to get breath in space somehow
maybe as a t injection or just simple dna computer alteration

you get stuck in a body when you body swap and they relog

buff stacking is apparently very serious. guy says can buff stack from 11k base to 3m bp

rename dragon balls to something more ear pleasing

make npcs verb save to save misc and they stay booted always

make auto train face splitform if not

auto attack isnt working on peebags

firing 4 blast at same time for some reason only fire 1

redo anger proc/vars

unify all anger increases to use the anger proc with a arg passed for how angry theyre getting as a
multiplier

redo melee proc
redo projectile bump proc

kienzan should destroy itself if it hits a mob but causes less than 100% damage because you can keep
moving it thru people much stronger and knock them out its OP

you can put doors in front of ship panels and nobody can get in the ship
you can grab the door before entering the pass then enter it after you move it

make shield center large icons

check out join_prompt for tourny it isnt alerting people that the tourny already begun and such, why?

people shoot sokidan thru walls

make a kill counter that displays to a person 'you have killed n people' when you kill someone

uninstalling module send you neg rsc

majin no allowed use mystic or kaioken

make no stack mystic + kaioken

make so cant lower someone stat with dna against their will unless really expensive

the more wishes for power you use the less you get like fruits

apparently fruit abuse is a huge deal

make fruit a 1 time only use?

make voting restricted on comp id so diff people on same ip can still vote same time

remove about half of the npcs

absorbing someone thru SC should not cause death enrage for the absorber
SC death enrages the person who died giving them ssj

make so that if a dead Kai/demon goes back to heaven/hell, which is their home, they get most of their
available power back instead of being stuck at 30%.

make android no diarea

make so if have dbs cant be in sz cuz its lame that nobody can steal them from u

BUG: you can lower someone's knowledge using teach knowledge

make buffs able to replicate limit breaker and kaioken and alien trans with static bp

FIX INVINCIBLE SPACE PODS MAKE ALL NORMAL OBJS TAKE GRADUAL DAMAGE AND ONLY BUILD OBJS USE THE 1 SHOT
SYSTEM

make Commas proc say 100 thousand etc

MAKE SC A RACE EXCLUSIVE MOVE UNTEACHABLE BECAUSE Saiyan SHOULDNT HAVE IT THEY ARE JUST
MONKEYS WITH SUPER STRENGTH

Newton378: well
Newton378: you need SC, an alt, and a char with fruit
Newton378: you SC you
r alt and alter BP up, then have it eat a few fruits
Newton378: remake and repeat

make battle ships more do-able and actually effective

Make killing/stealing in heaven impossible because of tournament killers

Doniu: 41. Make turets canont be grabbed

Doniu: 34.Add module Android Radar it mean Android got insdie radar and can detcet something or add
android can absrob radar likie Giru did  . something using Giru idea

Doniu: 43.Make a option to Admins to enable/disable use shurikens/gun in tourney.

res duping with body swap and genetics computers to duplicate the stolen body
sims can be cyberized
lemme get the file with the rest
You can use Mate to get the Spirit Doll class on any race.
You can use that to transfer BP mods onto Spirit Dolls too.
eg. Demigod BP mod on Spirit Doll baby.
splitforms + genetics comp = infinitely stackable custom buffs

when someone gets knocked out it saves a backup of their character and admins can revert them to the
backup if they are nonrp'd

Also, there's no cancel option on bans.

We need the right-click and ban option back :/
Maybe have the old ban verb back
then have a ban-options verb
for View-Bans
Unban-All
and Unban-Single

you can rename yourself
to Unban-All
so if an admin tries to ban you
it removes the ban
*bans

I one hit KOd somebody 125x my BP
Limit mod multipliers
on custom buff
cus
i just took out of every stat except bP
put it all into force
walked around with 30x force mod
only trained force
for an effective 210x force mod
and just one-shotted people with AoE
because they couldnt react.

add an admin option where the first ssj MUST be given by admin there can be none before.

make the host check not only in openport but as a loop too so that if exgen bans a server it doesnt have
to wait til a reboot/rehost to check if its banned and act accordingly

<--(9:54 pm) EXGenesis: Small suggestion. Make skills have a Teacher verb, so admins can track who taught it. It'll help with catching alt interaction alot.

make sim and destroy sim dont need to be choosable options the prompt itself is entirely pointless you
can only have 1 at a time

make admin4s able to turn on 'choosing alignments' during creation. you can only change alignments every 20
years.
	if you kill someone good when you are good you will lose power, or lose something, and be labeled evil
	make ranks have alignments where they can only teach people of the same alignment.
	good people can only bind evil people
	good can only revive good
	good can not break in to good walls
	good can only steal from evil

make Icer not lose hair when transing

make can reprogram telepads. but only if your knowlege >= creator's

seperate the PVP verb into All races spawn on earth and Toggle admin voting

if you log out while someone body swapped into you then you bug them

make meditation bp drop off heavily after youve been afk for 1 hour

explosions move spawns

fix ship in a ship bug

make so cant get ssj using buffed bp cuz you can go to x7 your normal bp to get ssj

review admin5 verbs

Add log note isnt adding a note

Body Swap Causes a player to permanetly lose skills tab and if the body is destroyed it deletes a the swapees body
You can Precharge Multiple Kiezans

log bp multiplier

make the transfer of power from SC like 90% not 100% because people are zenkaing/etc heavily then reviving
then the guy leeches their bp then they soul contract another and do it again

make decline not update while using custom buffs because you can put it all in ki to have ridiculous decline

Also, as a suggestion, would it be possible to get options to add pixel offset to the overlays from
custom buff / alien trans? (make it work like Custom Overlay)

learnable things:
	gain bp from flying
	gain stats from flying
	gain sp from flying

if 2 people wearing weights race fuse the person has 2 equipped weights and cant remove either

unlink lifespan with energy gain and instead make it a learnable meditation ability to increase life span
while meditating (no need to focus, it happens on its own after learning)
this may lead to the removal of original_decline
starting decline could be randomized considerably but using a new formula for increasing life span
it could be equalized in the end cuz it could be like:
lifespan+=sqrt(lifespan) so that it has declining increases

Make when a person first creates it auto binds them to the spawn they chose because a person can make a
hell demon for example then use Im Trapped to go to the earth demon spawn

8. Make a first-time SSJ transformation graphic, similar to finale PvP, where the hair flashes

stat bug people race fuse with their clone over and over back and forth for the 30 mins of stat gains
it gives and the stat combining before that was disabled

make people unable to get SSj while buffed because a person can put all custom buff points into BP to
get all SSj levels while their base is only like 1m

make mate not give them ALL the stats just most of them cuz people are eating fuits/upping then laying
egg remaking and repeat

make blueprinted mobs include the price of the things they have in their inventory because they keep
being duplicated freely

9. u can use dragon ball alot of timies by clicking wish wish wish spam and make alot of wishes

3. when u ship is destroeyed u can make u ship in that desotryed ship and be safe so no 1 can come

14 you can make a split in the blank of a ship and brain transplant to the split for to be in a other ship

make prison money wipe

.add new wish for dragonball work likie youtheisa it lower year to 1 or it just work likie youtheisa,
piccolo daimio used this be be younger in dragon ball

2. if planet got desotry u can wish using lizard sphres, dragon ball to resotre planet that usefull when
somone use nuke

Make prisons made by players! you can earn money from prisons thru the inmates. and other ways too perhaps
players can bust out if you dont upgrade it properly

log playfile

make vamp bp boost based on hunger

a computer that will place automated bounties on people using money you put in it, where you can have a
device in all your walls that if someone hacks it or breaks it it puts a bounty on them

make so cant continue icer creation til choose all form icons

make no brain transplant people against their will?

player spawns prevent normal spawns

ability to sense observes

make bounties also sort by most valuable first

instead of having seperate objs for hairs/icericons/demonicons, etc. just have an icon list and it
makes  a bunch of copy of 1 demon_icon/etc obj so there isnt so many diff objs in give/make/etc
also its just better

a melee attribute where you do low damage but drain their ki by a % weakening them

make regular people able to access kaioshin planet somehow

make no build within certain dist of spawn

clones should not have soul contracts

make ship obj in ship tab so can click it when cloaked
turrets are being used in tourny still

when you relog in death regen you dnt get sent back to your right place your stuck in FR forever

make host_check on a 5 min loop as well as in openport so that exgen canban/approve hosts without
them having to reboot to do openport
add support for port approval too

make so cant colorize turf objs cuz inflates item save

FIX TOURNAMENT KILLING!

new verb_path(Destination,Name,Desc)

make fart storm emit flies as a shield again. the flies slow enemies down but not you
they swarm the enemy, not stay around you?

just link my admin to 1 key and my computer id instead of like 20 keys
link get icon to my comp id too and 1 key

let RP president give ranks if no one has that rank already?

just make it simple where nobody in a tournament can be killed period. there is no need to check if the
person trying to kill/etc is in the tournament

stop spam ssj transing gfx

more alien ability choices

make precog teachable? long teach timer?

make alien choose aseuxal or not

make explosion gfx look better

remove perma death and add more advanced death options:
	die and lose power
	die and come back to life and sent to spawn immediately
	die while dead and lose power
	die while dead and forced to reincarnate
	die while dead and come back to life and sent to spawn immediately

bounty hunting technology
	tricks
		hologram tricks them into getting teleported to space jail where bounty can be claimed
	traps
	locaters

more incentives to use bounty system
	BP reward based on the power of the person killed
	maybe upon 'death' instead of dying the person is sent to 'space jail' or something

ability to make factions/groups/whaever again

make turrets fire streaming lasers that draw a line to their target instead of just shooting missiles

make an admin option that if you die twice you go to FR and the FR portal is removed

make turrets kill again
people using black moons to go ssj4 before they even have ssj1?

refigure stat catchup system. instead of slower then faster faster then super slow when caught up..
make it slow starting out, faster til like 0.5x max, then slower and slower til base gains
the sudden halt in stat gains seems to annoy players

Make a blind person not able to move full speed because they stumble over things which slows them

npcs are overly annoying

seperate the controls and entrance of a ship. make controls spawn an entrance like 5 tiles to the
right or something

make 30% of melee dmg come from force and 30% of ki damage come from str so that balanced builds dont suck

if sonic bomb hits ammo packs they explode and do extreme damage
paid tournaments
make sure avg bp leeching is relative to bp mod
make people afk more than 1 min in tournament lose their match
make training in SZ suck

set planet parent_type = /obj/Ships/Ship for android planet so it be pilotable
add some completely blank planets
make android ship pilotable

make RP logs more like admin logs where the entries are kept for 2 days or so

some sort of system to support good and evil character paths since the game is about good vs evil
remove most vote options

put copy icon, color, change icon, custom overlay, remove overlays into 1 verb called icon options, possibly in
customize
put ooc toggle in customize button, remove verb
put knockback options in customize call it melee options where it will appear with future melee options if any

make reincarnation or death from old age reset hbtc time
instead of disabling tabs after 2 minutes of afkness just switch their tab to a non cpu intensive tab
theres too many reasons to be evil and none for being good
an automatic blessing for the greatest hero? how can it tell good from bad?

make voting prompt tell you how much time you have left before you can vote
add some kind of interactive tutorial for new people

when you join tourny in pod or ship your view needs to change and ship=null
reincarnate needs redone?
dragon balls rescatter each time you hit the verb for some reason
make zenkai know who attacked you
make doors not prompt for passwords if they are not surrounded on at least 2 sides by unflyable walls
make so dont get multiple door prompts
make dash attack masterable down to 20%
make dash attack not 100% accurate?
technology that disables safezone fields
redo swarms if they get near safezone they multily to INF

if you fire blasts 1 tile away from the edge of a map the blasts are stuck there and you cant move because it wont
let you move if blasts are in front of you

A "god of war" power or something, that blesses a random person if there is no one online that doesn't already
have it. if a person who got it at a lesser year comes online then it is taken from everyone else cuz only
1 person can have it. if they are killed the killer gets it. you can tell if someone has it because ?
there would be a disadvantage against people who fight heroicly against you for example if they have at least half
your bp or something and they fight to the last of their health they are gauranteed to get anger, big anger maybe

people can get inf stat ponts by using buffs on the redo stats screen in creation so instead of having racial
skills given in the race proc they need to be given in a race skills proc that happens at the end of creation
like before

problem, ultra pack combine with leech pack is too much leeching
in ultra pack remove death regeneration and only give it to races that already have it so it improves theirs
maybe to gain voting power you must pass an intelligence test
make blast homing pick a target that is straight ahead if available
put limits on admin verbs that can crash the server
make so items can be gotten out of pod
alt leeching was to encourage people to log alts on to boost player count is there other ways to boost player
count by encouraging people to use alts?
when i used enter character my old character did not go away
a raise res instead of dur setting for armors?
the const says freedom of RP but the exception should be themed servers like people rping futuristic in medievel times
would not be allowed but it shouldnt be bannable just deletable or something

do some things that will cause a pwipe to update for
	put all buff objs under a buff category
		give them all uniform enable and disable procs
		give them all a uniform Buffed var to see if they are being used or not
give all equippable items uniform enable and disable procs
maybe implement the custom buffs system it doesnt matter if it causes a pwipe

make a thign admins can disable where its half turn based so you click a target(s) and hit start fight and it
does a countdown and after that you can attack them otherwise KO/Death returns

manual ban

COULD YOU MAKE IT SO THE BP cap only limits base, rather than current? I think that system would work better for
builds ment to Bp wall from buffs and a higher BP mod.

grab+attack = throw

overdrive can be spammed causing extreme lag

sense level 4 10 sp can sense everyone in the galaxy

redo turf/click
make turf upgrade "upgrade" say "increase durability"
an upgrade to scouters to detect droids 1 bil rsc

make aura overlay remove properly after relog use injuries as an example maybe

choosing hair at creation leaves you bald probably something to do with gray hair probably only does it to people
who start past decline

make all rare skills able to be put in Learn or be there by default and be removable/addable by admins to Learn

now that blasts home somewhat turrets dont need their own homing they can shoot real projectiles
make so pods/ships cant land on planet inside houses
for some reason player mobs are remaining past reboots they are being saved into something unintended
pods splode when hitting blanks
bounties placed by the game for certain actions
make sokidan able to hit 5x before exploding

gun projectiles spawn 1 tile too far ahead visually
try making map saving with associative lists again?

read if the host has any host bans if so shutdown til they dont
upgrades for regenerator durability to grav? the more grav its in tho the less it heals you due to the pressure on it?
when you press absorb while having a spirit bomb charges you absorb it and have epic energy boost
make majins have diiferent forms more powerful ones lower death regen
make bp_mult, bppcnt, anger, and ki>100% not count toward tech bp
spamming death ball bugs you
make docile npcs not crowd around you
because peple are soul contracting clones to get a person's soul using DNA unknowingly
make pods decloak when firing weapons
make pods able to be gradually damaged
have visited planets or planets you launched from added to nav automatically
make so when brain transplant viewx/y carries over and sets itself
make demons able to somehow detect jewel shards and know if a person has one
center icon seems broke on many things
make build nhot determin by age make it so you turn it on and a alert shows you how to use it
make a better who verb possibly using interface
improve trolls?
instead of having buffs multiply bp mult, make them add to it. so instead of focus x1.5, its +0.5
stun chips cna be used while in time freeze
beam deflection
make so you cant recover energy with active freezes in regen tanks
SD destroys objs/walls regardless of bp?
makosen will fire after charing even when your KO
ships arent clearing
when you log in KO your screen size isnt right
when you brain trasnplanet or mind swap your screen size isnt right?
text color is changed too

custom ki attacks
make force fields and shields block shockwave
make bp leeching use current bp to determine leech speed
should ki attacks have minimum percent drains that they can not go below regardless of energy and mastery?

make AI stop trying to reach target if it takes more than 5 unsuccessful steps in target's direction
a device letting you remote control androids you make
ability to pick freeform, good or evil, which has different advantages/disadvantages. choosing evil means you get
power and resources easily but are weak against good people, who knows what good means
make build cost resources
move get packs button to right of input bar
people using code to auto shadow spar. to fix make cam shift onto hologram guy maybe
speech bubbles?

ssj4 is unlock by death anger should it be?
bug: aliens are asexual regardless of choice
precog dont dodge beams
ships start at full speed and if you customize them you can add attributes which decrease speed for something else
native dp and jp races?
splitforms leech people? sims to?
when body turn 2 chiken u can pick it up
ability to make majins by magic?

science food
make npcs reproduce instead of respawn?
make stat catchip happen with sparring only instead of globally
UP gives residual gains still?
does zanzoken bypass turrets?

make ban work with right click
make change icon work with right click
make zombies cant fly over glass maybe nobody can
make a way to get tail back
make admin not ban higher admin
turrets need to shoot npcs
bio android children should be born at the same form as their parent so they cant stack it
pets
bug: zombies fly over edges when you fly
logout messages do not work
turn the stat menu into a full fledged creation system
exgen's icons need expand icons
make people able to choose to have alien transforms or regular alien
ability to choose custom expand/focus icons
sort races by popularity
make creation spiffier
make able unbind self
admins set max grav
capsules (expensive)
lower tourny prize
adminlog nuke+tvirus
a reason to establish a kingdom on a planet?
make a reason to be good
make better dojo stuff, upgrades, where resources go further towards making a useful dojo

add categories for the building system

beam attribute "absorb" where it drains the energy of the person and sends it to you

Vote Purpose: Namekians get a verb that lets them speak in a language that everyone else sees as gibberish to
replace the Portugese rule Lewis made lol
Vote Results:
Yes: 11
No: 4

if you use alter bp on soul contract then they reincarnate you can alter them higher than they should be to INF

make so you cant have your own soul from soul contract

make video tutorials

fix drones, make it so admins decide if drones can be lethal or not, and other stuff

Vote Purpose: First off: Bring back racial stat benefits. Second: Remove learn verb and re-add leech learning,
with limitations on who can leech skills. Third Tone down Majins a tad. Fourth tone up REincarnation. Fifth
change Kaioken to have two forms of the one skill one similar to Finale Kaioken and the one on this.

Vote Results:
Yes: 10
No: 3

make food never go bad

make it so bios need toa bsorb 5m+ borgs to trans
no global upgrade cap, but a power collection device that raises your personal upgrade level
redo AI but instead of using mob in view use mob in players if getdist < whatever
money spent on science should not just disappear into nothing, but be deposited somewhere. to cause inflation
heal all when tourny ends
droid/clone dont get change icon or voting
add ip ban to ban
the ability to make anything explosive with your energy then make it explode
make ssj halt recovery and have a steady but slow drain /recovery
make cyber bp not count toward upgrade cap
Namek etc gets increased hearing/emote dist
give players a who tab
soul contract life swap swaps any life of the soul you own to another even yourself
increase max ships
tell people when they get sp
make it so navs are boltable and can be used within 1 tile of you that way you can bolt them next to ship controls
does self destruct bust any wall?
make bodies use Duplicate proc so they can be used for DNA copies or whatever
pod customization
the max level of a cloak should be based on year, like year/10, and max 100
add a cloak self option to cloak controls? but it uses energy or something
make dragon radar its own object
a 1 time use intelligence booster, probably very expensive, maybe intelligence imprinting?
cant build in space (player voted) admin toggle? player specific?
make turrets lethal?
revamp self destruct
people who self destruct lose 10% of their bp? like majins...
add cancel to grabbing if there are multiple choices
fix the grids where the other things arent properly cleared
beam mode for guns
gain in fights by shooting ki at people if it hits them, but not guns
improve detection of who is fighting who in fights including ki fights
grav cap for admin
add redo stats
make so people who arent being hit in a spar dont gain
you dont keep bp from reincarnate, it sets your old bp as a cap and you gain faster til you hit it again
gete star
army system?
make senzus grow randomly on earth only on grass10 but very rare maybe 1 per month
make senzu growing different?
tree of might kills planet makes it unable to make resources
make asteroids actually collide with things again and maybe if they hit a planet there is an asteroid storm?
Mana(Cowdogs): Tens, forumula for infinit bp: Zombie Breed, zombies to desired bp level, take them over with a cloning machine, and spar them with another character
Mana(Cowdogs): Or just Sit in them while they are still a MOB instead of a clone, and gain stats and Sp at 5x the normal rate, even past stat cap.
Mana(Cowdogs): And transfering minds with them bugs fly until you relog usually, making it so you can fly infinitly, but gain nothing from it.
Mana(Cowdogs): Tens, I don't know if you fixed it, but cloning machines never transfer: anger, Death Regen, and Possibly now Breath in Space
bios cant be sensed
energy armor
bring back contacts system? influences death anger etc
make having more str drain more ki by a bit, player voted
make swords break if you hit someone much stronger? player voted
		mate animation can be spamming fly east state with penis attached while other person lays down as if KO'd
make Icers not get x2 recovery per form but like x1.3 instead
make icer forms take into account ascension so it dont stack
make so sp, mastery, zenkai, meditation, adaptation mods are all traded among each other, using addition, like
0.5 meditation for 1.5 adaptation
make sp mod and mastery mod show on the stat point menu
gun size=1 option
nonturf objs need to take damage normally, gradually each attack, because of pod battles
upgradable weights, light weights are 100k and are 1.5x bp gain, go up to 3x or something
finish enable/disable procs for buffs
soul contract leech energy
make it so you can meditate/train while flying
admins adjust stat gain
add CDs to rp logs
seamless transition from med/train to flight
revamp mate so players can mate with each other
ranks auto fill in the Ranks window
genius stackable for aliens?
admin verb that shows who is MKing
reverse spar works still
in projectile off vs def make it so instead of deflecting, you "miss" and it goes past them
if i use that, off and def can be renamed to accu and dodging
you only deflect in force vs resist
kaioshin can void contract if has more bp than owner
Android: Go into this body
Android: And look at regen / recovery
Android has transplanted their brain into Delariouse Hell-lard's body!
Android has not allowed the brain transplant
Silence has transplanted their brain into Android's body!
Android: yep
Android: but how?
Delariouse Hell-lard: It's a bug or a glitch
Android has transplanted their brain into Silence's body!
Delariouse Hell-lard: I installed brute / armor to it
Delariouse Hell-lard: Then i redid his stats
Delariouse Hell-lard: cuz with brute / armor 1/2 the regen / recovery stat
Delariouse Hell-lard: Then i redid his stats and spamed regen / recovery
Delariouse Hell-lard: Making them 6 each then i uninstalled brute / armor
Delariouse Hell-lard: And wam, it 2 x the 6

Natsumi(Sky Wind Fire): When using stat imprints, if you have a lot of energy and impirint to a low max energy...
you will temporarily be at like 10000% BP

SD goes thru walls?

demons regain their life after a time in hell?
ability to destroy spawns which you have made

Since its almost like UP, Wish for Power, fusion, etc, dont really give any BP, maybe instead they can add
the a square root type thing of the average bp to your base bp?

make halfies work in mate

a techie way to come back to life, Life Energy Generator? it has a 20% chance to explode when you
turn it on and cost a lot

fix AI
a "no icon" choice for change icon
all deaths get logged?
secret nonrp verb where it displays no info about who ko'd or died
just walk up to ship control and get a menu, same for sims, grav, signs, etc
fusion dont give anything
revise ways to get ssj
if you walk up to a sign it will automatically be read

what if there wasnt some global upgrade cap but the upgrade cap was based off of the power you have come in
contact with for each individual?

make packs more intense, and make them all have variable days to buy
make mj dance last a bit longer
fix telepathy spamming
make an option for android makers to let the next android who makes have that body
server info show stat gain mode
skill mastery modifier for admins

make it so admins cant ban admins of a higher level than them

changelings are OP cuz when they ascend their trans stacks their ascended bp? so they have 8x mod x1.3x1.3x1.3?

set all buffs Is_Buff=1, and make them all use Using, and have Enable/Disable procs.
Use this new system to carry over buffs or revert all buffs at once in the Clone and Duplicate procs
Because Clone/Duplicate stack buff mods to infinity

anti grav tech, when worn you dont master grav but it also doesnt hurt you

fly should auto stop med/train

vampire eaters should be more dangerous perhaps they spawn offspring npcs up to 5 that follow them around
if they get out of 10 tiles away they stop following and become rogue vampire eaters. if there are more than 100
rogue vampires eaters no more go rogue they just explode

vamp eaters should be even more sensitive to sunlight

enable FR

gun blueprinting

a giant explosion like SD but doesnt kill you

make hair graying based on logyear

make sd born only to other sd?

make android upgrade show before and after not just after

have adminlogs strip out entries over 3 days old

make tp watch take longer and you cant move

if you get past the bp of the bind on you you break it automatically

shorten lsd time

regenerate skill does nothing?

ships need to take damage diff they need 100 health and their durability should matter because
they have a durability mod
maybe only ship ramming damage needs changed

a majin ability to send out goo that absorbs multiple people at once if they are weak enough

you can absorb someone without KOing them if they are weaker than you LOL

if you fire a beam til your energy runs out you get a aura stuck on you

devil mats dont work with med lv2 because you gain back what you lose

make set_stats offense based on the sqrt of the dmg times the modifier passed as an arg

Nehalim Frostmourne(EXGenesis): Make Changie -> 55 Points into Recovery -> Mystic -> T-Recovery
 -> T-Undying -> Limit Breaker = 1500 recovery

As for 288 Recovery on Finale
Agorothian / Majin -> 20 Points into Recovery -> Small Body -> Mystic -> T-Recovery -> Limit Breaker

splitforms need to match the bp mod of their maker because Icers are leeching the splits

ban is broke again?

make majins unable to become cyborgs

redo the stat gain system so that its not gaining a % of the person with highest stats but rather
a set amount that decreases the higher your stats get?

oozarus go berserk

melee gains should be multiplied by attacker str / defender dur and also for off / def
that way damage whores can still get decent gains from sparring
it should probably be a sqrt of the ratio because people can rest up pretty fast and just do it again

redo self destruct

beams do not seem to show struggle state

re-add invis as a skill but it drains
imitate too

food should be makable in technology

when you drop a scouter the scouter var becomes null even tho its not the one your wearing

nonlethal hokuto

everyone can see the lsd blood

hacking consoles for doors

make it so a tab of a person can be opened with scouter even if you dont have advanced sense but it only shows bp

a pack message

a verb for admins to set max grav

a technology that allows you to teleport to anyone on the same z level if they arent in a house

scrap absorb is abusable to insane bp?

pod controls that summon your pod to you

add Omega Namek song to race fusion

rethink shikon jewel and dead zone amulet being in tech tab

a player toggle to show or dont show their ic name in ooc/who

changies leech bp mod bug

make sure clones to not inherit SP

ability to choose any clothes icon for weights

consider giving players Who tab now that tab refresing is optimized

players want bp to matter more

when race fusion is used make piccolo song play

fusion
	fusion dance
	potara fusion
	android fusion

fix up ship customize verb

demonic training devices
a training thing that sacrifices decline for enhanced training?

Vote Purpose: instead of speed, offense, and defense being melee and ki stats...seperate them into melee speed,
ki speed, melee offense, ki offense, melee defense, ki defense. so that instead of all the stats being str, dur,
 for, res, spd, off, def...the new stats are str, dur, melee spd, melee off, melee def, for, res, ki spd, ki off,
  ki def
  yes won 5 to 12
new stats:
	melee: strength, durability, speed, dexterity, dodging
	energy: force, resistance, refire, accuracy, deflection

clones need to be reverted from all buffs/steroids/etc

admin given ability to blow up a planet's moon

ship guns keep hitting the ship this should never happen

more specialized training equipment so gyms can look pwn
energy
strength
durability
force
resistance. A machine fires blasts at you until you are at low health
speed
offense
defense

a way to transfer intelligence genetically to any race so you could start as a Tsujin then transfer you
intelligence to a Saiyan body and be a Saiyan techy
it should cost a ton so that Tsujins/humans dont become useless. maybe you can only transfer 80% int

a bomb you can place in someone and detonate remotely, killing them.

people want swimming in place of starting with fly for every race

improve factions

bounty droids which will go to the planet that a bountied person is on and report their location

make sure splitforms still divide your bp properly

investigate check_spawn

make oozaru mastery and unmastered oozaru nonrps but does not kill

only humans can self-learn 3rd eye, but can teach it

make it so you dont master flight if you have an antigrav module

water ripple causes major lag sometimes esp when beaming over water

make third eye have editable icon

npcs move around you too much its hard to fight them

do vote: Couple random suggestions for Zee popped into my head. 1. Don't show the player that voted?
2. Make drills max out at a certain level  so players can't have a 100 mill drill draining the planet
before year 1? <--K done

make sure New isnt called on zombies being loaded from the npc file

make sp gain /skill mastery show on creation menu for races

demon trans

make vote delay 1 hour (voted)

people are macroing zanzoken with .click sky1

in injure, ability to rip tails off

new training: energy manipulation you gotta do something cool that relates to controlling energy and itll help
you out

majority wants demons to have a kaio teleport type ability

make ssjadd system or something instead of a static +10 mil it seems bugged a bit

bios should be made by combining dna of diff races

any race with mate can make half breeds with other races

ability to use custom icons for ssj hair using customize

a verb where admins can remove things from the learn list

vote to see if i should add finale-style kaioken
supposedly the kind in now is tien style kaioken

a ki setting between lethal and nonletahl which inflicts injuries when KOing someone

make people not frozen after shockwave attack

make char creation more appealing and faster

new effects for 3rd eye

revamp self destruct

fix injury and tail overlay bugs

make reward have stats option

a lethal ki attack should skip the ko if its damage is >200%

majority wants lift system

if you drop res on a drill it goes in the drill and if you right click a drill it doesnt ask you an amount it
upgrades using whats already in the drill

make it so bans can be right c licked on mobs again

auto tournaments
New players have absolutely nothing to do its a major source of boredom and confusion.

make ssjdrain use a 0-100% system

make sense a skill and it helps directional dodging too ranks have it also put it in learn

when you die you should just be a soul and you can get reincarnated. souls are powerless and demons can absorb
them even when they are not KO. only people who have keeped body can not be souls

Bio-Androids should be made by scientists

instead of bebi body swap being how it is, make it so you hit hte verb and turn into liquid then you must collide
with your target to take them over, using arrow keys

saiba seeds

a delete-all verb which deletes all thing sof a certain type and also tells you the count of them

people can get prostitute npcs and whore them out for money to people who want to unlock halfie

Mate does not produce halfies fix it

Fighting styles that alter stats. Players start with some basic styles they can switch between and master.
Rank styles might come later.
Brute Style
Range Style
Wing Chun
what do styles actually do?

bios and majins start with splitform
bio/majin SF is too small

make it so shield blocks bebi
powering up can kick bebi out your body?

EMP bombs that only hurt androids

all npcs should be able to gain from fights, so that clone drones gain, and other drones, etc

hacking consoles
	finds out passwords of doors, drones, nukes, etc

when a majin absorbs a player they get their clothes icons

Icers shuld start in ff, their base power should be 10x higher, and going down from ff should lower bp mult
its a much better system and they can also have regular ascension because of this

vending machines which can have items set to a custom price chosen by the owner of the machine

add a thing where people gain a percentage of the person with that maximum bp? like 1/1000th, but never more than
0.1% of their own power per tick? And only up to like 20% of that person's power before they have regular gains
only?

A starting skills list which by default has Blast/Charge/Beam in it but can be altered by admins to contain
more or less

skill mastery for popularity purposes

Tech: Tournament Computers

training dummys?

pendulum room?

make lssj more rare 1-10 Saiyans or something

make it so a player can have multiple chars on 1 key

seperate projectile stats into BP, Force, and Offense and have none dependant on the others

make it so sheild blocks attack barrier

make it so people cant start votes on alts after starting on on another alt

make shockwaves come off of beam impacts

fix punch machines

ascension for bios and Icers can be extreme since their forms increase bp multiplier so that needs
to be taken into account by dividing their base power asecnsion by bp multiplier if bp multiplier is >1

a system where theres a dodge verb and when someone presses attack there is an exclamation then a delay
before the actual attack, if dodge is pressed before the delay is over they will dodge. speed determines the
delay.

pimp planet destry make rising rocks have pixel offsets and not be on every tile
make sheild and force field block time freeze
flame thrower
a giant space laser that can kill any npc in a 40x40 radius
add some technology to attract zombies to a location?

upgradable bombs

techies can make viruses to infect drones, and bio viruses

regen/recov are gainable
zenkai increases regen/recov?

hacking consoles can be made to work on doors again and also to make drones switch masters to serve you, and
to unbolt things

When sense is a skill it can have a combat advantage where you can better dodge hits from behind, and perhaps
without sense you can't dodge hits from behind almost at all?

Make clean remove dust and body chunks and flies

make NPCs verb not cause them to make body chunks

Big Bang, like a suped up charge, moves faster, drains more, damages more

Make lethal ki skip the KO and just kill

Reverse Engineering. Certain technology appears in a random spot on a planet at a certain year and can
be reverse engineered to get 'blueprints' which can be used to build it. blueprints can also be taught.
Like pods appear on arconia at year 10, but dont appear on earth til year 30.

Economy: Money is made by the government to keep the peasants away from resources. The government makes
vending machines which peasants can buy things at for money. They get the money from government jobs thats
how the government covers the loss at the vending machines. Also there are taxes and artificial inflation
which help the government cover losses even more. It's all about keeping the peasants away from resources.

add a buster barrage type move

SD should start with telepathy

demon fruit should heal an injury

New alien skills: Acid Shot. A unique ki attack, primal, damages a biggish radius but is weak and has little
drain. undrainable flight.

A buff where its Omega powerful but decreases your lifespan

When you knock someone across water it should leave a water ripple trail same with blasts.

When weapons are customizable add a spear and lance attribute spear attacks 2 tiles away lance attacks
3 tiles at once

Melee settings should be a teachable rank thing and new characters just start with the 20% KB chance combat.

Treasure Chest things that other objs can be stored in and locked perhaps

HBTC can be destroyed from the inside, and perhaps restored somehow perhaps with dragon balls

If PVs have a level of power they can't fall below, perhaps Ranks should too, since it's their job to
be in a useful teaching position.

Automated PV, up to 5, if you die you lose the status, its granted by RP council, makes it so you get a
basic set of skills, perhaps some resources, and cant fall below the average power of the server. An
incentive to be evil other than this?

EG gets the ability to travel to the afterlife with a verb and also return any time?

In Kami's tower put the Pendulum room where there is a symbol on the floor and only Popo and Kami get the
ability to activate it and anyone standing on it gets sent to another dimension to fight to the death but
they dont really die. Also Popo and stuff can summon them back out of it

If only Korin can open the sacred water then perhaps it could be made more special and have a better boost.

Also give Korin the ability to send a person to another dimension of ice to get the REAL sacred water.

If a person built a house they should be able to IT into it

Gas chambers

rp council grants 1% of the max rp power of the server instead of static +1 but no less than +1

Make melee drain based on the sqrt of max energy.
	10 = 0.33 = 30 hits
	25 = 0.5 = 50 hits
	100 = 1 = 100 hits
	400 = 2 = 200 hits
	1000 = 3.3 = 300 hits

Add sexual mating back as an option which would allow for halfies and also could take the highest sources
of power from each parent giving them to the child. Inherit Body Power, Spiritual Power, Grav Power

Perhaps water ripples when ki blasts pass over water could come back?

Charged Melee move where those who have it toggle it on and energy forms around their hands, their energy
drains to keep the move active but it does like double melee damage or something

Ability to install premade force fields into ships

Make a "Create_Blast" proc or something, so that all blasts for all moves can be created from it
Players just grab pods in space because they move faster than pods, making pods useless. So something needs
changed

Sensing should be an obj that can be leeched by being around those who already have it, it is not something
that can be gained on your own but skill masters get it and such

Pods and ships should be removed and there should just be "Vehicle" and you can add features that can allow
you to recreate pods and starships as long as you spend enough money.

Pod launch speed should be a customizable stat

How obj's take damage will have to be redone so that they all have 100 health and take damage the same as
mob's do.

Fix the Control Panel stacking bug

Machines that read individual aspects of power such as just physical power.

Add Detox so that people can use it to get rid of the effects of steroids and other modifiers

Rabies

Use the Zero Armor icon to make something nice

Add where nukes can be turned to missiles and shot to a coordinate

Magnetic Mines would be good for pod race obstacles

Guns made by smarter people should be more powerful

Put Upgrading in for as many things as possible

Sword and Armor customization

Nobody can make tech by default. They must find something and reverse engineer it. After that they can create it. Also
they can spread it by creating another and letting someone else reverse engineer that.

Hacking consoles

Technology that can destroy a planet?

A techie should be able to diffuse a bomb technologically.






NON-PRIORITIES:

Ki Batteries that will restore ki that is stored in them

Make the aura into an object in the mobs contents so they can change it to custom icons if they wish as well

All manner of tortures exist in hell. The only way hell won't effect you is if your a demon or you get a special item.
LSD, Diarea, MJ, Zombies, Swarms, Baneling Altar, Scary Sounds, Flash the ring around the rosy girls and play the music,
Scary face appearing on screen, freddy kreuger hunts you down, the exit to hell can disappear, they can be fooled that
they have left hell but gradually it turns out they never left at all, make it so they are sent to spawn but are invisible
and no one can hear them then eventually are returned to hell,
A demon that grabs and buttrapes you
Hell is z6

Any air mask can be clicked and used even if it is not in your contents

Make ssjdrain vars go from 1 to 100% instead of what they currently do. and call it ssjmastery or something
there is no ssj drain, its bugged

Auto pilot upgrade for ships or navs

Have Make Fruit and Unlock Potential actually do something

Reconfigure the Admin() verb to add/remove things directly from the admin list rather than using it on mobs

Use Scan Machine.dmi for something other than ship controls?

Add more caves as a place to put more labs/fortresses

A currency system that serves the purpose of population control, keeping people from competing for resources you instead
give them money and they can buy things you allow them to buy out of a automated store.

Make it so when a HC/EV can be voted, perhaps HC can take double damage than normal? Like the god's are protecting them.

fix the thing with choose_login and load combining to repeat themselves over and over resulting in year spam and such

Redo the admin log system so that things that should be logged are logged and things that shouldnt be arent.
Delete needs logged

Use Read()/Write() to make a custom overlays system.

Guns/Turrets/Nukes should be upgradeable again by pumping money into them but only up to the average BP of the server.
Walls as well
I have an idea. An ability to imbue a weapon with your own power, it will match your power. Perhaps this is how all
technology is upgraded, even walls.

A Baneling Alter in Hell that can turn someone into a baneling and send them back to their life but they must kill 1 living
person a day or their power declines and they die and are bound to hell. Perhaps there is Shadow Water too that can
undo the curse of being a Baneling.

Build your own buff

Majin channels anger into bp, and durability into strength, resistance into force, and defense into offense, and
recovery into regeneration. Or perhaps just trade anger/recovery for bp/energy.

Make Shikon Jewel revive people if placed on their dead body

Perhaps make rapid blast slower than normal if under a certain power. More power = more ki usage possibilities maybe

A technological senzu alternative, speeds up healing and such but dur/res is lowered even more

Turtle Shell		44 pounds (20 kg)
Turtle shell's they wore in the last month with Roshi		88 pounds (40 kg)

Boots		44x2 pounds (20x2 kg)
Wristbands	22x2 pounds (10x2 kg)
Shirt		176 pounds (80 kg)

Total		308 pounds (140 kg)

185+308 = 493 pounds

Without shirt

185+132 = 317 pounds

Pressure point knowledge. Can inflict injuries without having to KO perhaps? Drains more energy because you must
discharge it into their pressure points. Hokuto Shinken. Also more melee attributes could be added.
Attributes could even be stat trading, like half defense double offense

Redo the set of admin verbs so that the below things can be done. There needs to perhaps be a 4th admin level for the
elected head admin. The only level that can strip/add admins.

Players should elect the head admin like a president or something and he forms his team.

Players also elect the RP Council or something, who can enhance events by voting to reward and make EVs and make HCs and
assign ranks and even make Super Saiyans.

Whether or not someone is a non-noob should be decided by regular players voting. They can vote to label someone as a
noob, average, or non-noob, and noobs have 0 voting power, non noob have 2, etc

Make the non-noob label a list that saves their key so it saves even if they remake or their is a wipe

Stat altering injections/whatever that place objs into the mobs contents which all share a action verb that after redo
stats is used it calls all those procs to enable their effects, perhaps the effects expire at some point too

Remove Crandal and add a better replacement
	Auto-Centering in change icon for large icons
	Add-Overlay
	Resize-Icon
	Change-Icon on mobs and objs
	Color

Make Intelligence a customizable mod like any other stat, so making more intelligent characters sacrifices other stats

Holograms, technological split forms basically

Surveilence cameras that alert you when someone is in the vicinity

Make Limit Breaker teachable

Make it so custom expand icons can be used

Make it so that if a planet is destroyed the race is not choosable

Give Super Saiyan forms unique effects perhaps randomized

NPC Whores and Brothels

Stock markets, planet-based, how developed it becomes more stock is worth, planet is destroyed stock is 0$
Ability to bring meteor showers down upon a planet, poison the air, start forest fires that roam the planet
Make it so players can create their own type of npc which reproduces itself so it can kill a planet
Make a swarm of flesh eating locusts that reproduct all across the planet and swarm and kill people turning them into
piles of bones

Add Dragon names so that to wish someone must know the name

Add the thing where if someone kills you theres a 20% chance your not truly dead and you come back

Whether the injury is permanent or temporary is up to the person injuring you and how severely they choose to hurt you

Add blood overlays for injuries to different body parts.

The michael jackson NPC comes out of the portal, but after he goes back in he goes to a cave, and becomes michael crab
jackson, he guards the sword of mj, the only weapon that can kill him, after a person grabs it they are teleported to
neverland ranch where they must battle mj to the death to end the madness. after killing mj they will recieve a
amulet that can kill all zombies with its magical powers

Add zombies back in



Make Spin Blast a toggle and it acts like buster barrage

Update the death ball and genki dama icons

A system where you can learn any non-rare ability you see automatically but only 1 new ability every 10 years
or something and only if you have the skill. Humans can learn every 5 years, if they have 3rd eye perhaps
every 2 years.

Add the skill teaching time limits

Admins can create custom trans for a person or race?

Make attack have a greater accuracy if you hit someone from behind

Finish the large dragon ball dragon icons

An ability that lets someone lessen another person's gravity mastery, weakening them.

A Demon Ability to control others. You can use it on them if your more powerful than them. You can explode
them at any time with it if they don't obey you or whatever.

You can launch ships anywhere? If it is not a planet you just appear some random place in space.

Fix invis npcs

Body Change ability. They switch mobs, mobs swap skills. The person can get their body back in these ways:
If the other person is knocked out they change back because they lose focus. Perhaps energy drains as the
person focuses to keep themselves in control of the body.
With enough drawbacks this could possibly become a balanced ability.

Make it so scouters are upgradeable again and they scan to however much money you put into them.

Matches to start fires that spread

Charge and Blast need to possibly be combined again. And Charge charges like a beam but is a blast.

Technology to change stats at any time. Power Suits.

Make Scatter Shot toggleable on and off perhaps so you dont stop firing them til you want to.

Put in some cybernetic skills like blast absorbing and stuff

Make it so SI can only be used once every 15 minutes.

For custom abilities you can make a new one each 10 years only, and perhaps each 10 years you unlock 1
new attribute, that way the older people have some use, they are the ability masters, and they can teach
unique abilities that younger people can not make on their own. If not, it can be used for a new game
where there are no preset skills, only player made skills.
	Types:
		Blast
		Charged Blast
		Beam
		Buff
		Summon

Make it so races are types of mobs and also its tab based so you choose your race in tabs as if you would
hair and stuff.

With stun chips you can also have a Stun Tower that prevents them from leaving a certain area. The chip
knocks them out if they try to zanzoken or blast too. Or if they get too close to the tower.

Let ships fire the weapon you have on you as if its mounted on the ship. In fact just make it so you can
mount the ship with weapons and ammo so it can reload automatically.

Turret seats on a ship that would allow a nonpilot to fire the weapons in any direction.

Pulse Bombs. They send out a pulse that breaks anything around them. You can have them use different
amounts of pulses. 1-5 or something. Make the pulse thing a proc that can originate anywhere because there
could also be Pulse Towers that send pulses regularly.

Acid that you can pour on an invididual thing to destroy it or melt it or whatever.

Vaccines, Viruses,

Make hell more hellish for non-demons. LSD effects there, random teleportations maybe, other things...

NPC eggs that you can make through science, and have an activator that can hatch them all at once. And some
way to make them not attack you if you have a badge of the same passcode.

Gas Chambers

A barrier style move. Weak, but if your very strong it can massacre many people. Such as if Frost uses it.

Have a toggle that lets you switch between building Inside and Outside turfs. Make it so NPCs can still
spawn as long as its outside.

Make it so scouters have communication but scanners have object detection

Idea where all tech isnt available at once you simply find technology laying around on certain planets and you
can reverse engineer it and add it to your ability to make it

Reincarnation. Lose all skills keep all stats. Kaioshin and Daimao have it.

Replace all upgrading concepts with customization. You make technology adapted to its uses, and so on.

A "create your own gun" system. And a "create your own sword" system. Remember about energy melee weapons.

LSD needs work and Weed could make you gain energy faster but no off/def. you can grow weed from the seeds

There needs to be more energy weapons. Like a Phaser. And energy melee weapons, they can have a tactical
advantage on someone with lower res than dur. But overall they are probably slower or something by 20%.

If someone drains your life force you get injuries. Injuries come in stage 1 and 2. Stage 1 is not permanent
but takes longer to heal from than just health, perhaps they wont heal at all without someone who has the
heal skill or a regenerator. Stage 2 doesnt heal at all, and has very bad effects. You could get cybernetic
limbs to counteract those effects to an extent.

For change icon object, make it so you can change the icon of expand and when you then expand, it shows you
as that icon instead of your previous one.

Redo Time Freeze?

Idea for how Zenkai can work. While knocked out, or killed, how much zenkai you get is determined by the
power of the person who killed you. You may match but not exceed their power potentially. Limit to 1
zenkai per year possibly.

Replace power up with a Limit Mode or some such thing. Where you can just toggle it, and you get an aura,
and your power increases, but you stop recovering energy or even drain energy or something.

Finale could go full democratic. Regular players must vote people into alliance. Regular players can vote to
strip the voting power from other players. Alliance members get more voting power. Admins would no longer
be needed.

Give blasts health levels about the same as the damage they do, that way that annoying thing where your
doing a genki dama and someone destroys it with 1 blast, doesnt happen any more

Ok so instead of intelligence being 100, you have intelligence = 1 or so. It lowers or raises the price that
it takes for your to make and upgrade things. The only thing you have to do to make your technology better
is get more resources. And there should be new upgrade verbs for all the things to reflect that, telling you
how much resources you need to put in to go to the next "level" or whatever perhaps.
So scouters could have individual levels again, it wouldnt be based on how intelligent you are, but how
expensive your scouter is.

When someone speaks into scouter people around them should see it in say as well

Basic skills can be taught freely after mastering them.
Moderate skills can only be taught once every 5 years, and to teach them you must have had them for 5 years
and mastered them.
Rare skills can only be taught every 20 years, and you must have had them for 20 years to teach them.

controls that can call your pod to you

Turrets need to attack ships piloted by people without clearance

A simple version of mate is needed

Create a custom virus system where a cloud of microbes spreads across the planet out of a 1 time use release
mechanism, and infects people of a specific race OR all races. For each person it kills, more microbes are
released and float around.

Bring DNA container back so that people can be cloned using it. And people can trade the bodies.

Check if ships need to be more expensive.
Ships should no longer be upgradeable. Nothing should probably.

Navs are NOt part of the ship rather a thing you carry on you OR a scouter feature and when it space you
get the nav tab because of that. Adding each new planet costs money.

A Blutz Wave move that can let a Saiyan turn themselves oozaru at the cost of much energy. Perhaps 200 energy?

I could code in a "Mode" variable that controls what gameplay style this has. I could use it to update
Finale, Abridged, and Riptastic all at once. By coding all 3 modes into some kind of toggle.

Make a verb only for me that lets me download people's custom icons from the game.

How I rate people's reputation
-2 Omega abusive on purpose
-1 nonrp nub, slight abuse possibly
0 neutral
+1 probably not abusive
+2 decent roleplayer
+3 deserving of minor ranks
+4 deserving of middle ranks
+5 deserving of major ranks

Redo the attack gaining system so that the attack gain proc is ran per hit and the mob attacked is passed
through for gain comparison
may require complete recoding of attack verb.
make the target a var like var/mob/A then set it accordingly that way for grabbing and stuff it attacks the
person being grabbed

A simplistic cybernetic module and upgrading system could possibly be implemented in a nice way.

Make the verb that adds and removes custom overlays, tab based, particularly for removing them.

Types of attacks which need included in the plans for revamping the ki attack system:
Knockback
Stun
Genki Dama style things that burst through all turfs but each hit takes the Genki Dama's health too so
you can only break through a certain amount of things before it dissipates.
Make it so Life Force and Health are the exact same thing and if a single attack is strong enough to bring
someone to -100 health it kills them instantly, as with Genki Dama.
A stronger blast hitting a weaker blast needs to keep going and delete the weaker blast. Health could be set
to a proportionate value to determine that.

Restoring a planet needs to bring it back to space too

New races would spawn where the most of their race is. So if the most Saiyans are on earth they spawn
there.
	Cant spawn inside someone's house


Make grab not use a loop to relocate the grabbed thing but put it in move maybe

Other types of blasts should also be able to struggle with beam. and the strongest blast against another
blast cancels that one out

Make Basic skills learnable as soon as you see them being used, as long as your energy, offense, and defense
are of a certain level. Maybe moderate skills too but only with really high energy offense and defense.

Make a thing where a blast can hit 2 people at once if they are on the same tile when it hits

Redo the Make and Give verbs to be tab based. Just make vars for objects like Make_List and Give_List
and have them equal 1 or 0 depending if they are makeable/givable or not

Charge, as well as similar attacks, should be more like beam, you can hold it as long as you want and it
auto-powers you up as long as your holding it and you can fire it at any time.

Blasts re-update their power based on the person who fired them every 1 second.

If you are powering up when an incoming blasts is coming towards you you will attempt to deflect the blast.
Both people become immobile, the blast will only be deflected if one person becomes significantly more
powerful or weaker than the other, and to become more powerful they would have to use powerup or focus or
something. It may take long to gain the upperhand so its possible the person with less energy would become
too exhausted and thus weaker and the blast would hit them.
*/