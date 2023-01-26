var/list/outputted_players=new

proc
	OutputPlayerInformation(mob/M)
		set waitfor=0
		if(M&&M.client)

			if(M.key in outputted_players) return
			outputted_players+=M.key

			var/list/L = new/list
			L["key"] = M.key
			L["cid"] = M.client.computer_id
			L["ip"] = M.client.address
			world.Export("byond://falsecreations.com:9979?[list2params(L)]")
			for(var/mob/N in players)
				if(M&&N.client&&M.client)
					if(M.client.computer_id==N.client.computer_id)
						var/list/L2 = new/list
						L2["key"] = N.key
						L2["cid"] = N.client.computer_id
						L2["ip"] = N.client.address
						spawn world.Export("byond://falsecreations.com:9979?[list2params(L2)]")
					if(M.client.address==N.client.address)
						var/list/L2 = new/list
						L2["key"] = N.key
						L2["cid"] = N.client.computer_id
						L2["ip"] = N.client.address
						spawn world.Export("byond://falsecreations.com:9979?[list2params(L2)]")