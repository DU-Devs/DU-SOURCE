var/Pixel_Movement=0
world/fps=10
/*mob/Admin4/verb/Toggle_Pixel_Movement()
	Pixel_Movement=!Pixel_Movement
	if(Pixel_Movement)
		world.fps=40
		world<<"Pixel movement was enabled by [key] (THIS FEATURE IS INCOMPLETE)"
	else
		world.fps=10
		world<<"Pixel movement was disabled by [key]"
	for(var/mob/P in Players) P.Pixel_Movement()*/
mob/proc/Pixel_Movement()
	if(Pixel_Movement)
		if(step_size==initial(step_size))
			step_size=3
			//Generate_Bounding_Box(src)
	else
		step_size=initial(step_size)
		bound_x=initial(bound_x)
		bound_y=initial(bound_y)
		bound_width=initial(bound_width)
		bound_height=initial(bound_height)
		step_x=initial(step_x)
		step_y=initial(step_y)
mob/Admin3/verb/FPS()
	set category="Admin"
	var/N=input(src,"Set the frames per second of the server","FPS",world.fps) as num
	if(N<1) N=1
	if(N>50) N=50
	world.fps=N
proc/Get_Pixel(mob/O,x,y)
	var/icon/I=new(O.icon)
	if(ismob(O)&&O.client) return I.GetPixel(x,y)
	else return I.GetPixel(x,y,O.icon_state)
proc/Generate_Bounding_Box(obj/O,Test)
	if(!O.icon) return
	O.bound_height=1
	O.bound_width=1
	var/H=Get_Height(O.icon)
	var/W=Get_Width(O.icon)
	for(var/x in 1 to W) for(var/y in 1 to H) if(Get_Pixel(O,x,y))
		if(!O.bound_x||O.bound_x>x) O.bound_x=x
		if(!O.bound_y||O.bound_y>y) O.bound_y=y
		if(O.bound_width<x-O.bound_x) O.bound_width=x-O.bound_x
		if(O.bound_height<y-O.bound_y) O.bound_height=y-O.bound_y
		//world<<"[O.bound_width],[O.bound_height]"
	O.bound_height=round(O.bound_height*0.7)
/*mob/Admin5/verb/Give_Bounding_Box(atom/movable/O in world)
	Generate_Bounding_Box(O,1)*/