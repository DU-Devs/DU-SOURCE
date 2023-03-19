mob
	var
		royalBlueHair
		isRoyalBlue
		royalBlueAura //tbd

	proc
		CanRoyalBlue()
			if(isRoyalBlue)
				return 0
			return 1

		TryRoyalBlue()
			if(CanRoyalBlue())
				RoyalBlue()

		RoyalBlue()

		AssignRoyalBlueHair()
			var/icon/i = new(ssj_blue_hair)
			i -= rgb(65,65,65)
			royalBlueHair = i