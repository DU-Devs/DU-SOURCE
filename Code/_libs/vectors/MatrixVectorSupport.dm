
matrix
	Translate(x, y)
		if(istype(x, /vector))
			var/vector/vector = x
			return ..(vector.X(), vector.Y())
		return ..()

	Scale(x, y)
		if(istype(x, /vector))
			var/vector/vector = x
			return ..(vector.X(), vector.Y())
		return ..()
