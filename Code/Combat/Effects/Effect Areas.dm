effect_area
	proc/ContainsPoint(X, Y)

	rectangle
		var
			lower_x
			lower_y
			upper_x
			upper_y
		
		New(lowerX, lowerY, upperX, upperY)
			lower_x = lowerX
			lower_y = lowerY
			upper_x = upperX
			upper_y = upperY
		
		ContainsPoint(X, Y)
			return (X > lower_x && X < upper_x) && (Y > lower_y && Y < upper_y)
	
	circle
		var
			center_x
			center_y
			radius
		
		New(centerX, centerY, _radius)
			center_x = centerX
			center_y = centerY
			radius = _radius
		
		ContainsPoint(X, Y)
			var/dx = center_x - X, dy = center_y - Y
			return dx * dx + dy * dy <= radius * radius

proc/CreateRectangleArea(lx, ly, ux, uy)
	return new/effect_area/rectangle(lx, ly, ux, uy)

atom/proc/IsInEffectArea(effect_area/area_checked)
	if(!istype(area_checked, /effect_area)) return 0
	return area_checked.ContainsPoint(Px(0.5), Py(0.5))

atom/movable/IsInEffectArea(effect_area/area_checked)
	if(!istype(area_checked, /effect_area)) return 0
	return area_checked.ContainsPoint(bound_x * 0.5 + Px(), bound_y * 0.5 + Py())