mob/FakePlayer/proc

	StartFakePlayerAI()
		DecideActions()
		FakePlayerTalkQueue()

	FakePlayerTalkQueue()
		set waitfor=0

		for(var/txt in talk_queue)
			Say(txt)
			sleep(length(txt) * 30 + 10)

	DecideActions()
		set waitfor=0
		if(Dead) SeekRevival()
		if(grabber) ResistGrab()

	ResistGrab()

	SeekRevival()
