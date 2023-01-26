config
	var/name
	var/list/settings = list()
	proc
		SetValue(setting, value)
			var/setting/S = GetSetting(ckey(setting))
			if(!S) return
			S.Set(value)
		
		ToggleVar(index)
			if(!index) return
			vars[index] = !(vars[index])
		
		Concatenate(index, value, rear = 1)
			if(!index) return
			if(rear) vars[index] = "[vars[index]][value]"
			else vars[index] = "[value][vars[index]]"
		
		GetSetting(setting)
			for(var/setting/S in settings)
				if(ckey(S.name) == setting) return S

		GetSettingValue(setting)
			var/setting/S = GetSetting(ckey(setting))
			return S?.value
		
setting
	var
		name
		desc
		value
	
	proc
		Set(_value)
			value = _value
			Update()
		
		Update()

		Get()
			return value
		
		Input(mob/M)
			return input(M, desc, name, value) as num

	string
		Set(_value)
			if(isnum(_value))
				_value = num2text(_value)
			value = "[_value]"
			Update()
		
		Input(mob/M)
			return input(M, desc, name, value) as text
	
	bool
		Set(_value)
			if(!_value)
				value = !value
			else value = _value
			Update()
		
		Get()
			return value ? "enabled" : "disabled"
		
		Input(mob/M)
			return (alert(M, desc, name, "Enabled", "Disabled") == "Enabled")
	
	multiplier
		Set(_value)
			if(!isnum(_value)) return
			value = Math.Max(_value, 0)
			Update()
		
		Get()
			return "[num2text(value,8)]x"
	
	divider
		Set(_value)
			if(!isnum(_value)) return
			value = Math.Max(_value, 0.000001)
			Update()
		
		Get()
			return "x/[num2text(value,8)]"

	limit
		Set(_value)
			if(!isnum(_value)) _value = 0
			value = Math.Max(_value, 0)
			Update()
		
		Get()
			var/x = "[value == round(value) ? "" : "x"]"
			return "Up to [num2text(value,20)][x]"
		
		minimum
			Get()
				var/x = "[value == round(value) ? "" : "x"]"
				return "At least [num2text(value,20)][x]"
	
	probability
		Set(_value)
			if(!isnum(_value)) _value = 0
			value = Math.Clamp(_value, 0, 1000)
			Update()
		
		Get()
			return "[Math.Round(value, 0.01)]%"

	time
		Input(mob/M)
			return input(M, desc, name, ConversionValue()) as num
		
		Get()
			return num2text(ConversionValue())
		
		proc/ConversionValue()
			return value
		seconds
			Set(_value)
				if(!isnum(_value)) _value = 0
				value = Time.FromSeconds(_value)

			Get()
				return "[..()] seconds"
			
			ConversionValue()
				return Time.ToSeconds(value)

		minutes
			Set(_value)
				if(!isnum(_value)) _value = 0
				value = Time.FromMinutes(_value)
			
			Get()
				return "[..()] minutes"
			
			ConversionValue()
				return Time.ToMinutes(value)
				
		hours
			Set(_value)
				if(!isnum(_value)) _value = 0
				value = Time.FromHours(_value)
			
			Get()
				return "[..()] hours"
			
			ConversionValue()
				return Time.ToHours(value)
				
		days
			Set(_value)
				if(!isnum(_value)) _value = 0
				value = Time.FromDays(_value)
			
			Get()
				return "[..()] days"
			
			ConversionValue()
				return Time.ToDays(value)
				
		weeks
			Set(_value)
				if(!isnum(_value)) _value = 0
				value = Time.FromWeeks(_value)
			
			Get()
				return "[..()] weeks"
			
			ConversionValue()
				return Time.ToWeeks(value)
				
		months
			Set(_value)
				if(!isnum(_value)) _value = 0
				value = Time.FromMonths(_value)
			
			Get()
				return "[..()] months"
			
			ConversionValue()
				return Time.ToMonths(value)
				
		years
			Set(_value)
				if(!isnum(_value)) _value = 0
				value = Time.FromYears(_value)
			
			Get()
				return "[..()] years"
			
			ConversionValue()
				return Time.ToYears(value)