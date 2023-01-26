var/const
    KHU_HTML_HEADER = "<meta http-equiv='Cache-Control' content='no-cache, no-store, must-revalidate' />\
						<meta http-equiv='Pragma' content='no-cache' />\
						<meta http-equiv='Expires' content='0' />\
						<meta http-equiv='Content-Type' name='viewport' content='width=device-width, initial-scale=1.0'>\
						<meta charset='UTF-8'>\
						<meta http-equiv='x-ua-compatible' content='IE=edge'>"


var/regex
	biggest = new(@"\[biggest\](.*?)\[\/biggest\]", "im")
	bigger = new(@"\[bigger\](.*?)\[\/bigger\]", "im")
	big = new(@"\[big\](.*?)\[\/big\]", "im")
	small = new(@"\[small\](.*?)\[\/small\]", "im")
	smaller = new(@"\[smaller\](.*?)\[\/smaller\]", "im")
	smallest = new(@"\[smallest\](.*?)\[\/smallest\]", "im")
	bold = new(@"\*\*(.*?)\*\*", "gim")
	italics = new(@"\*(.*?)\*", "gim")
	textColor = new(@"\[color:(#\w{6}|rgb\(\d{1,3},\d{1,3},\d{1,3}\))\](.*)\[\/color\]", "im")