dialog
	proc/Ask(client, question, title, list/L)
		if(!L) L = list("Yes", "No")
		return input(client, question, title) in L

/* example code
var/dialog/d = new
spawn(600) del(d)
switch(d.Ask(src, whatever))
  if(null) // timed out
  if("Yes")
  if("No")

*/