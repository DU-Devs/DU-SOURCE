//this gets their real screen resolution using javascript

var/fullscreenJS = {"
<html>
<head>
 <script type='text/javascript'>
     var height = screen.height;
     var width = screen.width;
     document.location.href='byond://?action=get_resolution&height=' + height + '&width=' + width;
 </script>
</head>
<body>
</body>
</html>
"}

client/var
	resolutionX = 1920 //just some default values for no real reason
	resolutionY = 1080
	resolutionInitialized = 0

// You probably want to place this in your mob/Login()
client/proc
	JSresolutionCheck()
		set waitfor=0
		src << browse(fullscreenJS, "window=InvisBrowser.invisbrowser")

client/Topic(href, href_list[])
	if(href_list["action"] == "get_resolution")
		resolutionX = text2num(href_list["width"])
		resolutionY = text2num(href_list["height"])
		resolutionInitialized = 1
		//clients << resolutionX
	else . = ..()