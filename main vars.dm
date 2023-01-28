//#define DEBUG

var
	modless_gain_exponent=1
	balance_rating_mult=0.4 //lower = retains more balance rating when changing stats.
	superior_force_exponent=0.3
	inferior_force_exponent=1.1
	superior_strength_exponent=0.3
	inferior_strength_exponent=0.8
	defense_damage_reduction_exponent=0.25
	defense_damage_reduction_cap=0.75
	shield_reduction=0.7
	shield_exponent=0.55 //how much affect more energy mod will have on reducing shield damage
	sword_damage_mod=0.75 //applies to the bonus only, so +70% damage becomes +(70x0.8)% damage assuming the mod is 0.8, so not 1.7x0.8
	energy_sword_damage_mod=0.93
	silver_sword_damage_penalty=0.93
	silver_sword_damage_mult=3
	strangle_str_mult_cap=2.7
	hit_from_behind_dmg_mult=1

	speed_accuracy_mult_exponent=0.13
	speed_accuracy_mult_min=1
	speed_accuracy_mult_max=4

	base_melee_accuracy=70
	base_blast_accuracy=22
	superior_off_vs_def_mult_exponent=0.3 //was 0.3
	inferior_off_vs_def_mult_exponent=0.65 //was 0.45
	kb_superior_scaling_mod=0.4
	kb_inferior_scaling_mod=1.6
	defense_auto_combo_backhit_chance=20
	recovery_powerup_exponent=1
	energy_mod_powerup_exponent=1 //determines max powerup % before massive slowdown begins, a soft cap
	powerup_softcap_scaledown_exponent=3 //how fast powerup slows down past the soft cap. this is not the soft cap itself
	health_regen_exponent=0.7

	android_extra_cyber_bp_mult=1.75
	standing_powerup_deflect_mult=4
	teamer_dmg_mult=1 //no change because double angers is a possibility,

	melee_power=1
	ki_power=1
	icer_recovery=1.2
	death_x=160
	death_y=200
	death_z=5

mob/var
	base_bp=1
	bp_mod=1
	Str=100
	End=100
	Spd=100
	Eff=1
	Pow=100
	Res=100
	Off=100
	Def=100
	regen=1
	recov=1
	max_ki=80
	gravity_mastered=1
	Age=0
	Decline=50
	real_age=0
	Race
	Class
	BP=1
	bp_mult=1
	strmod=1
	endmod=1
	spdmod=1
	formod=1
	resmod=1
	offmod=1
	defmod=1
	anger=100
	max_anger=100
	sp_mod=1
	mastery_mod=1
	Ki=10
	mental_power=100
	Immortal=0
	Body=1
	Tech=1
	hair
	ssjhair
	ssjfphair
	ussjhair
	ssj2hair
	ssj3hair
	HairColor
	BPpcnt=100
	displaykey
	Lungs=0
	leech_rate=1
	zenkai_mod=1
	med_mod=1
	Intelligence=0.1
	Demonic
	stun_resistance_mod=1
	ascension_bp=1000000