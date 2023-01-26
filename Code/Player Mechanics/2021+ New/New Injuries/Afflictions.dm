/*
New injury system should contain both simple, temporary injuries which happen during combat and go away slowly on their own
AND complex, permanent injuries which a victorious party can spend points from a pool that builds while fighting an opponent that have more longstanding effects.

System A: somewhat similar to what we have now.  Simple injuries that are temporary and heal on their own.
They have some mechanical effect but it's generally not going to be a game-changer unless the fights were already close.
These can happen on their own in combat, with different attacks having better chances of dealing specific injuries.
Maces doing more internal injuries, things like spears being more likely to damage specific limbs, certain ki attacks damaging eyes etc.
Nothing over the top though, as these are just the kinda meant to be a minor piece that builds into the second system.

System B: This one is more complex.  Fighting with this system will build up a sort of pool of points
(which will also diminish over time when not fighting the person) against your adversary.
When you've knocked someone out, you can then spend these points on a variety of substantially more complex, personal, and intentional injuries.
Somewhat like the permanent injuries we currently have, except they won't just be "stronger" versions of the same injuries before.
These can also only be healed by outside means, and won't recover on their own.  Races such as namekians or Majins will still have this limitation,
but I'm thinking of having the cost scale based on your death regen value + 1 so it's harder to deal permanent damage to those races
(and people who get DR thru traits, immortality, etc).

Afflictions are a more complex, dangerous, and effectively permanent malus than standard injuries are.
As you fight someone, you will gain Affliction Points against them.  These can then be spent from a dialogue window on different afflictions
of varying cost.  There will be an upper limit for how many afflictions one can have, as well as a per-source limit, both adjustable
via the server config.
*/

mob/var/list/afflictions = list()
mob/var/list/afflictionPoints = list()

mob/proc/GainAfflictionPoints(mob/Source, amt)
	if(Source.key in afflictionPoints)
		afflictionPoints[Source.key] += amt
	else
		afflictionPoints[Source.key] = amt

mob/proc/TryGainAffliction(mob/Source, affliction/A)
	if(Source.key in afflictionPoints)
		afflictionPoints[Source.key] -= A.cost
		afflictions.Add(A)

mob/proc/CanGainAffliction(mob/Source, affliction/A)
	var/canAfford = (Source.key in afflictionPoints) && (afflictionPoints[Source.key] >= A.cost)
	var/sourceCanAfflict = 1
	if(Limits.GetSettingValue("Maximum Afflictions per Source"))
		var/count = 0
		for(var/affliction/a in afflictions)
			if(a.source == Source.key) count++
		if(count >= Limits.GetSettingValue("Maximum Afflictions per Source"))
			sourceCanAfflict = 0
		
	return canAfford && sourceCanAfflict && (Limits.GetSettingValue("Maximum Afflictions") && afflictions.len < Limits.GetSettingValue("Maximum Afflictions"))

affliction
	var
		name = "template"
		desc = "a template affliction with no actual effect"
		cost = 1000000
		source

	amputation
		left_arm
			name = "Amputate Left Arm"
			desc = "Left arm has been severed entirely from the body."
		right_arm
			name = "Amputate Right Arm"
			desc = "Right arm has been severed entirely from the body."
			
		left_leg
			name = "Amputate Left Leg"
			desc = "Left leg has been removed entirely from the body."
		right_leg
			name = "Amputate Right Leg"
			desc = "Right leg has been removed entirely from the body."
	
