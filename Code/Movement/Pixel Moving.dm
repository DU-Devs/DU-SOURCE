var/client_fps = 100

mob/Admin4/verb/FPS()
	set category="Admin"
	var/N=input(src,"Set the frames per second of the server. A value that can be divided by 2 as many times as possible seems to run smoothest, but as long \
	as it is divisible by 2 twice it doesn't seem to make much difference after that. For example 16, is divisible by 2 four times (16, 8, 4, 2, 1) \
	and is known to work pretty good. 20 also works good (20, 10, 5), at least try to make it an even number because it makes a big difference\
	","FPS",world.fps) as num
	if(N<1) N=1
	if(N>100) N=100
	world.fps=N

	N=input(src,"Set the frames per second of the client. 100 is recommended and the max byond can do","FPS",client_fps) as num
	//trust me if you try to allow client_fps to be 999 it will be choppy, idk why. but 100 is fine
	if(N<1) N=1
	if(N > 100) N = 100
	client_fps = N
	for(var/client/c) c.fps = client_fps

proc/Get_Pixel(mob/O,x,y)
	var/icon/I=new(O.icon)
	if(ismob(O)&&O.client) return I.GetPixel(x,y)
	else return I.GetPixel(x,y,O.icon_state)

proc/Generate_Bounding_Box(obj/O,Test)
	if(!O.icon) return
	O.bound_height=1
	O.bound_width=1
	var/H=GetHeight(O.icon)
	var/W=GetWidth(O.icon)
	for(var/x in 1 to W) for(var/y in 1 to H) if(Get_Pixel(O,x,y))
		if(!O.bound_x||O.bound_x>x) O.bound_x=x
		if(!O.bound_y||O.bound_y>y) O.bound_y=y
		if(O.bound_width<x-O.bound_x) O.bound_width=x-O.bound_x
		if(O.bound_height<y-O.bound_y) O.bound_height=y-O.bound_y
		//world<<"[O.bound_width],[O.bound_height]"
	O.bound_height=round(O.bound_height*0.7)

/*mob/Admin5/verb/Give_Bounding_Box(atom/movable/O in world)
	Generate_Bounding_Box(O,1)*/