
proc/function(path)
	return new/callback/function(path)

callback/function

	var/_path

	New(path)
		..()
		_path = path

	Call(...)
		return call(_path)(arglist(args))
	
	operator~=(callback/function/other)
		return ..() && _path == other._path
