
datum
	proc/Method(path)
		return new/callback/method(src, path)
	
	proc/Callback(path, list/callback_args)
		return call(src, path)(arglist(callback_args))

callback/method
	parent_type = /callback/function

	var/datum/_source

	New(datum/source, path)
		..(path)
		_source = source
	
	Call(...)
		return _source?.Callback(_path, args.Copy())
	
	operator~=(callback/method/other)
		return ..() && _source == other._source
