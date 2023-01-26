mob/var/currency = 0

mob/proc/GainCurrency(amt = 0)
	currency -= amt
	currency = Math.Max(currency, 0)