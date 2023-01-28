/*
LOOK AT THE FEAT IDEAS IN UNITY3D NOTES TOO. THEY ARE SEPARATED INTO COMBAT FEATS, SCIENCE FEATS, ETC, ITS GOOD IDEAS

Feats could also be divided into Good and Evil sometimes.

Certain feats may require maintenance to keep, such as Undefeated Champion, this means you have not been defeated in a tournament since the last
tournament you have fought in

FEAT IDEAS:
	Combat Feats:
		Conquer planet. +5%. stack 1x
		Become Dojo master, +3%, 1x
		break a strong wall
		restore planet using crystal
		master high gravity
		make league, join league, league something
		become first Super Yasai

		Win 30 fights, +3%, 1x
		Beat someone very strong, +1%, 2x
		Beat dojo master, +1%, 1x
		Beat planet ruler, +1%, 1x
		5 win streak: beat 5 unique players who were at least 80% your BP without dying. if any of them have a matching CID/IP it resets

		Learn rare skill, +1%, can be earned once for however many rare skills exist in the game
	Science Feats:
		build a drone
	Other feats:
		Stop a zombie apocalypse

FEAT IDEAS THAT REQUIRE EXPLANATION:
	Blind Run Training: In this TV show called The Shannara Chronicles there were these Elf warriors who trained to gain heightened awareness by
		running blindfolded and with hands tied behind their back thru the woods, avoiding trees and ditches and cliffs etc and only the fastest 7
		to make it to the end would pass. We could have something like that, where you are blind most of the time and the faster you make
		it the better Feat reward you get. It must be added in a non-annoying way.
*/

var
	feats_on = 1
	list/master_feats = list(\
		"Win Tournament" = list("boost" = 0.005, "stacks" = 0, "max stacks" = 3, "type" = "BP cap"),\
		"Win Tournament Match" = list("boost" = 0.0033, "stacks" = 0, "max stacks" = 2, "type" = "BP cap"),\
		"Wish on Wish Orbs" = list("boost" = 0.01, "stacks" = 0, "max stacks" = 3, "type" = "BP cap"),\
		"Get revived by revive skill" = list("boost" = 0.0033, "stacks" = 0, "max stacks" = 1, "type" = "BP cap"),\
		"Find and use Vampire Altar" = list("boost" = 0.0033, "stacks" = 0, "max stacks" = 1, "type" = "BP cap"),\
		"Become Tournament Owner" = list("boost" = 0.01, "stacks" = 0, "max stacks" = 1, "type" = "BP cap"),\
		"Kill Hero while you are Villain" = list("boost" = 0.01, "stacks" = 0, "max stacks" = 2, "type" = "BP cap"),\
		"Kill Villain while you are Hero" = list("boost" = 0.01, "stacks" = 0, "max stacks" = 2, "type" = "BP cap"),\
		"Capture Bounty" = list("boost" = 0.0033, "stacks" = 0, "max stacks" = 2, "type" = "BP cap"),\
		"Use Time Chamber" = list("boost" = 0.01, "stacks" = 0, "max stacks" = 1, "type" = "BP cap"),\
		"Train Student" = list("boost" = 0.005, "stacks" = 0, "max stacks" = 3, "type" = "BP cap"),\

		"Survive Core (5 Minutes)" = list("boost" = 0.0033, "stacks" = 0, "max stacks" = 1, "type" = "BP cap"),\
		"Survive Core (10 Minutes)" = list("boost" = 0.005, "stacks" = 0, "max stacks" = 1, "type" = "BP cap"),\
		"Survive Core (15 Minutes)" = list("boost" = 0.01, "stacks" = 0, "max stacks" = 1, "type" = "BP cap"),\

		"Win 3 Tournaments Without Losing" = list("boost" = 0.01, "stacks" = 0, "max stacks" = 1, "type" = "BP cap"),\
		"Win 5 Tournaments Without Losing" = list("boost" = 0.02, "stacks" = 0, "max stacks" = 1, "type" = "BP cap"),\

		"Get Highest Relative Base BP This Wipe" = list("boost" = 0.01, "stacks" = 0, "max stacks" = 1, "type" = "BP cap"),\

		"Get Very High Knowledge" = list("boost" = 0.05, "stacks" = 0, "max stacks" = 1, "type" = "Cheaper Science"),\
		"Get 100 Million Resources in Bank" = list("boost" = 0.05, "stacks" = 0, "max stacks" = 1, "type" = "Cheaper Science"),\
		"Get 300 Million Resources in Bank" = list("boost" = 0.05, "stacks" = 0, "max stacks" = 1, "type" = "Cheaper Science"),\
		"Get 600 Million Resources in Bank" = list("boost" = 0.05, "stacks" = 0, "max stacks" = 1, "type" = "Cheaper Science"),\
		"Get 1 Billion Resources in Bank" = list("boost" = 0.1, "stacks" = 0, "max stacks" = 1, "type" = "Cheaper Science"),\
		"Get 2 Billion Resources in Bank" = list("boost" = 0.1, "stacks" = 0, "max stacks" = 1, "type" = "Cheaper Science"),\
		"Get 3 Billion Resources in Bank" = list("boost" = 0.1, "stacks" = 0, "max stacks" = 1, "type" = "Cheaper Science"),\
		)


mob
	var
		feat_bp_multiplier=1
		feat_price_div=1

		list
			student_feats = new //who you received student feats from so far
			feats = new

	proc
		GiveAllFeats()
			for(var/v in feats)
				var/list/l = feats[v]
				if(l && l.len)
					l["stacks"] = l["max stacks"]
				feats[v] = l

		BPFeatsCompletionPercent()
			if(!feats || feats.len != master_feats.len) return 0
			var
				completed = 0
				available = 0
			for(var/v in feats)
				if(feats[v]["type"] == "BP cap")
					available += feats[v]["max stacks"]
					completed += feats[v]["stacks"]
			return (completed / available) * 100

		CheckBlankFeats() //fixes the blank feats bug hopefully
			if(!feats || feats.len != master_feats.len)
				feats = master_feats

		SaveFeats()
			if(!key) return
			var/savefile/f = new("Feats/[key]")
			CheckBlankFeats()
			f["feats"] << feats

		LoadFeats()
			//this proc also updates their feats to the latest version so no new feats are missing
			if(key && !fexists("Feats/[key]"))
				feats = new/list
				feats = master_feats

			if(key && fexists("Feats/[key]"))

				var/savefile/f = new("Feats/[key]")
				f["feats"] >> feats

				for(var/v in master_feats) if(!(v in feats))
					feats += v //fix bad index error
					feats[v] = master_feats[v]

				for(var/v in feats) if(!(v in master_feats)) feats -= v

				for(var/v in feats)
					feats[v]["boost"] = master_feats[v]["boost"]
					if(feats[v]["stacks"] > master_feats[v]["max stacks"]) feats[v]["stacks"] = master_feats[v]["max stacks"]

				CheckBlankFeats()
				UpdateFeatMultipliers()

		CheckBankFeats()
			if(!key) return
			var/res = bank_list[key]
			if(res >= 100000000) GiveFeat("Get 100 Million Resources in Bank")
			if(res >= 300000000) GiveFeat("Get 300 Million Resources in Bank")
			if(res >= 600000000) GiveFeat("Get 600 Million Resources in Bank")
			if(res >= 1000000000) GiveFeat("Get 1 Billion Resources in Bank")
			if(res >= 2000000000) GiveFeat("Get 2 Billion Resources in Bank")
			if(res >= 3000000000) GiveFeat("Get 3 Billion Resources in Bank")

		CheckStudentFeat(mob/m) //m = student
			if(!m || !m.client || !client) return
			if(m.client.address == client.address) return
			if(ckey in m.spent_student_points)
				if(m.spent_student_points[ckey] >= 200)
					if(!(m.ckey in student_feats))
						student_feats += m.ckey
						GiveFeat("Train Student")
						src<<"<font color=yellow>Feat details: Teach a player 200 student points worth of skills"

		GiveFeat(f = "Feat Name")
			if(!feats_on) return
			if(!(f in feats)) return
			if(feats[f]["stacks"] < feats[f]["max stacks"])
				src<<"<font color=yellow>FEAT ACCOMPLISHED: [f]. \
				+[feats[f]["boost"] * 100 * (feats[f]["stacks"] + 1)]% [feats[f]["type"]]. [feats[f]["stacks"] + 1] / [feats[f]["max stacks"]]"

				feats[f]["stacks"]++
				feats[f]["stacks"] = Clamp(feats[f]["stacks"], 0, feats[f]["max stacks"])
				UpdateFeatMultipliers()
				SaveFeats()

		UpdateFeatMultipliers()
			feat_bp_multiplier = 1
			feat_price_div = 1

			if(!feats_on) return

			for(var/f in feats)
				switch(feats[f]["type"])
					if("BP cap")
						feat_bp_multiplier += feats[f]["boost"] * feats[f]["stacks"]
					if("Cheaper Science")
						feat_price_div += feats[f]["boost"] * feats[f]["stacks"]

			feat_bp_multiplier = 1 + (feat_bp_multiplier - 1)

		ViewFeats()
			src<<browse(FeatWindow(),"window=Feats Guide;size=650x540")

		FeatWindow()
			var/txt = {"
			<html><head><body><body bgcolor=#000000><font size=3><font color=#CCCCCC>

			Feats reward a player for proving that they are more skilled/knowledgable/capable at the game than some potato scrub who
			does nothing. Suggest to me new feat ideas if you want.<p>

			YOUR FEATS:<ul>
			"}

			var
				bp_boost = 1
				cost_boost = 1

			for(var/f in feats)
				txt += "<li>[f]. +[feats[f]["boost"] * 100]% [feats[f]["type"]]. [feats[f]["stacks"]] / [feats[f]["max stacks"]]"
				switch(feats[f]["type"])
					if("BP cap") bp_boost += feats[f]["boost"] * feats[f]["stacks"]
					if("Cheaper Science") cost_boost += feats[f]["boost"] * feats[f]["stacks"]

			txt += "</ul><p>"

			txt += "TOTALS:<br>\
			BP Cap +[round((feat_bp_multiplier - 1) * 100, 0.1)]%<br>\
			[round((cost_boost - 1) * 100, 0.1)]% cheaper science<br>"

			return txt