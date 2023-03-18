
callback

	proc/Call(...)

	proc/Calls()
		return list(src)

	proc/operator~=(callback/other)
		return type == other.type

	proc/operator+(callback/other)
		return new/callback/chain(Calls() + other.Calls())

	proc/operator-(callback/other)
		return src ~= other ? null : src
	