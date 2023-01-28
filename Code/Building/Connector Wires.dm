/*
Connectors are generic wires, tubes, or whatever they need to represent for every piece of technology on the space station to
be connected to the Reactor, where it can get power, and to the Central AI, which will report problems and/or control certain
aspects of things connected to it.

When a connector is damaged it gets an icon of a broken wire with electricity shooting out and it is dangerous
and it can cause fires on the space station, and reactor overload after enough time without repairing it
players who touch it catch on fire and can spread the fire with other flammable objects they pass by
*/

var
	default_electricity_color = rgb(0,128,255)

var/list/all_connectors = new

obj/Connector
	icon = 'Connector Icons.dmi'
	icon_state = "h"
	desc = "This is just graphical decoration for your base. Connectors automatically connect to other connectors you put beside them. They're just pipes."
	Cost = 10000
	layer = TURF_LAYER + 0.05
	Grabbable = 0
	Dead_Zone_Immune = 1
	Knockable = 0
	var
		tmp
			connector_powered = 0
			last_power_update = -9999
			list/attached_connectors = new
			last_signal_sent_time = -9999

	New()
		GiveLightSource(size = 20, max_alpha = 35, light_color = default_electricity_color, auto_fade = 0, light_icon = 'transparent.png')
		if(light_obj)light_obj.alpha = 0
		all_connectors += src
		for(var/obj/Connector/c in view(1,src)) c.DecideConnectorIcon()
		..()

	Del()
		all_connectors -= src
		..()

	proc
		ConnectorHasPower()
			if(connector_powered) return 1

		SetConnectorPowerStatus(on = 1, signal_sent_time)
			set waitfor=0
			if(!signal_sent_time) signal_sent_time = world.time
			if(last_signal_sent_time >= signal_sent_time) return
			if(last_power_update == world.time) return
			last_power_update = world.time
			last_signal_sent_time = signal_sent_time

			connector_powered = on

			if(on) FadeLightIn(4)
			else FadeLightOut(4)

			sleep(2)

			for(var/obj/Connector/c in attached_connectors)
				c.SetConnectorPowerStatus(on, signal_sent_time)

		ConnectorLightSourceUpdate()
			if(!light_obj) return
			light_obj.icon = icon
			light_obj.icon_state = icon_state
			CenterIcon(light_obj)

		DecideConnectorIcon()
			set waitfor=0

			sleep(world.tick_lag)

			icon_state = "h"

			var
				cn
				cs
				ce
				cw
			for(var/obj/Connector/c in get_step(src,NORTH))
				cn = 1
				attached_connectors += c
				break
			for(var/obj/Connector/c in get_step(src,SOUTH))
				cs = 1
				attached_connectors += c
				break
			for(var/obj/Connector/c in get_step(src,EAST))
				ce = 1
				attached_connectors += c
				break
			for(var/obj/Connector/c in get_step(src,WEST))
				cw = 1
				attached_connectors += c
				break

			if(cn)
				icon_state = "v"
				if(ce) icon_state = "right bend up"
				if(cw) icon_state = "left bend up"
				if(ce && cw) icon_state = "3 up"
				if(cs)
					if(cw) icon_state = "3 left"
					if(ce) icon_state = "3 right"

			if(cs)
				icon_state = "v"
				if(ce) icon_state = "right bend down"
				if(cw) icon_state = "left bend down"
				if(ce && cw) icon_state = "3 down"
				if(cn)
					if(cw) icon_state = "3 left"
					if(ce) icon_state = "3 right"

			if(!cn && !cs && !ce && !cw)
				icon_state = "h"

			if(cn && cs && ce && cw)
				icon_state = "4"

			ConnectorLightSourceUpdate()