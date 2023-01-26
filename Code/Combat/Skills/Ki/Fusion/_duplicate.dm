//Title: Object Duplication
//Credit to: Jtgibson
//Contributed by: Jtgibson


//This snippet will create and return an exact duplicate of
// a mob or an object.


datum/proc/duplicate()
    var/datum/duplicate = new type
    for(var/V in src.vars)
        if(issaved(vars[V]))
            if(istype(vars[V],/list))
                var/list/L = vars[V]
                duplicate.vars[V] = L.Copy()
            else
                duplicate.vars[V] = vars[V]
    return duplicate


atom/movable/duplicate()
    var/atom/movable/duplicate = new type(src.loc)

    var/list/parallel_inventory = list()
    for(var/atom/movable/X in src)
        parallel_inventory.len++
        var/atom/movable/duplicated_item = X.duplicate()
        duplicated_item.loc = duplicate
        X.loc = src
    for(var/V in src.vars-"contents")
        if(issaved(src.vars[V]))
            if(istype(vars[V],/list))
                var/list/L = vars[V]
                duplicate.vars[V] = L.Copy()
            else
                duplicate.vars[V] = src.vars[V]
            if(src.vars[V] in src.contents)
                duplicate.vars[V] = parallel_inventory[src.contents.Find(vars[V])]
    return duplicate

mob/duplicate()
    var/mob/duplicate = new(src.loc)

    var/list/parallel_inventory = list()
    for(var/atom/movable/X in src)
        parallel_inventory.len++
        var/atom/movable/duplicated_item = X.duplicate()
        duplicated_item.loc = duplicate
        X.loc = src
    for(var/V in src.vars-"contents")
        if(issaved(src.vars[V]))
            if(istype(vars[V],/list))
                var/list/L = vars[V]
                duplicate.vars[V] = L.Copy()
            else
                duplicate.vars[V] = src.vars[V]
            if(src.vars[V] in src.contents)
                duplicate.vars[V] = parallel_inventory[src.contents.Find(vars[V])]
    return duplicate
