
callback/chain
	
	var/list/_calls

	proc/_Match(list/list, target)
		for(var/match in list)
			if(match ~= target)
				return match

	New(list/calls)
		..()
		if(!islist(calls))
			_calls = list(calls)
		else _calls = calls

	Call(...)
		for(var/callback/callback as anything in _calls)
			callback.Call(arglist(args))
	
	Calls()
		return _calls.Copy()
	
	operator+(callback/gain)
		return new/callback/chain(_calls + gain.Calls())
	
	operator-(callback/loss)
		var/list/calls = _calls.Copy()
		for(var/callback in loss.Calls())
			calls -= _Match(calls, callback)
		switch(length(calls))
			if(0)
				return null
			if(1)
				return calls[1]
			else
				return new/callback/chain(calls)