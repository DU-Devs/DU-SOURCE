#define element .
proc
	//separates a string separated by any symbol into a list and returns it
    parse(string, separator)
        var
            length = length(string)
            list/words = list()
            position = 1
        element = findtext(string, separator, position)
        while(position <= length)
            if(element > position || element == 0)
                words += copytext(string, position, element)
            if(element)
                position = element + 1
                element = findtext(string, separator, position)
            else position = length + 1
        return words

mob
	proc
		ClientColorFlick(rgb)
			if(!client) return
			var/c = client.color
			client.color = rgb
			sleep(5)
			client.color = c

		ClientColorInvertFlick()
			if(!client) return
			var/c = client.color
			client.color = list(-1,0,0,0, 0,-1,0,0, 0,0,-1,0, 0,0,0,1, 1,1,1,0)
			sleep(5)
			client.color = c

atom/var/transform_size = 1

atom/proc/SetTransformSize(n = 1)
	var/mult = n / transform_size
	transform *= mult
	transform_size = n
	if(light_obj) light_obj.SetTransformSize(light_obj.transform_size * mult)

//This is from the library Screen Arrows by Kaiochao, but I have modified it
mob
	proc/PointArrow(obj/Arrow, atom/Target, MinDistance, ArrowDistance, instant_update = 0, dist_mod = 1, do_rotation = 1)

		if(!client) return

		if(!MinDistance) MinDistance = client.bound_height * 0.4
		if(!ArrowDistance) ArrowDistance = client.bound_height * 0.33 * dist_mod

		var/dx = Target.Cx() - Cx()
		var/dy = Target.Cy() - Cy()
		var/dot = dx*dx + dy*dy

		if(dot < MinDistance * MinDistance)
			Arrow.screen_loc = null
			return
		Arrow.screen_loc = "CENTER"

		var/matrix/m = new
		m *= Arrow.transform_size
		if(do_rotation)
			m.Translate(0, ArrowDistance)
			m.Turn(dx > 0 ? arccos(dy / sqrt(dot)) : -arccos(dy / sqrt(dot)))
		else
			var
				ang = get_global_angle(src,Target)
				x_offset = ArrowDistance * cos(ang)
				y_offset = ArrowDistance * sin(ang)
			m.Translate(y_offset, x_offset)

		if(instant_update) Arrow.transform = m //initial(Arrow.transform) * m
		else
			animate(Arrow)
			animate(Arrow, transform = m, time = sense_arrow_update_rate)


/*proc/MoveByAngle(mob/m, ang=0, spd=5)
	var
		vx = spd * cos(ang)
		vy = spd * -sin(ang)
	m.Move(m.loc, 0, m.step_x + vx, m.step_y + vy)*/

atom/movable/var/tmp
	fraction_x=0
	fraction_y=0

atom/movable/proc/MoveByAngle(ang=0)
	var
		xx = cos(ang)
		yy = -sin(ang)

	if(xx > 0)
		fraction_x += xx - round(xx)
		xx = round(xx)
	else
		fraction_x += xx - (-round(-xx))
		xx = -round(-xx)

	if(yy > 0)
		fraction_y += yy - round(yy)
		yy = round(yy)
	else
		fraction_y += yy - (-round(-yy))
		yy = -round(-yy)

	Move(loc, dir, step_x + xx, step_y + yy)

proc/vector_step_toward(mob/a,mob/b,step_speed)
	if(!step_speed) step_speed = a.step_size
	var/ang = get_global_angle(a,b)
	return vector_step(a,ang,step_speed)

proc/vector_step(mob/a, ang = 0, step_speed)
	if(!a) return
	if(!step_speed) step_speed = a.step_size
	var/xx = ToOne(step_speed * sin(ang))
	var/yy = ToOne(step_speed * cos(ang))
	return a.Move(a.loc, a.dir, a.step_x + xx, a.step_y + yy)
	//a.dir = angle_to_dir(ang)

//where north is 0 and it goes clockwise to 360. if b is directly above a then it will be 0
proc/get_global_angle(mob/a,mob/b)
	if(!a || !b) return 0
	var/ang = arctan(b.bound_center_y() - a.bound_center_y(), b.bound_center_x() - a.bound_center_x())
	ang += 360
	if(ang > 360) ang -= 360
	return abs(ang)

proc/arctan(x,y)
	if(!x && !y) return 0
	var/n = arccos(x / sqrt(x * x + y * y))
	if(y >= 0) return n
	else return -n