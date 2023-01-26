atom/var/list/AssociativeFilters
atom/proc/AddFilter(key, filter)
	AssociativeFilters ||= list()
	key ||= GetBase64ID()
	if(HasFilter(key))
		RemoveFilter(key)
	filters += filter
	AssociativeFilters[key] = filters[length(filters)]
	return filters[length(filters)]

atom/proc/RemoveFilter(key)
	AssociativeFilters ||= list()
	var/f = AssociativeFilters[key]
	animate(f)
	sleep(world.tick_lag)
	filters -= f
	AssociativeFilters[key] = null
	AssociativeFilters -= key
	sleep(world.tick_lag)

atom/proc/GetFilter(key)
	return AssociativeFilters[key]

atom/proc/HasFilter(key)
	return (key in AssociativeFilters)

atom/proc/ClearFilters()
	for(var/i in filters)
		filters -= i
	AssociativeFilters = list()