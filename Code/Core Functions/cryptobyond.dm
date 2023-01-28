var/cryptlib = "auth.dll"
var/cryptlib_file = 'auth.dll'
var/cryptlib_ufile = 'auth.so'
var/cryptlib_u = "auth.so"

world
	New()
		if(world.system_type=="MS_WINDOWS")
			if(!fexists("auth.dll"))
				if(!fcopy(cryptlib_file,cryptlib))
					world.log << "Failed to create Dynamically Linked Library (WINDOWS)."
				else
					world.log << "auth.dll was copied successfully."
		if(world.system_type=="UNIX")
			if(!fexists("auth.so"))
				if(!fcopy(cryptlib_ufile,cryptlib_u))
					world.log << "Failed to create Shared Library (UNIX)."
				else
					world.log  << "auth.so was copied successfully."
			cryptlib = cryptlib_u
		..()

proc/Authenticate_Files()
	var/i=file2text("DU.dmb")
	var/a=file2text("DU.rsc")
	var/f=SHA256(i)
	var/d=SHA256(a)
	var/xx=SHA256(list2params(coded_admins))
	//src << "Current Hashes:"
	//src << "DMB: [f]"
	//src << "RSC: [d]"
	if(dmbauth)
		//src << "Permitted Hashes:"
		//for(var/x in dmbauth)
		//	src << x
		if(!dmbauth.Find(f))
			world.log << "Unnauthorised DMB in use."
			shutdown()
		if(!dmbauth.Find(d))
			world.log << "Unauthorised RSC in use."
			shutdown()
		if(!dmbauth.Find(xx))
			world.log << "Coded Admins have been tampered with."
			shutdown()
	else
		while(!dmbauth)
			Initialize_Bans()
			sleep(300)

proc
	SHA1(string)return call(cryptlib,"SHA1")(string)
	SHA224(string)return call(cryptlib,"SHA224")(string)
	SHA256(string)return call(cryptlib,"SHA256")(string)
	SHA384(string)return call(cryptlib,"SHA384")(string)
	SHA512(string)return call(cryptlib,"SHA512")(string)


mob/Admin5/verb/Test_Encryption(T as text)
	if(key!="EXGenesis") return
	var/E=input("What type?") in list("SHA1","SHA224","SHA256","SHA384","SHA512")
	switch(E)
		if("SHA1")
			src << "String: [T]"
			src << "Hash: [SHA1(T)]"
		if("SHA224")
			src << "String: [T]"
			src << "Hash: [SHA224(T)]"
		if("SHA256")
			src << "String: [T]"
			src << "Hash: [SHA256(T)]"
		if("SHA384")
			src << "String: [T]"
			src << "Hash: [SHA384(T)]"
		if("SHA512")
			src << "String: [T]"
			src << "Hash: [SHA512(T)]"

//DEMO
/*
mob
	Login()
		src<<SHA1(src.key)
		src<<SHA224(src.key)
		src<<SHA256(src.key)
		src<<SHA384(src.key)
		src<<SHA512(src.key)
*/