/*turf/New(skip_auto_gen)
	. = ..()
	if(!skip_auto_gen) GenerateFeatures()*/

turf/var/auto_gen_eligible = 1

/*turf/New()
	. = ..()
	if(turf_gen_cache && auto_gen_eligible) turf_gen_cache += src*/

var/list/turf_gen_cache = new