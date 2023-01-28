var/Version_Notes={"<html><head><body><body bgcolor="#000000"><font size=3><font color="#CCCCCC">

Go to the Settings button to view the guides where you can learn which buttons do what and other things.<p>

There is also a Race Guide which tells you detailed stats of each race.<p>

Dragon Universe youtube channel (Game Guides): http://www.youtube.com/user/ZFightersReborn

If you want to know what something does, you can use the Examine verb on it. By either right clicking it, or typing
Examine in the input bar.<p>

If you want to help the game spread, like it on facebook, thanks.
https://www.facebook.com/DragonUniverseByond<p>

"}

var/New_Stuff={"<html><head><body><body bgcolor="#000000"><font size=2><font color="#CCCCCC">

<a href="http://www.byond.com/games/Lizard_Sphere_X/1" onmouseover="window.status='Hub'; return true;" onmouseout="window.status=''; return true;" target="_blank">Hub</a>
<br>
<a href="http://s1.zetaboards.com/Neko_Sennin/index/" onmouseover="window.status='Forum'; return true;" onmouseout="window.status=''; return true;" target="_blank">Forum</a>
<p>
Every update also includes quite a few unlisted bug fixes and tweaks to existing system that were too minor to be listed
<p>

v32 in progress<br><ul>
<li>Fixed the bug where running into someone while blast spamming them while they are being knockbacked deals x2 damage with
x2 accuracy because it was counting as hitting them from behind
<li>Fixed the bug where knockbacking someone thru a wall doesn't obey the new wall breaking system and can break much more powerful walls
<li>Fixed the bug where explosion doesnt obey the new wall break system and can break really powerful walls
<li>Fixed the bug where doors are easier to break than walls - now they are the same
<li>Send File verb removed because it probably lags us
<li>League leaders can now set it so that members of the league can't kill/steal from each other
<li>If two fighters arrive to each other at the same time and attack the one with the highest speed will get the first hit in instead of
it being random
<li>There is now a 20 minute wait between self destructs because people spam it in almost every battle when they start losing, it's lame
<li>Buffed kaioken
<li>A new toggle for admins to make the game announce to everyone when dragon balls become active
<li>Fear is back on but with changes to hopefully make it work correctly but I wouldn't bet on it. Runners get really out of hand without a
fear system.
<li>Fixed a bug with scrap absorb where a person can make a blank android in battle then absorb it, now whatever scraps they absorb
must be from an android that was created 30+ minutes ago
<li>Disabled fear again
<li>Moved the typing area to it's own draggable window because it was somehow interfering with the chat box causing it to scroll up randomly
<li>New level 4 admin command: Set knowledge cap mod. Determines by how much the global knowledge cap will adjust to keep up with the average BP
<li>Started filling in jagged edges on the map, right now I've only done it to 1 island, the tournament island in heaven, if it works out
I'll try to do them all that way.
<li>Android stat builds are now unsensable
<li>Fixed the shield double anger bug
<li>The sense/scan tab can now be sorted by power or distance, click Escape to open Settings then go to Change sense/scan tab ordering.
<li>Level 4 admins can now toggle off/on players gradually losing unbanked resources while logged out
<li>When fighting your own simulation or splitform knockbacks will be ignored for convenience so there is no more need to set knockback to 0
every time
<li>Fixed the bug where people can go past the stat cap on 0x stat gains, it had to do with the time chamber
<li>The revive orb can no longer revive androids, but more options for androids to come back to life are planned
<li>There is now a global senzu limit of 200 and no more can be grown past that limit due to lag reasons
<li>If someone tries to take dragon balls off planet they will immediately return to their planet, now if a person wants to collect the
dragon balls they have to stay and fight for them not run off to hide
<li>The marker above evil people's heads is now gone because people hated it and instead the sense tab now shows good from evil
<li>Androids are now locked at 1 BP with 1x BP Mod and are fully reliant on cyber bp, which they now recieve a +85% boost to to compensate.
Androids no longer ascend, and this makes special things such as the time chamber and sacred water and wish for power useless for them.
<li>It would seem that the bp spiking bug was from people intentionally bug abusing namek fusion to fuse with their own clone back and forth
whenever they needed extra power. This extra power would send them between 1.35 and 1.5x stronger than the strongest person online. It should
now be fixed.
<li>For some reason Dragon Balls were set to enable every 1 hour which is far too often, it has now been put back to how it was, which is
every 3 hours.
<li>Admins can now toggle door killing on and off
<li>Legendary Super Saiyan had a bug that caused the energy drain in their form to be far less than it was supposed to be. The form is stronger
than Super Saiyan 2 but weaker than Super Saiyan 3, so the drain was in between those. Now it should be proper.
<li>Legendary Saiyan was made slightly more common, the old requirements for Legendary Saiyan to appear in the race menu were that 1)
No Legendary Saiyan must currently be online, 2) The server must have been up at least 10 minutes, 3) The last Legendary Saiyan must have
been created over 5 hours ago. Now I have changed it to those same requirements except #3 is now only 2 hours not 5 hours.
<li>Buffed extendo arm. Majins and Aliens can grab from 150 tiles away. Extendo Module for cyborgs can go 250. Nameks go 500.
<li>Drones can now be ordered to get in or out of ships. The ship must be in sight of you. And so must the drones you want to get in it.
<li>Now when someone dies instead of losing all their soul contracts they lose 17% of them
<li>Drones with the Rebuild module will now prefer to respawn at a Cybernetics Computer on the same Z coordinate as themself, if one can
not be found, it will prefer one in the same planet even if it is a cave, if neither it will pick randomly from all available computers.
<li>Finally fixed that annoying bug where the chat box starts scrolling up on its own, this happened to me like every 30 seconds.
<li>Gravity now kills you if you get knocked out in it twice in a row. The whole "will not be affected by gravity for 2 minutes" thing is now gone.
<li>Streamlined the Simulator's interface (the thing that makes hologram fighters from science) so you can either click it or bump into it
and it will toggle a simulated fighter on or off for you to fight
<li>Added Planet Vegeta Fitness, a gym that parodies the biggest chain of gyms in America called Planet Fitness,
which people make fun of for numerous reasons, such as offering free pizza and donuts, and kicking you out of the gym if
you work out too hard, or if anyone there thinks you "look judgemental", or if they believe anything you do there is "not fair", such
as bringing your own resistance bands, then someone goes to the front desk and asks for resistance bands, then the desk says they don't have
them, so the person says "thats not fair" so the employee goes and kicks you out of the gym because you brought your own resistance bands
and it's not fair to others that they can't have them too. 'Murica
<li>I believe offline gains were causing the BP spikes and it should now be fixed.
<li>The game will no longer allow building at the death spawn within 50 tiles except for on the clouds. So the area can still be blocked off
but only by creating a border of walls around the entire island.
<li>Stat total now plays a role in how effective your character is at breaking walls. Before, only BP mattered. But this meant only BP or
powerup whores etc could ever break walls. I don't know if this system will work out but this is how it is for now.
<li>Fixed the item drop system to act properly when item drops on death are toggled off by admins. People will now still drop resources and
special items such as Dragon Balls or Shikon Jewels when they die. So no more people self destructing as soon as they start to lose a fight
just so that they don't get their items stolen.
<li>Can no longer rename something to all spaces "     ". All names must contain a valid letter or number A-Z or 0-9
<li>Fixed the bug where villain will do 0% damage against certain people
<li>Super Saiyan 4's stat effects should now be accessible thru the Examine command if you examine "Super Saiyan 4 Description"
<li>Era reset no longer wipes most banked items except for ones that would interfere with the era reset such as DNA
<li>The hero/villain rank can now only be gotten if the character's BASE bp is in the top 30% of all players relative to their bp mod. This
should further prevent random alts and weak scrubs from getting a rank they will either do nothing with or can't handle anyway.
<li>Alignment can now be changed every 5 hours instead of 10 hours
<li>Added a new public command called test_report_gains which every 5 seconds tells you how much base bp you gained, this will be removed
once I use it to figure out some problems I think might exist, til then enjoy the extra insight into your training gains.
<li>Fixed a bug where spar gains often did not work properly resulting in pretty much zero gain except for leeching
<li>Changed wish for power again for more consisten power gain and fixed certain circumstances that resulted in an insane boost
<li>Buffed all the ki attacks that nobody ever uses because they weren't good enough to be viable. So almost every ki attack except blast and
beams. Especially the most crappy ones like spin blast and genocide.
<li>Good can no longer use heal on evil when alignment is on
<li>In sagas mode, heroes and villains are not eligible to regain the rank thru seniority unless they have killed at least one hero/villain,
meaning those who have had the rank but did nothing with it can not regain it after logging back in.
<li>Level 4 admins can now toggle the dropping of items on death, meaning if this is off then items must be explicitly stolen from someone
before killing them.
<li>Fixed the bug that allows a person to powerup endlessly without draining
<li>No need to manually set knockback to 0 each time you start AI training, it will handle it itself for convenience
<li>Fixed the bug where sometimes a player gets kicked from the player list even though they are online still, causing various problems such
as not seeing text chats.
<li>Players with drone ai installed on themself can no longer break any wall by just hitting it enough times, however NPC drones still
can, but their ability to do so has been nerfed. Switching out of a body now disables auto attack, so they can't exploit it by installing
drone ai on themself, putting auto attack on, then switching out of the body.
<li>Senzus and T Heals no longer multiply regen/recov but are additive instead
<li>Fixed T Heal never wearing off
<li>I think Era Reset is now fixed (Attempt #2)
<li>Voting for era resets or pwipes can now be enabled separately by level 4 admins
<li>Countdown is now added to player logs
<li>I think I fixed the AI training bug where a splitform will just wander off
<li>I think I fixed ship interiors randomly swapping around. Ships may need to be destroyed and remade for this to work.
<li>Fixed a bug where ships enable themselves after every reboot even if admins disabled them
<li>Fixed the bug that lets people stack shadow spar
<li>It seems wish for power is now fixed
<li>Fixed a bug with auto rank bugging out of the person simultaneously ascends while receiving the rank
<li>Disabled fear for being too buggy
<li>Pwipe voting is able to be turned on again because era reset has bugs and I haven't fixed them in so long
<li>Ascension has been made 15% stronger which puts it at exactly equal bp of a mystic ssj2
<li>Fixed the resource duplication bug involving mind swapping into zombies.
<li>Fixed many runtime errors, especially the spammy ones
<li>Vote delay is much longer
<li>Fixed the bug that stops people from recovering health. It originates from the android bug to get 0x regen, which causes a math error
in the healing loop code, causing it to stop for everyone.
<li>Added lv4 admin command 'set zenkai mod' for the server
<li>Nerfed absorb
<li>Disabled the external ban check because I disagree with how it is being used, only in-game bans now for this server
<li>I think I fixed the bug where people retain knowledge after an era reset
<li>Fixed a bug where a person could power up forever without any drain if they hit powerup while meditating then stopped meditating less
than 1 second after beginning to power up
<li>Removed mark as evil again
<li>I still don't know why hotkeys randomly delete but I made it save a server side backup too so it can restore hotkeys from that if
the player doesn't have a save for hotkeys stored on their computer. If you switch to a server that doesn't have a backup for you then this
will not work. I think maybe something about player's firewalls is preventing BYOND from writing saves to their computer?
<li>It now cost more and more to build houses as the total amount of built tiles rises
<li>Optimization: Reduced amount of loops running on players by 24%, it can be reduced far more (I estimate by 70%) so I will do more later
<li>Fixed fear maybe
<li>Fixed dragon balls always spawning in caves
<li>Fixed the problem where hotkeys delete?
<li>Optimization tests
<li>Removed absorb as a dragon ball wish due to player vote
<li>Updated how the anger timer works but will not reveal the details or it could be abused
<li>I added a new thing for the sagas system, and it applies only to servers set to PVP mode. If the main villain makes a league it is
different than normal leagues, anyone joining it becomes like a henchmen sort of and there are some benefits. View the Sagas/Alignment guide
for details.
<li>Added a new vote that is sort of like pwipe but instead of actually wiping it will reset BP to early levels and strip super saiyan
and so on. Also it wipes banked items and items on the map and player inventory.
<li>Beams now do 60% more damage due to the discovery that they are pretty weak and useless in battle
<li>People can no longer blow up Vegeta and stay in Atlantis, or blow up Earth and stay on Kami's tower, it now recognizes them as
part of the same planet
<li>There is now a 0.4 second immunity time between being stunned to prevent "stun lock" which is being exploited by certain ki builds
<li>You can now grab other players at an angle to make it easier to use strangle against 0 strength ki builds
<li>Body Swap was overpowered so now you have to get someone to 30% health instead of 50% to swap into them and it decreases \
durability/resistance/defense by 5% each
</ul>

v31<br><ul>
<li>The biggest part of this update is the new drag and drop hotkey system. Just press Escape and go to View hotkey menu and assign them
however you want and it should just work.
<li>Updated Ultra Super Saiyan. Use Examine on it for details.
<li>When alignment is on, if a person gets knocked out, any dragon balls they have will drop on the ground to allow a way for good people to
take dragon balls from other good people
<li>I made it quite difficult to abuse the super saiyan inspire system by having friends spam KO the person
<li>Using ki in a tournament will now only track the person you are fighting, to make it easier for ki to be viable even with all those
other spectators around
<li>Removed flash step again for being annoying
<li>Made it so that the hero can not be marked as evil because people were abusing the system to get rid of every hero who got the rank
<li>Fixed a dash attack bug where you dash attack then grab the person so dash attack hits them for every tile you move
<li>Maximum screen size increased from 25x25 to 33x33
<li>Kai teleport spawns are now randomized
<li>Drones can no longer be teleported with Kai Teleport / telewatch / IT
<li>Fixed an exploit where Dragon Balls can be stored on empty clones on ships forever, lots of people were doing it
<li>Due to complains that drone's move superhumanly fast with insane reflexes, I increased their movement delay by 35%
<li>Prison now counts as afterlife so that dead people can be there without the game returning them to afterlife then back to prison
over and over forever
<li>Fixed knockback lock, where if you get spammed with knockbacks in a short time period you are stuck in the animation. I THINK it is fixed
<li>Fixed a bug to give drones death regen without having to install the death regen module making them nearly unbeatable sometimes
<li>Scrap repair and rebuild modules now cost 3x more
<li>Drones will no longer genocide binded people who are within 20 tiles of the bind spawn
<li>Prison time has been halved
<li>Made Kaioken better. More power, less drain.
<li>Fixed a nearly unbeatable "shield + recovery" build where each time they run out of energy they zanzoken out of the battle and recover 100%
energy in like 2 seconds then run right back in, and repeat forever til they win. Now, if you have used shield is the last 20 seconds, you will no longer
experience the increased energy recovery while meditating until it has been more than 20 seconds
<li>Bounty drones will no longer come after people in tournaments
<li>A person can no longer use shockwave while firing a beam or being shot with a beam
<li>When alignment is on I added a harsh penalty if a person of good alignment attacks another good person against their will. Because that
would mean they are not good, but rather evil masquerading as good and abusing the alignment system, which is far too common. So to trigger this penalty, the
person being attacked must say either "stop" or "STOP" in say, and if the other person continues attacking past a certain time frame, they
will be labeled as evil, and have a 1 minute debuff placed on themselves which causes them to take 25x damage from whoever they were attacking.
So if you are good, you may want to check if it is okay with another good person before attacking them, or at least stop when they say stop.
<li>Using a custom buff to increase energy mod or recovery will no longer increase your powerup soft cap or how fast you powerup, using a
buff to boost those stats is now primarily to make training more convenient, but it will still increase other things that rely on ki mod or
recovery as it did before, such as shield becoming more powerful with more energy mod, and so on.
<li>Nerfed Majins
<li>Bounties can now only be claimed by the person who called a Bounty Drone to jail the target. If they are captured any other way then
the bounty is an open bounty that can be claimed by anyone.
<li>Give power can no longer be used inside Vegeta's Core due to a type of bug where you can have alts teleport in and out to heal you so
you can stay in there forever
<li>Making a clone at a genetics computer now works properly again
<li>Fixed a bug where if a person relogs while damaged they are removed from the player list making them immune to admin commands
and undetectable to drones
<li>Fixed a bug with the powerup system's energy drain that made it so a person who is almost all energy mod can stay powered up to 500%+
for 5+ minutes straight without resting, basically experiencing no drain. And in some cases reaching 1000s of % power like it is nothing
<li>Balanced give power, if a person with much higher energy mod gave power to someone else, they could get up to a 21x boost in how much
power they raise the person's power. Now it is capped between 0.5x and 2x the standard transfer rate and the scaling is different.
<li>The rebuild module now has a 12% failure chance where it will fail to rebuild the android
<li>Health drain from overdrive raised from 1% per second to 1.5%
<li>Bp boost from overdrive lowered from 2x to 1.5x
<li>Drones should now be able to use scrap repair
<li>Drones should now be able to use the rebuild module
<li>Hiding in a spacepod no longer makes you invisible to drones
<li>Hopefully I fixed Drones glitching thru doors randomly, and getting stuck against walls then proceeding to do nothing forever
<li>Automatic combo teleporting disabled again and Flash Step ability enabled
<li>Making clones or blank androids now costs about a million resources each because people were spamming them endlessly to lag the server
<li>Powerup drain scales much higher if a person powers up to insane levels, so they won't be able to hold ridiculous power ups very long
<li>Repair Android/Cyborg will now reset their powerup level to 100% to fix a sort of bug where a person can powerup to like 6000% by
spamming repair
<li>I completely changed the Sacred Water, it no longer temporarily sends you to 150% health and energy. Instead it will provide a small power
boost to your static BP but only if your static BP is less than 12% of your base BP, otherwise it gives nothing. But it will fully refill
health and energy. It can also be used endlessly as long as you meet the static BP requirement.
<li>Modules which boost energy mod will no longer increase how high a person can power up, but modules that reduce energy mod will still
reduce how high they can power up.
<li>Made some changes to power up to balance it and also fixed a bug where a person powers up in some buffs that raise recovery/energy to reach
insane levels then debuffs and retains those levels. Now, how high you are powered up will revert to however high it would've been if you
powered up the entire time in your current state. I saw someone power up to 1100% and that is just too extreme.
<li>Fixed a bug where a player's telewatch password frequency can be stolen if they have a Giant Teleport Nullifier and someone else uses
"Remove allowed frequencies" which will show their telewatch passwords to the person using it
<li>A sword can now have a silver blade attribute which makes it do slightly less damage against the living but much more damage against
undead (vampires, zombies)
<li>When alignment is on, bounties can only be placed on evil players.
<li>Destroying a planet causes the prison to automatically place a bounty on you
<li>When alignment is on, the prison will automatically use it's funds to place a bounty on a random evil person every 2 hours, if it has
collected enough to do so from taking resources from player's who have been previously jailed.
<li>Admins can now toggle whether players can ignore instant transmission or not
<li>Added wall upgrader bots to the science tab, right click them and hit examine for details on how to use them
<li>Unmastered super saiyan 3 now drains a lot more energy, it will not become very usable until sufficiently
mastered
<li>Attack barrier will now fully protect the user from all explosion damage
<li>In PVP mode with alignment on, evil players will have a red crystal thing above their head
<li>Combo teleporting for melee now works differently, you can no longer endlessly do it, you have a set amount of
charges before it has to recharge. How fast it recharges depends on your speed. How many you can do at once depends
on how much higher your offense is compared to the defense of the person you are attacking. Better defense will not
decrease the base amount of combos an attacker can do against you.
<li>The jail now permanently takes half the bounty money for itself so that people can't jail others for free
by jailing them then collecting all their own money back
<li>The time chamber can now be used every 9 hours instead of 21 hours, but only gives 12x BP gains instead of 30x
<li>Fixed a bug to make overpowered drones by giving them energy before setting them loose so every copy of them has
like 200% energy and it doesn't go down on them
<li>Made a bunch of random changes to the stat system to get rid of some of these stale stat builds people
keep using, changing things up a little, but I'm not sure exactly what effect it will have. Old builds that were
good might not be so good any more, old builds that were bad might be better.
<li>Dragon balls now grant a single wish but are active much more often
<li>Fixed the fear system I think, and turned it back on, but the penalties are no longer as harsh as they were.
<li>Fixed it so that dragging someone out of a tournament to win will disqualify the grabber
<li>Using genetics computer to switch bodies can now only be done once every 10 seconds to prevent a bug that
happens when people spam it
<li>Small performance optimizations on the most laggy features of the game
<li>Big optimization: Players logging out causes a lot of lag, in fact the most lag of anything, because when
they log out the game deletes 100s of items they are carrying. Now they do not get destroyed, they are just
cached and given back to the person when they log in again. The only problem I see from this is the game will
use even more memory now for the server that hosts it.
<li>Automated reboot every 10 hours
<li>Removed npcs from displaying in sense tabs because players voted and said it was annoying
<li>Fixed the bug with genetics computers where people would keep modules installed after redoing stats then
uninstall them to mess up your stats, sometimes making them extremely overpowered
</ul>

v30<br><ul>
<li>Fixed a lot of the bugs that EXGenesis told me and also fixed a lot of runtime errors
<li>Added a new admin command called Toggle-guests which will either allow or disallow guest keys from being on
the server
<li>There was a problem with manually shadow sparring where a lot of extra delay was added, fixed that so now
manually shadow sparring is viable again
<li>I wrote a new guide on how to get strong faster, view it in Settings>View Guides
<li>Giant form gotten from the dragon balls is no longer teachable
<li>Mark as evil command is back to mark people who are faking being good and abusing the alignment system
<li>People can no longer go oozaru in skill tournaments
<li>Gravity costs half as much since only like 5% of the entire population can ever afford a fully upgraded
gravity from what I'm seeing
<li>Made it so good people can not force inject, force cyber bp, or uninstall modules from other good people
against their will
<li>Made it so good people can not order drones to do evil things
<li>New admin command called toggle-admin-voting so that admins can or can not be voted by players
<li>Revival altar now forces you to go to spawn, it is no longer optional. I'm trying to make living world the
place where all the action is, not have every living person in afterlife for no good reason
<li>Fixed Instant Transmission acting really weird I think
<li>Admins now have a bp-soft-cap command to let them set a bp where if people start going past that amount then
their gains start slowing down, for example to prevent getting super saiyan earlier than it should be
</ul>

v29<br><ul>
<li>A door's bp will now properly reset when a wipe happens
<li>Fixed villain killing sprees so that killing dead people does not count toward the spree count and also the
villain's alts do not count
<li>Binds will not return you to hell while in a tournament
<li>Fixed the bug where gun pods can kill people in the tournament
<li>Nukes can no longer hurt people at the tournament
<li>Nukes will no longer spawn radiation in heaven so that the tournament can not become radioactive
<li>Toggle-pvp-or-rp-mode command for admins to set the server to RP or PVP
<li>Since the 100% anger chance from packs no longer matters, they now receive Kai Teleport as well, but only on
PVP servers. And 1 minute off their anger wait timer on RP servers.
<li>All anger chances are now 100% but anger can only be used in short bursts, after 1 minute of anger you become
calm again. The wait time in between angers is now only 4 minutes instead of 10 minutes.
<li>Admins can now turn off death anger giving super saiyan using the command Toggle-death-anger-gives-ssj
<li>Admins can now turn off Super Saiyan Inspire, this is mostly for RP servers. Toggle-ssj-inspire command.
<li>Fixed stealing resources from knocked out people
<li>Giant form is now in, Nameks and Makyos can self learn it, Daimao rank starts with it. It can only be taught to
the same race, and you can wish for it on dragon balls
<li>The regenerate ability is now not self learnable, Nameks start with it, and it can only be taught to the same
race, and you can learn it from dragon balls.
<li>The main hero can now be voted to lose the rank
<li>Anger now increases energy drain from any attacks you use by the same factor that it increases your BP by
<li>Materialize now cost more SP, and can only be taught to the same race, and is not self learnable
except for Namek, Kai, and Majin. Certain ranks or dragon balls can provide the skill to other races.
<li>Armor customization options are now different
<li>Nerfed swords because they are too popular and this is dbz not some sword anime and the majority of builds
should prefer unarmed fighting
<li>Changed side-stepping to be an instant zanzoken instead of a slow slide into position, because of how useless it
is because your opponent has always moved by the time it takes for you to slide into position. It will use a few
zanzoken charges to side step now. It should now be useful for scoring side hits, since side hits have x2 accuracy,
and backhits x2 accuracy and x2 damage
<li>Fixed an auto attack bug that caused it to be unreliable when moving around a lot in a fight and it would not
work most of the time
<li>Added the fear debuff system where if a person runs their character will become fearful of their enemy which
causes them to move slower and take more damage.
I added this because running away from fights is far too effective,
and running is lame anyway and should have penalties.
<li>Flash step has been removed for proving not to be a good solution to the runner problem, due to the negative
impact it has on the combat system
<li>Added combo toggle back on to see what it is cuz I forgot a little
<li>Oozaru bp boost is now completely different, it will be a very high multiplier at low base bp levels but
drop off til it is an x2 bp boost
<li>Oozaru stat boosts are now +30% strength/durability/resistance and -70% speed/defense
<li>Oozaru control is no longer learnable until 5000 base bp
<li>Upgrading turfs should no longer be a major source of lag because everyone's built stuff is stored in
subdirectories based on who built it so that it can loop thru only what it needs to
<li>Fixed the manual absorb module
<li>Alignment+Sagas guide updated
<li>You can no longer join a tournament while body swapped to escape
<li>Evil people can now steal the main villain's rank if they manage to kill them
<li>All guides are viewable in the settings button and there is a new guide for alignment/sagas
<li>Cached zombies to reduce lag.
<li>Cached shockwave graphics for re-use instead of generating a new one each time because with many players it
becomes the laggiest thing with all the attacks being thrown around
<li>Pods should no longer get caught on every object in their path
<li>Fixed a bug where people could use planet destroy on heaven/hell/etc if they teleport to them half way
between using it
<li>Fixed a wipe ruining bug where people install certain modules then redo their stats then uninstall modules
afterward for 10x regen/recov boost and some other stat boosts
<li>Blast homing was really laggy so I cached the result of blast homing so that blasts don't retarget with
every step they take. They just find a target once and keep using it so long as it remains viable. If no viable
target is found it won't recalculate again for 5 steps instead of every step.
<li>Cached core demons to reduce the lag since they don't actually delete when killed they are just stored
for later use. Deleting mobs causes a lot of lag. Zombies still aren't cached yet.
<li>Drinking out of a well will now longer send you past 100% health/energy because people use that to cheat
all the time by going to 150% health/energy then teleporting to someone they want to kill, and it is beyond
annoying now so it is gone
<li>Scatter shot now uses automatic target selection the same as flash step. It will target the last person
you attacked, if the last person you attacked is not a valid target, it will select the next most valid target.
<li>You can now become a super namek with only 5 million base bp. It will add up to 15 million extra bp.
You can only become a super namek by fusing with your counterpart.
<li>The BP requirement to learn and use ultra super saiyan is now 32 million current BP instead of 24 million
<li>In Planet Vegeta's Core music will play. 3 different songs will play depending on the BP you have in there,
if Pikkon's theme is playing it means you are using too much BP and the core is too easy for you, if Ginyu's theme
plays then you are not using too much BP but you could stand to use less for increased gains. If Vegeta's
training theme plays then you are using 2x the average BP or less, which is the perfect amount for maximum gains.
The song will not switch immediately if you change your bp, it will switch when the previous song ends.
Just use 2x the average BP in there for optimum training, gains don't get any higher than that even if you power
down more.
<li>Fixed the "1 bp in tournament" bug
<li>Notes about Planet Vegeta's Core. 1) Vegeta's Core is survival/torture training 2) You gain a ton by just being
there in the harsh conditions 3) Killing the core demons will refill your health 4) The lower you power down in
there the more you will gain because the difficulty of surviving rises 5) Powering down to 2x the average bp or
below is the maximum amount of gains you can get from the core so for example powering down to 0.1x the average bp
won't help you gain more you'll just die faster 6) For the most part energy/force/resistance/defense/regeneration/
recovery stats do not matter in the core because you can not refill health there and resistance/defense will not
reduce any damage from the acid smog or explosions or meteors 7) Only BP and durability will reduce the damage
you take from the core explosions/smog/meteors
<li>In the settings button you can now ignore Shunkan Ido, so that nobody can randomly teleport to you using it.
This was voted by players 14 to 5
<li>Keep body can now only be taught to those of the same race, so basically only Kais and Demons will have it now
<li>Keep body is now more effective it lets a dead person retain 85% of their power instead of 65%
<li>Dead people now only have access to 30% of their power instead of 50% unless they use keep body
<li>You can now use the time chamber every 21 hours instead of 24 hours
<li>Force fields no longer work in skill tournaments
<li>Flash step now has better targeting and can even follow the enemy thru caves in certain situations
<li>People grabbing you before your tournament match starts will no longer cause you to be disqualified
<li>Stealing resources from knocked out people is no longer bugged
<li>SI will now only show people you can successfully teleport to
<li>Reduced melee knockback distance due to a 10 to 7 player vote
<li>Drones can now kill enemy drones. Just declare enemy drones illegal then send the drones to patrol and if
they find enemy drones they'll kill them.
<li>Nerfed stun blasts because of a 19 to 1 vote
<li>Drones now seem to work pretty well and most of their bugs are fixed
<li>Drone options (accessed by robotics tools or cybernetics computer) now has new options: 1) Ability to see
how many drones you have, and what planets they are on. 2) Ability to observe all your drones
<li>Halved the resources of heaven/hell/checkpoint/kaioshin because I don't like how over 85% of all players are in
afterlife all the time.
<li>Nerfed stat whoring again because of player vote (12 to 10). Not much of a nerf because the vote was so close.
<li>Nerfed force fields by 40%
<li>Nerfed Drone AI BP by 40%
<li>Optimized and debugged Drone AI so that drones will work better now
<li>Fixed the bug where NPCs could not be knockbacked ever
<li>Fixed the bug where your show tabs button disappears if you switch bodies
<li>Had to disable taking DNA from monsters animals and zombies and their dead bodies because of a stat bug
that I just can't seem to fix
<li>Due to a bug that I never noticed there was practically no drain from melee attacks, it is now fixed
<li>You can now ignore tournaments in the settings button
<li>Added drivable cars that can go thru anything, have fun while you can!
<li>The time before you can use the altar to come back to life now depends on how powerful you are, the
weaker you are the less time you have to wait to be revived
<li>Removed 2 hidden secrets from the game now that everyone knows what they are. 1) Making armor with protection
level of 1.01 turns it into armor that makes you almost unbeatable 2) Meditating on the throne above the vampire
altar gives you insane BP gains
<li>New aura and hairs from Tobi Uchiha, and fixes applied to other hair icons
<li>Sometimes a random car will come out of nowhere running from the cops and hit you, mangling you for life
regardless of bp! (with sound effects!)
<li>Fixed a bug that ruins beam struggles by making the beam 5x easier to deflect instead of 5x harder
<li>Fixed the bug where stun blasts didn't factor in force so a strength whore with 0 force could stun
blast you a really long time then punch you to death
<li>When imprinting battle power from someone's DNA the amount given can no longer exceed the BP of the person
the DNA was taken from, for example if the DNA is from a human with 1 million BP and 1.2 bp mod and some ascended
namek with like 12x bp mod uses it they won't get 10 million bp any more, the max would be 1 million
<li>Nukes now produce less radiation, do not instantly give you radiation poisoning, and have a max range of
100 instead of 275 now because they aren't as lag free as I thought
<li>Gun5 found the bug that caused the average BP to shoot up ridiculously fast after Super Saiyan is unlocked.
Every time someone made an Elite Saiyan the BP they start with would be nearly 2x more than the strongest person
online because it wasn't taking BP mods into account when deciding how much BP an elite should start with.
<li>Fixed a bug with icers where their forms would double stack with the bp_mult var, causing them to gain much
more than they should from things that boost BP, for example majin instead of giving +10% would give them +21%,
but something that gives them 2x would instead give them 4x, and it just kept getting more exaggerated the more
they can multiply their bp
<li>Had to make it so that a person can only wall upgrade once every 30 seconds because when the map got really
large upgrading a wall would lag badly because of how many turfs it would have to loop thru
<li>Majins now gain nothing from training, and literally can not train, and have no need for weights,
or gravity, but have higher BP mods and faster leeching. They will get no gains from meditate, train, sparring,
peebags, or core training. Shadow sparring will still work for them for stat, SP, and energy gains, but no BP
gain from it.
<li>Many more unlogged bug fixes
<li>Fixed the bug where 2 flying people will fly thru each other while fighting (was really annoying)
<li>Diarea virus will now begin rapidly going away after you have been out of the presence of shitting people for
more than 2 minutes
<li>The diarea virus will only survive an hour after the original virus was created then the virus will die all
at once leaving everyone cured
<li>Explosion will no longer destroy the items of those you kill with it
<li>I put tighter caps on many of the server settings for gains, due to a player vote
<li>Fixed the bug where Half Saiyans go SSj4
<li>Fixed dash attack multi-hit bug
<li>Fixed being able to dash attack and shockwave at the same time
<li>Nukes now are much less laggy and have upgradable range
<li>Fixed a bug to duplicate any item by redoing your stats, dropping it, clicking done, and now you have another
one back in your item list
<li>Radiation can no longer harm you thru walls
<li>The +300,000 resources from packs can now only be recieved once every 30 minutes to prevent a bug where people
with packs make 2 blank androids, and get in them and drop 300k then get in the other and drop it and repeat for
as much resources as you need
<li>Fixed some weird bugs with ships displacing themselves every reboot and making everyone switch to pixel movement
<li>It now costs extra to build within 20 tiles of a spawn
<li>Kaioken starts off giving +5000 per level which can be really extreme early wipe letting people break walls
too easy so I made it work different.
<li>Fixed a wall breaking bug where using kaioken + beam was like using kaioken + powerup at the same time
<li>Fixed the bug where one macro press can cause you to move 3-4 tiles at once
<li>New ability in learn: Oozaru Control
<li>When a Saiyan goes Oozaru they will go berserk unless they learn Oozaru Control
<li>Every 30 seconds 400,000 to 600,000 resources (multiplied by the server's resource mod) will appear randomly
somewhere for treasure hunting purposes
<li>Fixed a stat bug where people would use a stat increasing buff, kill themself in it, take DNA from their body,
revert the buff, then stat imprint the DNA onto themself, raising the stat cap up to double
<li>You can now set a stun attribute to your blast by clicking Blast-Options in the Other tab
<li>Turrets are now more expensive and have less range and slower firing rate than before, but each individual turret is better.
They have more responsive targeting, more damage, more durability, they stun the target, have more knockback.
They are meant more to keep people away than to do damage.
<li>Stun guns are back but work differently. Instead of completely freezing the target they just slow them down.
<li>NPCs now respawn differently. Instead of appearing in the same spot over and over, they'll spawn as a
child of an NPC of their same type that is currently roaming that planet. This also makes it appear
that they roam in packs.
<li>Jungle Planet graphics were greatly improved
<li>Server Info command in other tab (Doniu)
<li>Fixed the bug where relogging in oozaru makes it permanent until you get knocked out
<li>Fixed some bugs where relogging while powering up causes the aura to stay forcing you to redo
overlays.
<li>New regenerator upgrade that heals radiation exposure
<li>Added barrels of toxic waste. When broken they will leave an area radioactive for 6 hours. Exposure
to too much radiation kills you. Demons, Majins, Bio Androids, and Androids are immune to radiation
<li>Sparring a real player is now better. See the training section of the guide for new gain mods for it
<li>Spawns can no longer be made in the time chamber
<li>Fixed a bug where you could get free 2x strength mod if you wear a 0.5x sword before redoing your
stats on a genetics computer, then redo your stats how you want them, and click done, take off the
sword, and you have 2x more strength than you should.
<li>Instead of 8 sets of dragon balls there can now only be 3 (Earth, Namek, Heaven), but instead of
activating only once every 7 hours it is once every 3 hours.
<li>Gravity mastery is now fully leechable but very slowly
<li>Added 'DBZ Mode' where you play as dbz characters. Only 1 player can play them at once. I will
add more playable characters soon
<li>Anger bypasses untapped potential giving you temporary access to your full power
<li>Reincarnating no longer unbinds you
<li>Turret damage lowered a lot, and they are more easily destroyed, but their knockback has been
tripled.
<li>Can no longer build too close to the prison exit
<li>Can no longer put turrets too close to the prison exit or dead people spawn
<li>5 out of 30 Saiyans were Legendary, that is too many. So I added a new condition for Legendary to
appear in the race menu. All the conditions are as follows: 1) No LSSj must currently be logged on 2)
There must be at least 10 Saiyans online 3) It must have been over 5 minutes since the last reboot 4)
There must not have been a Legendary Saiyan created in the last 5 hours (This is the new condition)
<li>Fixed a serious bug with calculating melee accuracy, where speed lowers your accuracy instead of
raising it. The math was inverted. It is now fixed. The sad part is that it has been that way for
years.
<li>So that you can choose the time of your automatic revive instead of it just happening, there are
now wierd crystal ball thingies around that if you click it you can be automatically revived if you
meet the requirements
<li>Fixed a bug where hitting a peebag while having someone else punch you would give you combined gains
of peebag and sparring
</ul>

v28<br><ul>
<li>Improved the map stretching so there is no more leftover black space (letterboxing) when you
stretch the map to display how you want it on your screen by dragging the separator between the map
and the text output + tabs
<li>Weakened default wall health
<li>Improved turret power, range, and durability greatly
<li>Improved force field item power but now once drained it will cause an explosion strong enough to KO
you and also while using it your leech rate is halved because your not using your own power to defend
yourself your using the force field's power, so it isn't as good of training.
<li>Fixes for the new movement code where it will miss a key press or add an extra one for no real reason
<li>You can now move and fire blasts at the same time
<li>You can now move diagonally by holding UP+LEFT arrow keys and so on
<li>Fixed the bug where your own blasts would hit you if you were firing them rapidly and moving at the
same time
<li>Fixed a bug with makosen that causes it to do 10x+ more damage when the target is 2 or less tiles
from you. Now it should be the opposite, the further away you hit them from the more damage it will do.
<li>New icon from Powah, which is a new pale male icon for testing of new animations for spin punch,
spin kick, dodging, genki dama, and kienzan.
<li>New icons from Tobi Uchiha, including lssj/ssj2/ssj3 electrics, new hairs for SSj Goku/Gohan/Trunks/
Kid Gohan, new clothes, and more.
<li>Changed automatic revives. No longer will it mass revive everyone at once. It is now per player,
so if your character has been dead longer than the amount of time the server has for automatic
revives, you will just come back to life. Even if you log out the entire time you do not need to wait
on the next mass revive you will just come back to life if you have been dead more than the time
needed.
<li>Admins can now set auto revives to only revive players below a certain BP compared to the strongest
person. By default only people under 80% of the strongest person's BP will automatically revived.
Anyone above that is considered a pro and death will be more serious for them, they will have to
revive themselves.
<li>Fixed the bug where people kai teleport you out of the tournament and kill you
<li>More new icons thanks to Tobi Uchiha, including better Broly SSj and USSj hairs, Gohan SSj hair,
Broly's waist robe clothing thing, new energy effect for LSSj aura, some new Saiyan Armor icons, and more
<li>New Demon/Vampire/Majin(ability) electric aura, and new beams, new USSj hair for hair25 (Broly's hair)
and color corrected LSSj aura made by <font color=red>Tobi Uchiha<font color=#CCCCCC>. Thanks.
<li>Fixed some bugs with strangle that caused it to do way more damage than normal and also a certain
bug that made it not drain some people's ki at all when a person struggles against them if the
strangler has really low recovery
<li>Doors will no longer spam you for the password to open them if someone knocks you into them or you
run into them more than once
<li>Did the same for banks
<li>Having really bad defense will now negatively affect your ability to precog dodge, but only slightly
<li>Changed up how precog refills, instead of gaining +1 precog dodge every 12 seconds to a maximum of
5, it now will wait til your precogs reach 0 then wait 90 seconds and refill them to the new maximum
of 6.
<li>Fixed death regeneration sending people to their spawn after they come back instead of to their
place of death
<li>Added an 'incline system' where more of a player's power is unlocked as they age to full grown,
each race is different. This is off by default, but some servers wanted it, particularly RP servers.
<li>Admins now have the option to keep the map or items when pwiping, and can set the walls down to
a BP of their choosing, or only delete items that cost more than a certain resource value also
<li>Fixed the hokuto + beam bug
<li>To come back to life by absorbing a living person their base BP must be 100%+ of yours. It used to
be 75%+
<li>Pods can now fly over non-dense roofs
<li>During creation the points put into regeneration and recovery are now limited to 6x
<li>Majins are now immune to all injections, including the use of T-Injections, if you want a
reason then lets just say they don't have DNA or something so it has no effect on them.
<li>Majins are now 3x regen instead of 2x regen and 2x recov
<li>If a dense turf is built on top of a spawn the race will become unavailable
<li>I had to add a new system where you can relog freely up to 3 times within a certain time frame,
after that the game thinks you are spam relogging and will force you to wait 5 minutes before you
can load your character again.
<li>Heavy optimizations in an attempt to reduce lag
<li>Added better spam checking for OOC
<li>Each Super Saiyan level has a bigger beam size than the last, except SSj4 which is the same
size as SSj2
<li>Fixed a method of bug abuse to get death anger by blueprinting an android that is in your SI list
(Because only people in your SI list can give you death anger) then whenever you need death anger
you make and kill a copy of that android and get it.
<li>Fixed the very annoying bug where once a beam pins you against a wall it becomes impossible to
deflect it and you are just stuck there til you are defeated
<li>The Core of Planet Vegeta is now less difficult to survive
<li>Kaioken will now increase beam size
<li>Immortality's death regeneration is now 40% better (faster, stronger)
<li>Bind power now works differently. It will scale much more to how much energy training you have done.
Energy mod helps some but nowhere near as much as how much energy you have per mod.
</ul>

v27<br><ul>
<li>Beams will now become larger as you powerup higher
<li>Made diagonal beams look less like feces spewing from Krillin's ass as Cell kicks him in the balls
with the force of a thousand moons
<li>When there are multiple bags of resources on the same tile, hitting grab will now pick them all
up, instead of having to deal with the annoying popup of which one to get, when intuitively it should
know that 90%+ of the time you want them all
<li>People currently being grabbed will no longer be knocked away by powerful auras
<li>Found out that guns using ballistic damage do 100x damage to npcs, so lowered it to 2x
<li>All NPCs enemies now have unique stats instead of all the same
<li>Humans now have 1.2 bp mod, Tsujin 1.15, Spirit Doll 1.2. Maybe now they won't be entirely useless,
just mostly useless. They still have the lowest bp mods of any races.
<li>Fixed the problem with zombies where if they reach the cap all in the same zone no more zombies can
appear in other zones, so I made it so even when they reach the zombie cap they can still reproduce
but for every new zombie created the oldest zombie will die
<li>You can now mount bombs to any object in front of you by right clicking the bomb in your items and
clicking mount.
<li>Kais suck, most people even say they are the worst race, so I gave them the perk of having 30% more
BP while in heaven or kaioshin planet so they can at least be god-like in their own realm,
except if they join a tournament.
<li>Lowered max view size from 34x34 to 25x25 after confirmation from BYOND that large view sizes will
cause more bandwidth usage, and more lag if there isn't enough bandwidth.
<li>Fixed a bug that Doniu told me where you can kill people in the tournament if you spam lethal on and
off while strangling someone
<li>Fixed the bug where you can put a telepad in front of someone's door, then put a pod behind the
telepad, blow up the pod, and it knocks the telepad thru the door and into their base, so you can
teleport in.
<li>Tried to optimize more stuff, especially npc target finding, to be less laggy
<li>Fixed another infinite resource bug where a person will brain transplant into their alt's body
while the alt's body is waiting to be logged out after damage. Then they would drop the alt's resources
and log the alt back in and the alt would pick up the dropped resources and have double resources,
so you can no longer brain transplant into a player's body that is waiting to be logged out because
it creates 2 copies of them, and because they aren't there to consent to the brain transplant
<li>It now takes time to scrap something, if your speed is the highest online then it will take 5
seconds. Scrapping something worth less than 300k resources will be instant
<li>You now get 80% of the resources in an item when you scrap it instead of just 50%
<li>Spawns are now unscrappable
<li>Turrets were made overall better because it would seem they were useless
<li>You now choose the appearance of your weights by right clicking them, and you can choose any clothes
icon for them now.
<li>Fixed hair10's ssj icons
<li>Fixed spawn redirectors being buggy, I hope
<li>Robotics tools can now redo the stats of androids again, because I fixed the bug with it (I hope)
<li>Genetics computers can now redo the stats of any creature that has DNA, which means anyone except
androids really. But unlike robotics tools, it costs resources to redo the stats using genetics.
<li>Zenkai mod now increases gains from the torture training in Vegeta's Core. The default gains are
multiplied by zenkai_mod^0.3, so Saiyans have 1.5 zenkai mod, which equates to 1.13x gains in the core.
Androids have no zenkai, therefore the core is completely useless to them.
<li>Being able to breath in space reduces the acid smog damage in Vegeta's Core to only 33% of normal,
but if it isn't hurting you as much, then it isn't as much 'torture training' so your gains are lowered
to 70%. The breath in space point from ultra pack will not count, and not affect gains or damage taken
from the smog.
<li>The full heal from injecting RAGE can only happen once every 10 minutes now
<li>Fixed a bug where a person could instantly regenerate using soul contract while in the final realm
<li>Can no longer build in tournament area
<li>Added SI back to learn but it needs more SP now
<li>This update is now required in order to appear publicly on the hub, because I can't have these
infinite stat and resource bugs screwing up the overall game, and because there is no fighting some
of the changes I made, such as teleports being less common now, unless someone convinces me otherwise.
<li>Fixed an infinite resources bug where apparently clones would have all the items of the original
duplicated, and you could just scrap them all and get tons of money over and over especially
if it was expensive stuff
<li>Fixed the zombie infinite stats bug, zombies can be used again
<li>Fixed the bug with dragon balls and hbtc where if you make the wish for someone inside the hbtc
they get insane gains
<li>People keep using the old stat mode on servers just so they can see their stat mods in the stat
tab but that mode should not be used because it is buggy and unbalanced. So I made it so no matter
what mode you use you can not see your stat mods in the stat tab, that way there is no incentive to use
that old buggy mode that should never be used ever.
<li>Had to disable the ChatLog proc of the game because according to the cpu profiler it is causing
3x more lag than anything else in the game.
<li>By going to the southwest corner of Atlantis you can enter the core of planet Vegeta, which is
a type of torture training and the most dangerous place you can go probably. It's really hard to survive
but you will gain power just from being in the harsh conditions. There are fire demons there that if you
kill them your health will refill. The atmosphere will turn to poison gas sometimes. Big rock fragments
(meteors) are shooting everywhere. Explosions are everywhere. I'll add some more stuff eventually I
hope, but this is the first version of it.
<li>Demon icon in Vegeta's Core map by Airman123
<li>Only Demons can use or teach soul contract now
<li>Only Kais can use or teach kai teleport now
<li>SI removed from learn. Now taught only.
<li>This was done because of how overused teleports are
<li>Autopilot on navs is now half price
<li>There is a wormhole in space's northwest area and one in Icer's caves that will teleport you to afterlife
<li>Demons have 20% more BP in hell
<li>Added a brain scrambler tower. When placed on a planet makes everyone retarded.
<li>Added a brain scrambler blocker, when kept on you, will block the tower's signals from affecting you
<li>Fixed bind not responding to ki mod of the user
<li>Fixed BP going to 0
<li>Made some attempts to fix the splitform bug where they just immediately delete for no apparent
reason. I added some debug text when they delete that will only display to me. One reason it is so
hard to fix is because on my server the bug doesn't happen and splitforms work fine.
<li>There is now a portal to kaioshin planet that will only allow one use per 15 minutes. It is somewhere
on the checkpoint map
</ul>

v26<br><ul>
<li>Added big bang attack, which is basicly a more powerful version of charge that takes longer to fire
<li>Capped the amount of points you can put into anger at 3x. Anyone with more than that will be lowered
now, but no need to remake, your stat cap will rise to what it would if you had put the anger points
into stats instead.
<li>Fixed invisible death balls?
<li>Fixed Makosen being shitty
<li>Removed the regeneration and recovery boost from being angry and instead made anger give you more
BP like it originally was
<li>Added an option for level 4 admins to set where a fighter in skill tournaments will get a bp boost
for each new stage of the tournament they make it to, as a reward for their performance as a player
<li>Nerfed shuriken range from 75 to 25, and offense from 2x to 1.5x, and fixed a problem where a
person with no speed could fire shurikens almost as fast as someone with max speed
<li>Fixed the bug that lets people build over the time chamber door
<li>Give power must now recharge between uses, so no more of the wall breaking exploit where one guy
sits in a regenerator endlessly giving power to some other person so they can break a wall no matter
what BP it is
<li>You can no longer recover energy/health in a regenerator while using kaioken to endlessly keep your
maxed kaioken bp, this was also part of the wall breaking exploit
<li>Regenerators will no longer heal you while using a transform or BP increasing buff
<li>You can no longer use kaioken or power up while in oozaru form
<li>Changed how kaioken + give power + trans buff + oozaru mix together, basicly you won't get as
much that is for sure.
<li>It is 25% easier to kill death regeners now because of a vote saying it was too hard to kill them
<li>Because blast's alternate firing modes suck, I made it so spread has a 35% chance to fire 2
blasts at once, and barrage always fires 2 at once
<li>Fixed the logout resource loss thing? It is supposed to be a 5% loss per hour of logout time
<li>Mastering powerup is now less retarded, instead of randomly waiting for it to kick in, you will
begin powering up, but slowly. How mastered it is depends on how high you managed to power up. So if
at some point you powerup past that again it will start going slow as you are pushing the cap of how
high you can powerup
<li>Kaioken is now capped at Kaioken x20
<li>Fixed all T-Injections
<li>Fixed a bug where a person can just reset DNA on a telewatch and teleport to all that person's stuff
and steal it cuz Sheep did that to me
<li>Made elite saiyan rarer, there is always far too many of them
<li>You can now revert from mystic any time you want instead of having to wait
<li>Fixes to flash step and beam struggles
<li>Added a thing where if you become more than 2x stronger than what the game considers "strong" for
that point in the wipe then your gains gradually decrease until it becomes pretty unrealistic to become
more than 3x stronger than what the game considers "strong". This is to prevent 24/7 afk training being
so insanely effective.
<li>The race guide now displays the correct anger failure chance of each race
<li>When a Half Saiyan goes Super Saiyan 1 for the first time the drain will be far greater than it
is for a Saiyan and they will have a harder time
controlling it, but they master it 4x faster than a Saiyan now.
<li>Zanzoken now has a new ability, which appears as a command in the skills tab called Flash Step,
using it will move toward a running target making it harder for them to escape. You must face the
person you are chasing for it to work. It will drain you because it is zanzoken. More speed means
better flash steps.
<li>Projectiles that deal ballistic damage such as ballistic guns and shurikens now have 3x less
cutting power to cut thru opposing projectiles. So for example it is very hard to cut thru someone's
blasts with some shurikens
<li>Fixed doors being nuke immune
<li>Fixed nukes being way overpowered
<li>Fixed invincible waterfalls
<li>Aura knockback no longer occurs when charging/firing a beam
<li>Fixed the bug where you grab someone then dash attack and it hits them every step of the way.
You could beat someone 10x your power with it.
<li>Fixed Namek counterparts?
<li>Beams involved in a beam struggle become 5x more powerful and 4x harder to deflect
<li>Each match of the tournament will open a sense tab of your opponent automatically
<li>Every new match in the tournament refreshes your anger
<li>Beams that hit the person closer than 4 tiles away will not have beam stun, but will have added
knockback on the person, and only hit them once before knocking them away but will do 5x damage for
that 1 hit
<li>Admins can now set the max amount of bp a person can set their custom buff to go to, I am having
my server at 1x so that people have to use the transform attribute on their buff if they want extra
bp
<li>Fixed the bug where people will store dragon balls in a bank
<li>Mastered Super Saiyan 1 now provides 30% more static BP, if you haven't reached the point where
all your static BP is gone already
<li>Majins are now totally immune to strangle and can break free of any grab instantly by becoming gum
<li>Dash attack is now a command in the skills tab, and upon using it your character will just start
dashing in whatever direction you are facing, striking any enemies in the path. You can now aim during
the dash attack by using side to side movements
<li>A person hit by a beam can no longer get out of the way of it until they can deflect it,
beam stun only works if you hit the target from 4+ tiles away to prevent abuse of point blank beam stun
<li>Beams now do half damage due to the above feature
<li>Majins now get 0.7x dura/resist and 2x regen instead of 0.7x dura/resist/def and 3x regen
<li>You can now store items in the bank. Just drop the item onto the bank.
<li>If your bp is over 10 million and and you have more than 35% more bp than a person within 5 tiles of
you while you are standing still and powering up a bolt of electricity will shoot out and knock them
away from you, but won't hurt them. I was reminded of this when USSj Trunks was powering up and Krillin
was nearby and got fried and knocked away by the power
<li>You now power up twice as fast if you do not move while doing it
<li>Added more convenient side stepping, where if you are facing an enemy right in front of you, then
you sidestep them using a diagonal key, your character will automatically face them because it realizes
you are trying to do a sidestep
<li>The person who you are attempting to side step has a 30% base chance to defend against the side step
by facing you to avoid getting hit in the sides. More BP and defense increases the person's ability
to counter side steps. More BP and offense increases your ability to prevent them from defending the
side step
<li>The force from the shockwaves of your melee attacks alone will now knock other nearby people back
away from you just from the sheer force of the battle, except if they are a lot stronger. I noticed
this happening a lot in some dbz videos, so I did it. Also it has the added side effect of helping
reduce 2 on 1 battles.
<li>Stun controls now have upgradable BP and the victim will take less damage by having higher BP
<li>If a person who uses scattershot is knockbacked they lose focus and all the blasts lose their
homing and fly off in whatever direction
<li>Majins are now immune to injuries
<li>Upgrading gravity is now less expensive but the cost of the actual machine is higher
<li>Put a 1 minute cooldown on scattershot and made it so you can't move while it is in progress for a
few seconds
<li>Rebalanced the difference between explosive slow blast and rapid fire blast, explosive and slow was
far superior
<li>Movement speed is now overall faster
<li>Speed now has more impact on how fast you attack in melee
<li>Added extra delay between diagonal movements because it is almost like moving twice as far as
regular movements because instead of just moving an x or a y coordinate you are moving an x and a y
move at the same time. I realize mathematicly it is the same. And it IS the same amount of tiles moved
in the same amount of time, but I made a diagonal line of ammo 10 tiles long, and a straight line of ammo
10 tiles long, and measured the actual length of these lines on my screen, and the straight one was
11 cm, but the diagonal was 17 cm. So in my opinion, thats more distance across my screen covered if
a person moves diagonal, imo that = faster. It definitely makes them harder to track, harder to chase,
and other stuff.
<li>Added a verb to let level 4 admins turn diagonal movements on or off
<li>The energy drain when someone struggles against your grab has been greatly lessened
<li>Fixed a bug that made it so a person can not get super saiyan levels even if they have insanely
more BP than needed
<li>Made sokidan more sokidanny
<li>Scattershot now fires more blasts, moves faster, but is weaker and easier to deflect
<li>Death ball now moves slower but does much more damage, I changed it because it was a shitty attack,
I'm not sure this will make it actually better though
<li>Genki Dama now charges twice as fast because it had no practical application in battle
<li>Made buster barrage do a bit more damage and have less drain
<li>I put indestructable walls around the tournament arena to stop runners and hiders
<li>A person who has the revive skill used on them must wait 30 minutes before it can be used again on
them, to prevent people who have tons of alts to immediately revive themselves with. Seriously, that
shit is out of hand, as soon as you kill someone they are back 30 seconds later to kill you while your
weakened, almost guaranteed.
<li>Did the same for reincarnate
<li>Im Trapped now takes 4 minutes to work instead of 1 minute
<li>You are now disqualified from the tournament if you go 9 tiles out of range instead of 13, because
of all the people who manage to hide til a tournament is over and win using cheap runner tactics
<li>The tournament now detects if a person is running and disqualifies them for being a whore
<li>Dash attack is now better
<li>Brought back the Synthesize command when right clicking an antivirus that you can use to create
different T Injections with for a high price but without the need to create tons of zombies
<li>The regeneration stat now has more impact on how fast you get up from being knocked out, because
the regeneration stat sucks
<li>Fixed so-called "SI Zanzoken" where you can infinitely zanzoken as long as you have mastered
SI and move while doing it. SI Zanzoken is supposed to only be used when charging a ki move, at which
time you can SI somewhere else to fire it, like a Warp Kamehameha
<li>Cant use explosion or any ki blasts when grabbed
<li>Deleted this weird little room near Kami's tower that people were somehow getting into and making
bases in even though there was no way to get in there from what I can tell
<li>Half Saiyans can now get ultra super saiyan as intended
<li>Added bank machines to every planet that you can deposit or withdraw resources from
<li>If you have over 500k resources and you log out more than 5 minutes you will begin losing resources
at a rate of 5% per hour up to a 50% loss so that people stop using logged out alts as banks and
use in-game banks instead, where at least they can be ambushed before being able to deposit the
money.
<li>Fixed AI training bugging out
<li>Fixed the annoying bug that keeps removing your overlays after death regenerating??
<li>You can now attack immediately after using taiyoken, and taiyoken slows down the movement of the
blinded person, but taiyoken has a pretty long cooldown
<li>I made anger have a 75% chance of working instead of 100% until I fully plan out some type of
new anger system
<li>The bp requirement for super saiyan 2 is now 20% higher because it seems like people are just
getting super saiyan 2 almost immediately after super saiyan in most wipes.
<li>Nameks can now set another Namek as their counterpart which is a Kami and Piccolo type thing where
it means they were once the same being, if one counterpart gets less bp, ki, gravity mastery, or bp mod
than the other, the weaker one will be raised up to the same level. If one dies, the other's energy
drains until they also die. Just right click another Namek to set them as your counterpart, or to
drop them as your counterpart use Reset_counterpart found in the Other tab.
<li>If a Namek with over 8.5 million base bp fuses with their counterpart, they will recieve up to an
additional 10 million bp and be classified as a "Super Namek"
<li>Namek lowered from 1.8 bp mod to 1.7
<li>There are 2 new stats, one determines how much BP you lose from low health, the other from low ki.
You can see each race's rank in these stats in the Race Guide in the Other tab. Nameks have the best
in both.
<li>Aliens can now choose from 2 new perks which gives them less bp loss from low health or ki
<li>Lowered Icer bp mod to 1.8 instead of 1.9
<li>If a Saiyan is grabbed from behind, the grabber grabs them by the tail, which drains the Saiyan's
energy by 1/30th every second, and makes it twice as hard for the Saiyan to break free
<li>For 35 skill points you can learn Saiyan Tail Training, which can be trained endlessly, each new
rank reduces the energy loss if someone manages to grab you from behind.
<li>Made ascension give 5% more BP mod
<li>Added Ultra Super Saiyan. To learn it, you must reach 24 million BP in super saiyan, then it
will be learnable. You can toggle it on and off in the skills tab. It is on by default. To use it, just
go Super Saiyan, then power up twice again while having at least 24 million BP. It gives 1.3x BP, 0.5x
ki, 1.3x strength, 0.7x speed, and graphical changes. If anyone has a better USSj aura tell me please,
I'm looking for something more spikey and violent looking than the normal Super Saiyan aura.
<li>Vegito hair now has a mastered super saiyan icon
<li>Changed the math that decides a beam's energy drain, because I never factored in that higher drain
= less overall damage due to power dropping rapidly, and that it decreases your effectiveness for the
entire remainder of the fight. So now the high tier beam attacks have less drain.
<li>I put Icer forms back how they were because they were going from like 1000 bp to 20'000 bp final form
<li>Changed how speed works to reduce speed whoring slowing people down a lot, basicly speed has
less impact on how fast you attack and move now, but has more impact on your accuracy and dodging
and blast deflection. Everyone should notice they attack/move a bit faster because whoever is currently
whoring speed at the moment will have less impact on everyone else's move/attack speed. But whoever
is whoring speed will dodge like crazy and have insane accuracy.
<li>Changed defense, removed the exaggerated dodge scaling, for example it was that 4x defense = 16x
dodging ability and 16x accuracy, now 4x = 4x, but defense now decreases damage taken from all attacks
except for area of
effect attacks such as explosion and self destruct etc, but the damage decrease is not nearly as much
as you get by having better durability or resistance, but defense covers both ki and melee damage,
instead of just one or the other like durability or resistance does.
<li>Dragon balls now have a drop all command if you right click them so that you can drop them
all at once for convenience
<li>Precognition has been changed. Before: Precogs refilled by +1 every 3 seconds to a maximum of 3
at once. Now: Precogs refill by +1 every 7 seconds to a maximum of 5 at once, and there is no more
ki drain from using it.
<li>Made some optimizations to reduce lag if there is a lot of empty clones laying around, by
making a lot of their loops slow down if no player is in them.
<li>Had to remove empty body's ability to dig because it can be used to earn billions of resources
if you just keep making like 50 afk digging clones inside energy refilling regenerators
<li>Icer forms grant more at lower BP levels now but still max out at the same amount at the same
time. By the time a Icer reaches 530'000 base bp, they have maxed out their forms, same as ever.
<li>Raised Icer ascension BP requirement even higher
<li>You can now wish on the dragon balls to make vampirism incurable. Or if it was already incurable,
they can be used to make it curable again. This will really piss people off!
<li>Fixed the problem with blasts getting stuck on the map edge causing endless lag
<li>You no longer lose BP if you miss while using shadow spar, the whole point of that system was so
that people can't just randomly spam directional keys and hope to succeed. But I came up with a new
system, if you miss, you won't get gains on the next success. That should fix it in a less shitty way.
</ul>

v25<br><ul>
<li>The warp kamehameha type thing that you can do with shunkan ido now has no ki drain
<li>Prison time extended to 1 hour for first offense, and up to 1.5 hours for successive offenses,
because people laugh at imprisonment and treat it as no big deal, nobody bothers to place bounties
because nobody cares that they get imprisoned. It isn't severe enough.
<li>Stat gain (on modless mode only) now has a rubber banding effect where instead of your stat gain
suddenly coming to a grinding halt, it slows down more and more as you near the cap, much like gravity
mastery works. For example if your 50% capped you gain stats at 71% normal rate, if your 80% capped your
gain is 45%. 90% capped is 32% gain. 95% capped is 22%. 98% capped is 14% gains. 99% is 10%. Except it
isn't in set intervals like that, for example 82.732% capped is 41.554% gains.
<li>Zanzoken cooldown now works differently. You get a set amount of zanzokens you can spam at once,
and if you use them up, they will slowly recharge like +1 every 5 seconds or so. How many zanzokens
you can spam at once is determined equally by how much speed and energy you have. The reason zanzoken
needs some type of cooldown in the first place is because runners use it to escape too easily
<li>Majin no longer reverts you from super saiyan or icer forms when you stop using it
<li>Shuriken explosions now deal damage based on durability like they are supposed to, instead of
resistance
<li>Icers no longer have the ability to sense because the community voted it because Frieza and his
family couldn't sense energy so the vote assumes that no Icer can.
<li>Icer only becomes an option now if less than 6% of the population is already Icers. It was
10%.
<li>Fixed bp scanner module?
<li>A person who is currently a body swap victim can not teleport or be summoned
<li>Everyone has 100% anger chance because I have new plans for the anger system but this is the first
step
<li>Autopiloted pods/ships will now navigate around obstacles including other planets
<li>Attack barrier damage boosted 50%
<li>You can no longer spam explosion and attack barrier together and can no longer zanzoken during
firing attack barrier
<li>How many blasts you can fire out at once and control is now determined by your energy mod, so you
can't just go offscreen and wait to produce 5000 blasts then cheaply walk up to someone killing them
instantly even tho theyre 5x your power.
<li>Changed wish for power, no longer does it make your bp equal to the strongest person's, but
instead gives you 4 hours worth of sparring bp gains.
<li>When Vegeta is wished back from being destroyed, Atlantis will be restored too, and vice versa
<li>Ships on destroyed planets will now automaticly be sent to space
<li>You can now wish for absorb, soul contract, kaioken, genki dama, majin, mystic, and kai teleport on
the dragon balls
<li>You can now wish to be immune to the dead zone on dragon balls
<li>Fixed dead zone to properly suck in people who are meditating/training/KO'd. They were
immune due to a bug
<li>Heaven, hell, and checkpoint can now have dragon balls again, but dragon balls only become active
every 7 hours instead of 3.5 hours in return.
<li>Lowered explosion's max range because it was lagging
<li>Improved tab responsiveness by tying how long tabs refresh to the server's cpu levels. Anything under
50% will have tabs refreshing every 0.1 seconds, but for every 5% over that it adds 0.1 seconds
to the refresh time. So if the server is strained at 100% cpu, tabs only refresh once every 1 second max
<li>Fixed the grab bug where it just stops working
<li>Attack barrier now drains 50% more and is 25% weaker due to noobs abusing it
<li>Fixed the body swap duplication bug
<li>You can no longer brain transplant into a dead body for obvious reasons
<li>Fixed the bug with clones having 0 lifespan and dying immediately
<li>I added a way for people hosting a vps to get host admin. Just make a text file named "Host keys"
and inside it put any keys that are supposed to have admin (with EXACT spelling). Put that text file
in the game folder and when you log in it will give those keys level 4 host admin
<li>Fixed the infinite wishes bug with dragon balls
<li>Overdrive module sucked so now it gives x2 bp instead of x1.5
<li>Nanite Repair module now sucks less
<li>Namek Regeneration ability now sucks less
<li>Fixed bp scanner module
<li>Fixed a bug where bio androids and majins constantly had 25% higher bp than they were supposed to
<li>Fixed scrappers
<li>Level 4 admins now have a command called Pwipe_vote_settings which lets them set a year and BP
requirement on pwipe votes
<li>Fixed a bunch of prompt stacking bugs
<li>Fixed explosion going thru walls
<li>Fixed blueprints being able to create items that were turned off by admins
<li>You no longer need to spar a super saiyan or even have a super saiyan online to ascend now. You
just have to reach a certain base bp level and you will just ascend. The amount for each race is
different and can be seen using the Race-Info command
<li>Bio androids no longer get the cyber bp increase when transforming, instead it goes into regular bp,
but they get 25% less overall as a trade off
<li>Spirit dolls now recover energy while flying
<li>You must now be outside the space pod to repair it, and if you or the pod moves the repairs are
cancelled
<li>Repairing a spacepod now only takes 5 seconds instead of 7.5 seconds
<li>Aliens can choose "Better blast homing" during creation to boost their blast's homing chance from
30% per step to 54% per step
<li>Self destruct now obeys the server's ki damage mod
<li>RAGE can no longer be used while knocked out
<li>BP gains are faster
<li>Fixed nav systems being unable to detect Earth
<li>Fixed the bug where mystic lowers a saiyan's bp permanently after reverting
<li>Nerfed how much money you get from the dragon ball wish because of how frequently they can be used
now. It was 15 mil to 100 mil, now its 10 mil to 25 mil, multiplied by whatever admins have the resource
gains set to
<li>Alt sparring is now the same gains as sparring an NPC
<li>Added a Set_alt_limit command for level 4 admins
<li>Bio androids now need at least 8 million current bp to transform to semiperfect or perfect form
<li>Dead people in tournament now have full power
<li>You can no longer get more than triple BP in 1 zenkai
<li>Zenkai weakened from a 250x leech to a 100x leech
<li>Each successive zenkai from zenkai spamming is now half as much as the last instead of 3x less
<li>Zenkai from death is now half the amount as zenkai gained upon KO, instead of twice the amount,
so a full KO + death is now 1.5x normal zenkai than just being KO'd, instead of 3x
<li>The amount of power you get from zenkai is now multiplied by a 'difficulty mod' that represents
how hard the game thought the fight was for you. If you get knocked out in 1 hit, you will not gain
very much at all. If it was a long dragged out fight you will gain the most.
<li>Keep body teach timer upped from 12 hours to 18 hours
<li>Keep body has a 1 hour timer between uses
<li>Keep body is now 'per death', meaning if you have keep body, but come back to life, then die again,
you won't have it.
<li>Dead people with keep body are now at 65% BP instead of 85%
<li>Dead people are now at 65% BP instead of 30%
<li>Nerfed strangle
<li>Each race now has a "stun resistance mod" which determines how long they will be stunned by any
attack that has a stun on it. Currently that means only time freeze since blast stuns are off. Nameks
have one of the highest resistances to stuns. You can see the mods in the Race_Info command
<li>You can now strangle in tournaments
<li>Any T-Injection that alters a person's stat build will now be completely undone upon death
<li>You can now use HBTC once every 24 hours instead of 36 hours.
<li>Nerfed attack barrier damage from 3% to 2%
<li>Redid explosions. They should be much more cpu efficient and arguably better looking
<li>Nerfed zenkai by half, because I noticed it is a common thing for a weak character to be beaten,
then get up with almost all the power of the person who beat them, even when that person is
10x stronger. Especially if they were beaten with
ki for some reason.
<li>People seem to think that afterlife is the place to be, while the living world remains mostly
empty, so I nerfed heaven/hell/checkpoint to 0.5x default resources, and kaioshin to 0.25x. The higher resources
in living world will hopefully make it more appealing to be there. Living world is where most of the
action is supposed to be.
<li>Fixed the bug where Time Freeze was teachable
<li>Stat modifiers in custom buffs can now go down to 0.7x again instead of just 0.8x
<li>You are now disqualified from a tournament if you get 13 tiles away, instead of 25
<li>Nerfed attack barrier damage from 4% to 3%
<li>Nerfed buster barrage damage from 10% to 6.5%
<li>Fixed time freeze being teachable
<li>Fixed a bug with leagues deleting each other if you are in more than one league at a time
<li>Bio Androids and Majins now retain 25% more BP when using splitform than other races
<li>Ki jammers no longer block ki during a tournament
<li>Made the precog ability less draining, but the drain doesn't scale down as much any more from having
better ki mod
<li>Kaioken can now be used with custom buffs again
<li>Legendary Saiyan will not become a choice til the server has been up 5+ minutes to prevent the
exploit where a new person can get it every reboot if they do it before anyone logs on.
<li>To train knowledge, you must now select to do so using the stat_focus command, then you can
train knowledge by meditating.
<li>You now lose immortality upon dying
<li>Dragon balls can no longer be made in afterlife
<li>Dragon balls now only stay inert 3.5 hours instead of 6 hours
<li>Wishing for money on the dragon balls has been greatly boosted
<li>When a person struggles against a grab it drains the grabber's energy trying to control them
<li>Fixed the bug where Elite would be offered to Legendary Saiyans, creating a bugged hybrid
<li>Kai teleport can now go to space
<li>You can now only knock on a door once per 5 seconds to prevent knock spam which was annoying
<li>The 6 things listed below this were done because of the huge amount of faggotry occurring where
as soon as you get someone out of your hair by killing/binding/jailing/trapping them, they would
almost always INSTANTLY come back to you to harass you some more. There was no penalty for their actions.
<li>Removed death immunity
<li>Dead people in living world now constantly have energy drain and when its all drained they return
<li>You can only use the hell altar every 4 hours instead of 2 hours now
<li>You can now only use im trapped once every 1.5 hours instead of 1 hours
<li>Increased first offense prison time from 18 minutes to 42 minutes, but made each offense
increase the time by less than it did before
<li>Doubled the time it takes for binds to expire, from 30 minutes to 1 hour.
<li>HBTC training now gets slower depending on what percent your hbtc_bp makes up of your total bp
<li>Ship exits and ship controls are now 2 seperate things. No longer do you have to be unsafe when
piloting your ship when the controls and entrance can be in 2 separate rooms.
<li>Melee now attacks in an arc, on any player in the front of front-sides of your character. I don't
know if this will be a good thing or not, just consider it a test.
<li>Fixed the RAGE injection not actually giving you any boost
<li>Updated the Simulator item, because nobody uses it. It was the same as using a splitform, but now
it is better because hologram fighters can take 3x more damage than a splitform and only do 0.35x
as much damage to you. Resulting in much longer spars with them in exchange for less convenience.
<li>Elite Saiyan will now only be offered if the server has been up 5+ minutes, to prevent bug abuse
to get Elite Saiyan after a reboot
<li>Fixed the bug where people will grab people out of tournament with extendo arm to kill them
<li>Changing tabs now resets client.inactivity to 0 so that the tabs begin updating again. It would be
pretty annoying to be afk for 1 minute and your tabs stop working til you move.
<li>You can now transition seamlessly into fly/train/meditate/shadow spar/ai training without having to
manually stop doing one to do another.
<li>The system that detects when someone is sparring, and then gives them sparring gains from it,
wasn't detecting properly, which made spar gains much less than they should have been. Even less than
from the train command.
<li>Meteors now move much faster and in a straight line, and cause damage to ships and people.
The damage scaling on meteors is greatly exaggerated, a person whos BP is exactly the same as the
server average bp will take 100% damage, a person with twice the average bp will only take 6.25%
damage. A person with half the average BP will take 1600% damage. Durability helps too.
<li>Added a level 4 admin command called Disable_planets which lets the admin turn planets on or off
<li>Fixed the bug causing all buffs to delete
<li>You can now strangle someone to death by grabbing them then pressing attack. Attack toggles
strangling on or off. While it is toggled on the person will take 1/3rd normal melee damage
(minus any sword) every 0.5 seconds
<li>Replaced the grab struggling system. Now every player has grab power at 100% and as a person
struggles they wear down the grabber's grab power. The struggler wears down the grab power more
if they have better strength and BP, and to a lesser extent defense.
<li>When not grabbing someone, grab power will refill to 100% by +1 per second
<li>Kaioken no longer halves defense or gives 1.5x offense
<li>Kaioken now gives less BP per level used
<li>Completely changed the effects of mystic and majin. Use the examine command on them to see.
<li>Each race now has a different base chance for anger to kick in upon being knocked out, instead
of everyone having 50%. It can be viewed in the race guide command.
<li>Each race now has a different blast homing mod, you can see it in the Race_Guide command
<li>Nameks have the highest blast homing mod, because they suck so much, and it sure seems like they
had great blast homing control in DBZ
<li>Fixed a bug with the blast caching system where a blast pulled from the cache would not have its
"stun" variable reset from the last time it was used, causing blasts to stun when they aren't
supposed to
<li>Having blast absorb module installed weakens the shield ability by 20%, because the combination
was far too powerful. I can't come up with any logical reason to explain this but it was needed for
balance.
<li>Armor item is now capped at 1.5x durability instead of 2x. Any past that will automatically delete.
<li>Blueprints can not be used in combat now, to prevent a bug where a person using a force field item
will just quickly create a new force field using the blueprint when theirs gets drained and be
practically unbeatable
<li>The durability increase from armor, and the armor module, no longer increases shield power.
This can be logically explained since whatever is hitting you is never contacting your armor, it is
only contacting the outside of the shield, dealing energy damage, not physical. But the real reason
is that I'll do anything it takes to balance shield out whether it makes logical sense or not.
<li>Generator module was x2 energy mod, which made shield 23.1% stronger. Now generator gives +5%
shield power, but the extra artificial energy mod provides no boost to shield.
<li>Weakened shield. It now takes 100% normal damage instead of 65%. That is before energy mod alters it,
which I wasn't taking into account before, and that made it overpowered. For example having 4 energy mod
turned that 65% into only 42% normal damage while shielding compared to not shielding. So 100% would
become 66% now.
<li>Absorbing your own blasts no longer gives any energy. The only way I can logically explain this is
that sending out energy, then putting that same energy back in, shouldn't result in more energy somehow.
But the real reason is because of a tactic that shield+absorb androids use to refill their shields
in a fight by quickly shooting a beam then zanzoing into it to refill all their power.
</ul>

v24 (5/17/2013)<br><ul>
<li>Zanzoken cooldown is 25% higher because I hate how effective kiting is
<li>Fixed another HBTC bug regarding the time you can spend in there
<li>A person is supposed to be able to train again in the HBTC 36 hours after they last did, but due
to a bug it never resets. Fixed it.
<li>You can now get super saiyan without the need for inspiration or death anger, just by getting
normal anger, as long as you have 4x more BP than you need for ssj1, 2x more for ssj2, and 1.35x more
for ssj3. So if you want you can go all Vegeta mode and get Super Saiyan solo just by being really
strong and getting knockout anger.
<li>Fixed the bug where crashes can duplicate dragon balls
<li>Zanzoken is a combat tactic not a way to travel great distances or run away from someone, any
zanzoken that goes more than 6 tiles away will add 0.15x to the cooldown for every tile
<li>Eating more than 1 senzu in 5 minutes will cause you to be overfilled, putting an overeating
debuff on you that lasts 2 minutes. It will cause you to move slower.
<li>Reduced the timer on make fruit from 60 seconds to 10 seconds
<li>Removed the senzu effect from fruits
<li>The decrease in fruit gains with each one eaten is less severe
<li>Having low ki will now lower available cyber bp just like how it does for natural bp, except
to a much lesser extent (4x less severe roughly).
<li>Demigod ascension mod is now 1.1x instead of 1.15x
<li>Android ascension mod is now 1.15x instead of 1.2x
<li>You can no longer absorb blasts while using any kind of shield, because logically, the blast
never even makes thru the shield for you to absorb it. Also because androids are fucking overpowered,
like 4x better than anything else at least.
<li>Fixed the vampire overlay bug where when you stop flying all your overlays stack over and over
<li>Overloading an android's blast absorb now instantly knocks them out with an explosion of energy
<li>Low health no longer lowers bp as much
<li>Nerfed force whores some more. The 3 strongest people on were all people with 60% force builds.
They were FAR stronger than ANYONE except other 60% force whores. They could kill people twice their BP
in 3 hits only using blast even when that person had 18k resistance when the average for the server was
only 12.7k
<li>Nerfed force field items greatly they were extremely OP for some reason
<li>Evil now gains bp 2% faster than good
<li>Evil now masters skills 15% faster than good
<li>Evil now stat caps 15% faster than good
<li>To stop evil people hanging out with good people, evil people can no longer gain BP/SP/Ki while training
in the presence of good people. They can still leech but that is it.
<li>Zanzokening backwards now has twice the cooldown of zanzokening forwards. This was to reduce the
effectiveness of kiting with ki.
<li>Saiyans now only have 5 predeposited points in durability instead of 7
<li>Majins now have slightly less predeposited points in regeneration and recovery
<li>It is now impossible to stay in the final realm when not regenerating there
<li>Fixed extendo arm?
<li>Because of the below buff updates all buffs will need to have their stats redone
<li>Minimum buff stat is now 0.8 instead of 0.7
<li>Buff regen/recov boost is now capped at 1.3
<li>Buff ki boost is now capped at 1.5
<li>There is now a 40 second cooldown between switching custom buffs
<li>Grab is now 3x weaker
<li>Icers can no longer ascend off anything less than a super saiyan 2
<li>Fixed the bug where knockbacks send you thru the hell clouds even tho you are flying
<li>Fixed the bug abuse where a person in a skill tournament has another person teleport into their
match and time freeze the enemy for them using their full bp against the enemy's 100 bp and cheats to win
<li>Telepads are now 5x more durable
<li>Teleport nullifiers now stop binds from teleporting people to hell
<li>New level 4 admin verb: Set_percent_of_people_that_can_break_walls
<li>New level 4 admin verb: Set_wall_INT_scaling
<li>Lowered the effect that intelligence has on max gravity limit
<li>Fixed a bug to bypass teleport nullifiers by joining the tournament, getting in a pod, then
destroying the pod after the tournament to appear where the pod was destroyed
<li>Teleport nullifiers no longer interfere with spawn redirectors
<li>Teleport nullifiers now prevent the dead zone portal from opening
<li>Added new technology called Spawn Redirector, which can be set to redirect to any spawn you
choose, then you place it over an existing spawn and anyone who spawns there will be redirected to
the spawn of your choosing
<li>Giant Teleport Nullifiers can now be set to allow certain telewatch/telepad frequencies to be
undisrupted and usable
<li>Shortened jail time
<li>Added an item called a Scrapper that will scrap any item in front of you to salvage resources
from it, destroying the item. It recovers 60% of the resources spent.
<li>Added a resource destroyer technology that will somehow stop a planet from generating resources
<li>EMP Mines now only drain an android's energy
<li>Added teleport nullifier technology that will prevent all forms of teleporting within range
<li>Dead people's injuries will heal on their own gradually even if they were 'permanent'
<li>Telepads can now teleport between planets
<li>Added EMP Mines which only harm androids and cyborgs, I don't think they're permanent, just an
experiment
<li>Scouters can now be upgraded to scan androids rather cheaply
<li>Fixed the bug where people bind then forget and relearn bind so they can keep stacking bind power
over and over.
<li>Minimum bounty is now 5 million resources
<li>Made it harder to lose your tail, now any attack below 20% damage can not make you lose your tail,
and you must be under 50% health to lose your tail even if the attack does more than 20% damage.
And if you didn't already know, only slicing attacks like sword and kienzan from behind can make you
lose your tail anyway.
<li>Nerfed force damage scaling
<li>Buffed resistance damage scaling
<li>Buffed turret damage
<li>Nerfed gun damage
<li>Removed stun attribute from guns
<li>Fixed ki attacks seemingly stunning people for no good reason
<li>Fixed gravity upgrading not giving the correct amounts and bugging past server limits
<li>Fixed body swap body duplication bug
<li>Fixed namek fusion I think?
<li>Fixed the unlimited gun points bug, thanks to EXGenesis for the info.
<li>New female hair icons provided by Ssj jenny. Thanks.
<li>Diarea virus now lowers 10x faster
<li>Simulator fighters now do half damage to give them a reason to be used instead of splitforms so
they aren't entirely useless
</ul>

v23 (4/18/2013)<br><ul>
<li>Ascension is now 15% stronger
<li>Vampire hunger no longer rises when dead
<li>Sunlight generator now means instant death for a vampire within 2 tiles instead of 1 tile.
<li>Added a lv4 admin command called Toggle_death_cures_vampires so that the head admin can set whether
dying will get rid of being a vampire or not
<li>Put buster barrage damage from 15% to 10% base damage
<li>Fixed a bug where if you fire beams 1 tile away from the edge of the map into the void they will
stack endlessly and cause huge lag and crash the server
<li>Re-enabled redo stats for robotics tools for androids. It has some sort of bug but I can't find a
note anywhere as to what that bug was so I might as well enable it again til I find out the bug.
<li>Revive skill timer is now 3x longer
<li>All cybernetic modules are now 10x more expensive, uninstalling modules is now 5x more expensive
<li>Took the game off of debug mode to hopefully stop the 404 error spamming that keeps causing the
server to crash frequently
<li>You will now get a small resource prize for every fight you win in the tournament, so that
not just the champion and runner up get prizes. The prize you get is increased by whatever stage the
tournament is on. If the server has resource gains at 1x and tournament prize at 1x, then the prize
per fight is 1000$ for stage 1, 2000$ for stage 2, 3000$ for stage 3 and so on.
<li>Anger reset timer now starts the moment you become calm not the moment you last got angry
<li>Saiyans can now only recieve cyber bp upgrades if they are in base form
<li>Cyber bp now reduces your available natural bp to 60% instead of 75%, so if the amount you get
from cyber isn't enough to fill in that 40% loss then you will actually see a decrease in your
total available bp.
<li>Racial fusion is now Namek fusion and only Namekians can have it
<li>Namek fusion is far more powerful than the old racial fusion
<li>Raised ssj2 bp requirements because people were just getting it too early
<li>Anger now has more of a bp boost by a bit
<li>Anger no longer keeps your bp from falling when your ki is low. You get a full ki refill but
that's all
<li>Having health under 100% now decreases available bp, the same as having ki under 100%, but the
effect is far less severe. When angry you will not have your bp decreased by low health
<li>Fixed spirit bomb
<li>Nerfed blast absorb. Use the examine command on it for details.
<li>The boost kaioken gives you can now be increased by staying in kaioken, until it hits the
current kaioken server cap. Unmastered kaioken gives +5000 bp per level
<li>Fixed the bug where the server refuses to reboot
<li>Fixed the bug that made AI Training stop working
<li>Speed now matters more in deciding how fast you can throw shurikens
<li>Attack barrier no longer knockbacks, it is the only AoE that doesn't knockback I think
<li>Tripled the damage of buster barrage because it was useless
<li>x4'd the damage of attacker barrier because it was useless
<li>Fixed an error that may have been causing the frequent server crashes
<li>Fixed a bug where a person who is being grabbed gets free by using shockwave
<li>Shielders now get knockbacked by melee but only half as far as normal
<li>Fixed the division by zero error spamming the server logs and possibly the reason of the crashing,
it is caused when a half saiyan has 0 bp, which I still havent solved
<li>Soul contract teleports and summons can no longer be used when the target is knocked out, this is
to make it harder for people to successfully run away from fights. When summoning you lose the lock
on their energy if they become knocked out. And if your knocked out you can't teleport because you are...
knocked out.
<li>Global leeching is really a problem because everyone is about the same BP without ever even coming
into contact with each other. I think most of the problem was the global leeching from unlock potential,
so instead of UP giving 600 leeches from the person UPing you and 50 leeches from the strongest person
online, it now gives 600 from the person UPing you, and if that doesn't give you any gains it then finds
a player as close to 1.1x your BP as
possible, and gives you 100 leeches from them.
<li>Did the same thing for absorb as I did above for unlock potential
<li>Zenkai no longer gets used up if the enemy who defeated you is too weak to provide any
zenkai gains
<li>Knockbacking someone who is charging or firing a beam will cancel the beam
<li>Taiyoken is disabled in the tournament unless you are fighting
<li>Fixed the bug that let people teleport others out of the tournament with SI
<li>Doubled the cost of building
<li>Nerfed makosen's damage by half
<li>Killing death regeners was made about 4x easier
<li>Beams with really high damage mods have had those mods lowered, as a side effect their drain decreased
by a lot
<li>Overall damage from all beams was cut by a third
<li>Pods now look like the ones from DBZ again
<li>Doubled the time it takes to recombine after coming back from death regeneration
<li>Upon first turning into a super saiyan a saiyan's base bp will receive a large increase
<li>You no longer gain money by downgrading a person's cyber bp
<li>Having cyber bp or modules now divides leeching by 10 instead of 3 and divides base bp gains from
training by 1.5
<li>Cyber charge was firing twice as fast as it was supposed to, fixed it.
<li>Nerfed force field by about 40% because it seemed overpowered but I didn't check for sure
<li>Fixed the bug where people make aliens with super high recovery, use a bunch of recovery buffs, then
step into an upgraded regenerator, which overcharges their ki to like 1200%, granting them insane
temporary bp. Regenerators no longer overcharge ki past 100%.
<li>I fixed the npc bp bug where they glitch to infinite, and that fixes the infinite resource bug
too
<li>Fixed death zenkai, it hardly ever worked. Now it will work. This will help lessen the mindless
killing if people know it will only make their victims stronger.
<li>Added a manual ban command so offline bug abusers can be banned
</ul>

v22 (2/19/2013)<br><ul>
<li>Removed the auto bounty when someone destroys a planet because people go around destroying planets
just so their friend can collect the bounty then they share it.
<li>The lag optimizations I added this update helped tremendously, the game running on the main shell
went from being able to have 85 players without lag to now 150.
<li>After a lot of searching as to why blasting causes such huge lag I finally found out that the
blast caching system wasn't even working so now I fixed it and tested it and it works, at least for
most ki attacks, especially the fast firing ones. Now that blast caching is actually working
hopefully it will do its job of making blasting less laggy.
<li>Rapid blast only fires 1 blast at once now instead of 2 to reduce lag but each blast does x2 damage
<li>Makosen only fires half as many blasts now but each one is x2 damage
<li>Shurikens now fire 1.5x slower but do 1.5x more damage
<li>Scattershot now fires half as many blast but does x2 damage
<li>Melee was a major source of lag so I made melee refire 1.5x slower but melee does 1.5x more damage
so its the same DPS as before just slower refire to help with lag til I can find other ways to
optimize it.
<li>Optimized the soul contract updating loop because it was causing a lot of lag being on a loop
when someone had many contracts at once, so now instead of updating on a loop it only updates
when you log in or someone else you have the soul contract of logs in.
<li>Optimized the sense tab because it lags more and more with more players on especially past 90
<li>BYOND's text overlays cause too much lag so I have removed them from drills because the lag it
causes increases exponentially with the player count.
<li>Nerfed hokuto to half power after learning that it can kill people 300% stronger than you
if you use a hokuto buff
<li>Genki dama now charges 1.5x faster
<li>Fixed the mate bug where the kid has 0 bp and cant gain any BP ever
<li>When a person with death regen comes back they are now frozen while their peices assemble for 7
seconds divided by sqrt(death_regen_mod) (7/sqrt(death_regen_mod))
<li>People can no longer use SI or kai teleport while knocked out
<li>Absorb now gives 5x less global leeching of the strongest person online per absorb
<li>Leeching BP now slows down more and more the closer your base bp gets to the base bp of the person
your leeching. It's exactly like how gravity works, you can never fully get all the BP off of them
because it'll just keep slowing down.
<li>Weights now increase leech rate a bit, for example if the weights are giving you 5x bp gains they
give you 1.62x leech rate too (5^0.3)
<li>Zenkai now gives 500 leeches from the person who kocked you out instead of 400, and 0 leeches
from the strongest person online instead of 50
<li>Made unlock potential give you 600 leeches from the person UPing you instead of 400, but only 50
leeches from the strongest online instead of 100
<li>When a person's tournament match starts their power up % is set back to 100% to get rid of
pre-powering up before a match starts
<li>Lessened ki drain from melee a bit more
<li>The more strength your build has compared to other stats, the higher your energy drain will be
in melee
<li>Fixed scattershot targeting the user without asking first
<li>Injure command now lets you rip tails off
<li>Fixed the bug where a person with death regen would still be zombie infected after death regening
<li>Fixed a bug where people double their resources by dropping them before a reboot then
when the server comes back they still have the amount they dropped on them and also more on the floor
<li>Speed now gives a bit more of a boost to offense and defense
<li>Nerfed charge and sokidan damage to half
<li>The price per 1x of gravity is now relative to the max gravity of the server that admins have set,
so a fully upgraded grav will always cost the same amount
<li>Fixed the bug that lets people make gravity machines far past the max gravity allowed on the server
<li>Fixed the bug abuse where people kill people in their houses by shooting genki damas thru the walls
<li>Zombies now reproduce slower the more of them there are rather than faster
<li>Zombies now drop resources
<li>Zombie durability/resistance has been halved
<li>The zombie virus has evolved into a semi-intelligent parasite, it will now lay dormant waiting on you to infect
at least 2 other players, or until you travel to a different planet, or until you get in a crowd of at
least 4 other players before it kills you and turns you
into a zombie so that it can spread itself more efficiently
<li>Unbanned Newton378
<li>Fixed the bug that let people bug abuse their sokidan/kienzan/deathball over someone's walls to
kill them or destroy their drills
<li>Melee energy drain is now more severe
<li>Rearranged some technology prices
<li>Buffed door hackers to 0.9x instead of 0.65x power but made them much more expensive so only the
richest can afford them
<li>Buffed Bio Android's perfect form boost and made it so the android they absorb only has to be
8 million BP for them to go to their next form instead of 10 million
<li>Dust optimizations
<li>Fixed a bug that made every zombie incredibly overpowered.
<li>Fixed a bug where people intentionally infect themselves with zombie virus, then get someone to
use the heal ability on them over and over, which is -10 virus each time, and it would send it to the
negative, which caused you to gain health from the virus instead of lose it. There was people
with -500 zombie virus and 5000% health, unbeatable.
<li>Really fixed the teach timer reset bug now (credit Doniu)
<li>Gave Kai's 10x starting gravity mastery because Sheep / CodeNameDerp mentioned they needed it
<li>Hopefully extendo grab is fixed. And if your attempting to grab a mob with extendo grab it
no longer has to be directly out in front of you, but now in the line of tiles directly out in
front of you and the 2 lines of tiles bordering it. So a 3 tile wide straight out line in front of you.
<li>Disabled redo stats for androids until I fix it because it can be used to bug your stats far
past what anyone can get legit
</ul>

v21 (2/1/2013)<br><ul>
<li>Made unlock potential a bit better, it was really terrible after the last nerf
<li>Fixed teach timer bug reported by Doniu
<li>Fixed arm stretch not working due to runtime error
<li>Fixed blast knockbacks not working due to runtime error
<li>Added a system that is really hard to explain but, if you are for example 500 bp and the strongest
person online is 5000, lets just say that means your in the weakest 10% of players. So you log out
to sleep, and your gone 12 hours, you come back, the strongest person on is 25000, your still 500,
your now in the weakest 2% of all players. You lost a lot of status, a lot of 'position in the food
chain' so to speak. This new system is to make it so you don't lose so much of your position in the
food chain when you log out for the night, if you logged out in the weakest 15% of all players, you
will log back in the weakest 15% of all players. So with the example before instead of logging out
500 and coming back 500, you would come back 2500. In reality there is some loss in your position
compared to everyone else, I was just simplifying it. Basicly if the strongest person gets 5x stronger
while your asleep, you will come back 4.25x stronger or something like that. There is a hidden verb
you can use to test the results of this system. Just type 'test2' in the input bar or macro it and you
can test different values. It works for stronger people too of course, if you were 10'000 bp when you
logged out, and you were the strongest on, then when you come back someone is 50'000 bp, your bp
will be updated to 42'500. So your position in the food chain only went from to top 1% to the top
13% or something like that. Without this system you would come back still 10'000 bp, which is the
bottom 20% of weakest players, a huge loss in status overnight. It means you went from the strongest
online, then come back, and somehow 80% of players can kick your ass now.
<li>Nerfed door hackers because clearly they are too overpowered if I log back in to have all my
shit stolen every time I go to sleep even tho I upgraded my walls using a packed human with 2.4
intelligence mod and capped knowledge. Lowered the cost of door hackers too tho.

<li>Nerfed strength whores in 2 ways. The reason for nerfing strength whores is because it is the most
overpowered build, and this is reflected by the stat-info verb of mine which shows the average of
each stat that all players have on the server, it said strength was 24k, durability, speed, offense, and
defense were all near 11k, and force and resistance near 8.5k. So strength was over twice as valued as
any other stat, and to me that is proof enough that it is overpowered. Here are the nerfs I did:
1) Knockback distance was multiplied by (attacker.strength/defender.durability), now it is multiplied
by (attacker.strength/defender.durability)^0.65. Long story short, if you had 4x the strength
than your enemy has durability, and you were knocking them back 16 tiles, now it'll be more like
10 tiles. This doesn't sound like a big deal but knockbacks were a big reason why damage per second
builds kind of suck, a damage per second build is one that primarily has strength, speed, and offense,
with neither of those being too out of proportion to each other. If they are getting knockbacked long
distances a
lot of their DPS ability becomes useless, because even tho they can technicly attack like 4 times a
second or something, they can't attack while they're being knockbacked, so the actual time between
their attacks is far far less than they are actually capable of. In fact I believe the strength whores
with their huge knockbacks do far more DPS overall than an actual DPS build fighting against them. This
doesn't at all change the knockback distance of 2 balanced stat's opponents fighting each other, it was
4 tiles before, and it still is 4 tiles. It is only the scaling that changed. When fighting a guy
with better dps than you who attacks extremely rapidly, you can still negate a lot of their dps
ability by running around
them and causing them to move while fighting and miss more often, putting more time in between their
attacks than they are optimally capable of if you chose to fight them in straight line back and forth.
Because even if running around them only causes them to land 2 hits per second instead of the 4 they
would land if you fought them in a straight line, your still taking half the damage you would and
decreasing their odds of winning greatly. Ok bye. 2)
Nerfed strength's influence on damage, it has diminishing returns at high levels.

<li>Grab cheating is a form of bug abuse where a person who is losing grabs someone so that that
person takes all the damage instead of them. I fixed this in 2 ways: 1) If you have something
grabbed you can not attack. 2) Getting knockbacked cancels anything you have grabbed and people can
knock whatever you have grabbed out of your hands
<li>BP is now updated immediately upon getting angry to fix an annoying problem where you will get angry
but then get KO'd by the very next hit if it comes before your BP is updated to reflect your anger
level. It happened quite often and was very annoying.
<li>All thanks to Blackheart / LeaderOfTheSeven for making all the extendo arm icons.
<li>Majins now have extendo arm, up to 60 tiles. Nameks have 100 tiles.
<li>Aliens now have extendo arm if they choose it as a starting ability, up to 47 tiles.
<li>Androids now have extendo arm if they install the module for it, up to 40 tiles, but it travels
at the maximum possible velocity even if your character isn't the fastest online
<li>Fixed the bug that let extendo arms grab people out of their sealed houses
<li>Fixed a bug with aliens that let them spawn with insane amounts of energy that nobody could
get legitimately.
<li>Fixed a bug where half saiyans could not be made using mate
<li>If the amulet is used in hell on the first month of every 2nd year (2, 4, 6, etc) the portal will
take you to Earth for some reason
<li>You can now cancel arm stretching by hitting grab again and also the max range is now 150 tiles.
<li>The upgrade cap no longer fluctuates, it only goes up, at a steady rate, and never goes down.
<li>Namek arm stretch ability added. All Namekians can do it from the start. Just use grab at something
far away from you.
<li>A Saiyan now jumps to 5.1 bp mod after getting Super Saiyan.
<li>SSj 1 and 2 are now 1.4x boosts instead of 2x
<li>The amount of static BP that ssj 1 and 2 give gradually lessens based on whatever your base BP is,
until there is no static boost any more, only the multiplier.
<li>These changes to saiyans were to make their base form not entirely useless at later stages of the
game when people have >200 million BP
<li>Lessened ascension boost for all races by 25%.
<li>Legendary saiyan genetics are now impossible to clone.
<li>Races now have mods for how much they gain from unlock potential. See the race guide for details.
<li>Spirit dolls now do 1.5x more self destruct damage than any other race.
<li>Bio android forms should now be far more powerful especially when the server average is under
35 million bp. But, to go to their next form they must absorb either an android who has over 10 million
bp, or a Bio android who is already in a higher form than they are.
<li>There are 2 new racial mods: power absorb mod and knowledge absorb mod. They impact what you gain in
BP and knowledge when you absorb someone. View the race guide to see the mods for each race.
<li>Absorbing scraps of an android now gives you the knowledge of that android if you had less than them
<li>The main villain no longer needs to have the bp requirement to blow up a planet.
<li>When the main hero dies from the villain they now have a 50% chance to lose their hero rank instead
of 35%. If anyone but the villain kills them they lose the rank immediately.
<li>When sagas are on, the villain now deals +35% damage to anyone other than the hero instead of +100%.
The hero takes 25% less damage from all evil people except the villain instead of 50% less,
and 35% less from the villain instead of 50% less.
<li>Reactivated the client side preferences saving since it is now known it is not the reason why
the server refuses to reboot.
<li>Redid the way aliens choose their special alien skills using a points system where each choice
costs a different amount. Removed useless choices and added some new choices.
<li>Time freeze is no longer teachable and is alien only.
<li>Limit breaker is no longer teachable and is alien only.
<li>Installing modules or having cybernetic BP no longer completely stops you from leeching, instead
your leech rate is divided by 3.
<li>Installing modules or having cybernetic BP no longer lowers base bp gain at all. It used to divide
base bp gain by 4.
<li>Having modules or cybernetic BP now divides the amount you get from zenkai by 4
<li>Android's can no longer get any anger boost or put points in anger.
<li>Android bp mod raised from 1.7 to 2.3
<li>Android ascended bp mod is now 20% higher to compensate for lack of anger boost.
<li>Android's now have more stat points to spend because their force, regeneration, and recovery
defaults are now lower.
<li>Android skill mastery raised from 3x to 5x
<li>Android knowledge cap rate raised from 0.5x to 0.8x
<li>Android zenkai mod lowered from 0.1x to 0x, now they have no zenkai at all.
<li>Aliens now have 91 stat points but each stat starts at 0.6. This makes their builds the most
customizable of any race. The ultimate whores, I guess. They still need more perks tho.
<li>Fixed the game offering anyone who makes a character all ranks.
<li>Made beam collision graphics look better
<li>Reduced npc bp by half because they were over powered.
<li>You can now wish for a time chamber key on the dragon balls.
<li>Building in space now works.
<li>It is no longer possible to get super saiyan from anger caused by the rage drug.
<li>Fixed mating bug where the child is born with 0 bp mod.
<li>Made more changes to the bp gain formula but they're pretty much unexplainable.
<li>Fixed the bp mod bugging to insane levels, 95% sure of it this time.
</ul>

v20 (1/17/2013)<br><ul>
<li>Added a client side player preferences file which will carry over between all servers so now if you
create a new character on any server it will load your personal settings. Currently it saves your
map view size, ignoring votes, ooc on/off, fullscreen on/off, admin see logins on/off, adminchat on/off,
build tab on/off, science tab on/off, ignore league invites on/off, ignore soul contracts on/off,
text size, text color. This
should lessen the annoyance of setting up new characters. There will be more saved settings added
in the future I'm sure. Thanks to EXGenesis for providing the client side savefile code and idea.
<li>When someone destroys a planet, the prison itself places a 30 million bounty on them
<li>Dead people can no longer be absorbed
<li>Player made spawns are now destructable but very durable. You must right click a spawn to upgrade
its health/bp.
<li>Blast absorb is now easier to overload
<li>Super Saiyan now requires 2/3rds of your BP requirement be in base bp instead of 1/3rd. So
previously if your requirement was 900k, you needed at least 300k base, now you need 600k.
<li>Senzus and fruits are now disabled in the tournament
<li>When alignment is on, good ranks are forced good and evil are forced evil. The only way to
get a different alignment is to remake.
<li>When alignment is on, good people can not use planet destroy.
<li>Saiyans are now raised to 2.5 bp mod upon getting Super Saiyan.
<li>Saiyans can no longer leech the 2.5 bp mod of a Half Saiyan.
<li>Half Saiyans can no longer be the first to get Super Saiyan 1. They must be inspired first even
tho their requirement is lower.
<li>Half Saiyans can never get Super Saiyan 4 now or go Golden Oozaru.
<li>Lowered the cost of door hackers since they essentially cost double after upgrading. (30 mil to make
and 30 mil to raise to 100%) and they cost a ton after that too since you will need to keep upgrading
after your knowledge increases.
<li>Kais now start with 10x gravity mastered.
<li>There is now a 3 hour wait between votes instead of 1 hour.
<li>People can no longer get death anger from there own deaths, and therefore can not get ssj from it
either.
<li>You can no longer get death anger off of random people dying near you. It must be someone your
character knows the energy of. To know someone's energy you need all 3 levels of sense, then spend
a while near them (average 10 minutes, max 20). You can tell that you know someone's energy because
you can teleport to them using SI. The game assumes you know this person well enough to get death anger
if you spent that much time near them.
<li>Demigod ascension is 15% better now because it was the worst race after ascension.
<li>Changed demigod starting build, they now use up 25 points instead of 35 so you can spend more how
you want.
<li>Orbital cannons are now 5x more durable.
<li>Players can now build in space but it'll cost 100x more than normal
<li>Added an 'im trapped' toggle for lv4 admins
<li>Changed bp gain formula again. It was
(base_bp/bp_mod)**0.7*bp_mod*gravity_mastered**0.3*Amount*Gain/80000. Now it is
(base_bp/bp_mod)**0.7*bp_mod*gravity_mastered**0.37*Amount*Gain/60000. So gravity has more impact
and also gains are overall higher anyway. This means 500x gravity mastered is 10x more bp gains than
1x mastered, before it was only 6.45x more. The original formula that the game had for a very long time
was (base_bp/bp_mod)**0.5*bp_mod*gravity_mastered**0.5*Amount*Gain/20000 I believe.
<li>Increased max view size to 34x34
<li>The amount of SP that SP pack gives now scales to the server's sp multiplier, with a minimum of
+20 x racial sp mod.
<li>Energy gains now scale down gradually after 1000 (x energy mod) energy instead of slowing down in
sudden and harsh tiers. Before 1000 x mod your gains are normal.
<li>Dragon balls now become active 6 hours after the last use instead of 10 hours.
<li>Anyone can learn planet destroy now. But there are heavy restrictions, use Examine on planet
destroy for details.
<li>New lv4 admin command set_planet_destroy_immunity_time. Sets how many hours a planet will be
immune to being destroyed after it was last destroyed.
<li>New lv4 admin command set_planet_destroy_bp_requirement. Sets what % of BP compared to the
highest BP online that a player needs to be able to use planet destroy.
<li>Changed Shunkan Ido's first use timer from 120 seconds to 45 seconds, and the minimum time you
can get it to is now 6 seconds wait instead of 10 seconds.
<li>Forced injections are now off by default but there is a lv4 admin command called toggle-forced
-injections to change that.
<li>New lv4 admin command: Manage-learnable-skills. Lets admins set which skills can or can not be
self learned from the learn command.
<li>Unpassworded doors can no longer be grabbed
<li>Fixed scatter shot
<li>Nerfed unlocked potential to 1/3rd of what it was but made it so you can get unlocked every 6
hours instead of 12.
<li>Force field items can no longer be upgraded while the game considers you "in combat". Which means
if you have been recently attacked.
<li>Imprinting someone's BP now only gives 85% of the real person's BP who the DNA came from, instead
of 90%.
<li>All ranks, including elite saiyan, and also legendary saiyan, that give more than 1000 BP starting
out, now give it in the form of what was previously known as 'hbtc bp', but a more accurate term now
would probably be unleechable BP. As the rank/race gains more BP legitimately, more of it becomes
leechable. This was added because of people creating ranked alts to leech their BP on different races
which was in my opinion ruining the early stages of the wipe where everyone is supposed to be at low
BP except for very few ranks and special races.
<li>Elite Saiyans now get 6300 to 7700 BP starting out, more than before.
<li>Legendary Saiyans now get 8000 to 10000 BP starting out, more than before.
<li>Added set-server-leech-mod command for lv4 admins to set how fast all forms of leeching are.
<li>Nerfed maximum allowed zenkai gains slightly.
<li>Nerfed absorb's effectiveness to 30% of what it was.
<li>You can inject rage while knocked out.
<li>Icers no longer lose their overlays when transforming.
<li>Halved the rate that resources refill for all planets, everyone was rich, it was lame. Scarcity =
competition.
<li>Fixed a bug with battle power imprinting, where it would overwrite your gravity mastery. It was only
supposed to do that if you had lower gravity mastery than it would give you.
</ul>

v19(10/8/2013)<br><ul>
<li>More durability lessens gravity damage. By more durability, I mean what share your durability is
of your total stats. So like 26% durability build takes less gravity damage than 13% durability.
<li>Regeneration lessens gravity damage, but you will not regenerate health in gravity above your
mastery.
<li>I redid the gravity mastery and gravity damage formulas, you can now never fully master the gravity
your using, it just gets slower and slower as you near it but can never actually reach the amount your
using.
<li>Gravity now has less impact on BP gains. It was 1x mastery = 1x gains, 10x = 3.16x. 100x = 10x.
500x = 22x. 774x = 27x. Now it is 1x = 1x. 10x = 2x. 100x = 4x. 500x = 6.5x. 774x = 7.4x. I lessened
it because it was doubling up with the whole "the more bp you have the faster you gain" feature, to
create far more gains than intended. So you were gaining more bp from having more grav mastery and
gaining more bp from having more bp.
<li>You can now only leech 1/10th of a person's gravity mastery instead of 1/5th.
<li>Gravity mastery is now leeched half as fast.
<li>Time chamber is now 10x gains instead of 20x.
<li>Fixed a bug with body swap where if you body swap a logged out player when they come back there will
be 2 copies of them with double items/resources/etc, thanks to Doniu reporting it.
<li>AI training is now properly removed from bodies of people who had packs if someone without packs
gets the body.
<li>To get inspired by a super saiyan you must now be fighting them. It could take up to 2 minutes
of straight fighting to get inspired, or could happen instantly, but average is 1 minute. You no
longer need to be close to their BP to be inspired, anyone can be inspired if they can last in a
fight. This was to slow the spread of super saiyan.
<li>Fixed a mate bug where if one parent logs out during the mate the child is born with null race and
0 bp mod.
<li>Kienzan and Sokidan can no longer glitch past walls.
<li>Drone AI can now only be installed on androids, not regular players.
<li>Fixed the bug that let people use amulets to go over walls thanks to Rikscen.
<li>Fixed a bug where Saiyans endlessly ascend to ever higher bp mods due to a bug, when they aren't
supposed to ascend at all.
<li>Admins can now build in space.
<li>Cut down on the amount of dust things make, by roughly half, to lessen lag.
<li>Bounty drones now deploy on a 20 minute loop instead of 10 minutes, so they are less bothersome.
<li>Bounty drones can now be manually called on someone using a new item.
<li>Ascension is now 25% stronger.
<li>Fixed some safezone bugs that let you knock people out of safezone and kill them.
<li>Blast now fires 2 blasts at once (1 from each hand) but I nerfed the damage of each blast from
3% to 2%, this also makes it slightly easier to deflect them, so overall I would say each blast is half
as effective as before, but it fires twice as many.
<li>Can no longer rape in tournament.
<li>Regeneration now slightly decreases health drain from kaioken, but your % of durability has far
more effect.
<li>Recovery now slightly decreases energy drain from kaioken, but your energy mod has far more effect.
<li>New level 4 admin verb to toggle whether earth npcs have a chance to drop time chamber keys or not.
<li>Made digging and npc drops give 10x more resources. But also raised the cost of the cheaper
technologies by 10x. This was to bring digging and drilling closer together while still having drilling
as the best.
<li>Minimum bounty is now 1 million resources.
<li>Blasts were causing 8-12x more lag than the next most lag causing process, so I redid the system to
use 'blast caching' instead of creating/destroying hundreds of blasts over and over. I expect this
system will have bugs at first.
<li>Orbital cannons should be fixed as long as that was the only bug.
<li>Made it harder to lose your tail. Only attacks that are labeled as slicing attacks will slice off
tails now, and only if they deal more than 20% damage at once. Currently the only attack labeled as a
slice attack is kienzan and swords.
<li>It's harder to lose your tail but now also harder to get it back. The only ways to get your tail
back is to use an upgraded artificial moon or be less than 16 years old and it'll grow itself back.
<li>All earth npcs now have a chance to drop the time chamber key. The % chance of dropping it is
100 / (existing_hbtc_keys+1)^3. So the more keys exist the less your chances by far. 0 keys = 100%.
1 key = 25%. 2 keys = 11%. 5 keys = 4%. 10 keys = 1%. They also will only start dropping them after
the server has been up 5 minutes.
<li>I noticed a few problems with the bp gain formula, at least on 1x gains, where people start hitting a
wall after about 2 million base bp. There would of course be Super Saiyans by then but getting
Super Saiyan 2+ is quite a challenge unless server gains are raised, and they shouldn't have to be now
that I changed the formula because your gains will scale more dramatically with how much base bp you
have. Also when server BP was low people gained too fast it made the
"dragon ball" feel of the wipe end too early, then it becomes the age of the Super Saiyans. See below
for the new detailed changes to the bp gain formula.
<li>The old formula was this: bp_gain=(base_bp/bp_mod)**0.5 * bp_mod * gravity_mastered**0.5 / 10000.
This is a simplified version with a lot of the more complex modifiers removed but I did leave in the
gravity modifier. Remember to use order of operations correctly if you try to work out your gains
using these formulas or you won't get the right answer. Although it's simplified it still represents
your 'base' gains, before things like weights, being in time chamber, etc.
<li>This is the new formula: bp_gain=(base_bp/bp_mod)**0.7 * bp_mod * gravity_mastered**0.5 / 80000.
<li>Here are some examples of a person's gains based on the bp they have using the old formula,
assuming their gravity mastered is 1x, and bp mod is 1x. That would give their gains per second, but
I'm multiplying it by 60 to show gains per minute. Then multiplied by 5 to represent sparring's 5x
modifier. Then multiplied by 3 to represent weight's modifier.
<li>100 bp = +0.9/min
<li>1000 bp = +2.85/min
<li>10000 bp = +9/min
<li>100000 bp = +28.5/min
<li>1 million bp = +90/min
<li>10 million bp = +285/min
<li>100 million bp = +900/min
<li>These numbers actually seem suspiciously low I'm pretty sure that someone with 10k bp gains much
more than just +9 per minute but that is what the formula says. I know I gain much more than that
though. But as I said there is a lot of modifiers I didn't factor in, if I didn't factor in sparring (x5)
and weights (x3) then the numbers on this chart would've been 15x (5x3) which we know isn't accurate.
So even if there is just one missing 4x modifier I left out that by itself is 4x more gains than this
chart shows.
<li>Now here is a chart for the new formula.
<li>100 bp = +0.28/min
<li>1000 bp = +1.41/min
<li>10000 bp = +7.1/min
<li>100000 bp = +36/min
<li>1 million bp = +178/min
<li>10 million bp = +893/min
<li>100 million bp = +4478/min
<li>Super saiyan inspire was completely not even working. Fixed.
<li>Charge now fires half as fast but has 34% base damage instead of 22%, and 1.5x more if you don't
move positions while charging it.
</ul>

v18 (12/30/2012)<br><ul>
<li>Fixed league expel being bugged that Doniu reported
<li>Fixed tournament stealing that KeVeiiN reported
<li>How far the knockback on a ki attack knocks back someone is now relative to the power difference
of the 2 players. The more BP+resistance you have compared to your enemy's BP+force the less distance
you will get knockbacked. In the case of projectiles that deal physical damage such as shurikens and
ballistic bullets it is BP+durability vs BP+strength (if it's a gun then that means the strength of
the gun not your own strength).
<li>Knockback on rapid blast is now 2 instead of 1
<li>You can now move while using Charge, but if you move it does less damage. A moving charge has 22%
base damage, a stationary charge has 33%. Anything that moves you from the original position you started
charging in lessens the damage, whether someone grabbed you or knockbacked you or anything.
<li>Lessened buster barrage drain by 4x.
<li>Halved the drain on attack barrier.
<li>Nerfed kienzan from 67% base damage to 45% but made the drain 3x less.
<li>Buffed scattershot from 2.7% base damage to 3.5% and fixed the bug where it targets you without
warning.
<li>Bolted objects no longer get sucked into the dead zone.
<li>Medical scans now show the balance rating of your stat build
<li>Since whoring particular stats is still a big problem, and no balanced character can ever defeat a
whore (it's literally near impossible, balanced is the worst build), EXGenesis came up with this great
idea where every character has a 'balance rating' which is determined by how balanced their build is,
the worse their balance rating, the lower their stat cap. Whores will still have more stats in their
chosen stats than a balanced person would, but this just makes the scaling a bit less dramatic.
<li>Bio field generators are now better because they pulse more often. Also if you right click it
when next to it you will see a Upgrade/Repair command that can be used to upgrade the generator's
health based on your knowledge.
<li>Also added upgrade/repair commands to bounty computers, cybernetics computer, drills, genetics
computers, peebags, punch machines, orbital cannons, sunlight generators, wells, devil mats, gravity,
med scan, nukes, sonic bombs, simulators, and telepads,
and made it so that instead of using the system where if you have over the bp needed to destroy the
object you destroy it in 1 hit, and if you have less bp then you can't destroy it at all,
it takes gradual damage with each hit.
<li>Because dragon balls keep randomly disappearing no known reason, I added a loop that checks each
minute for missing dragon balls and recreates any that are missing.
<li>RAGE drug added. Get angry on demand but lose 2 months of decline age. Slightly weaker than natural
anger.
<li>New Kaioshin skill: Focusin revert. Reverts the effects of focusin from anyone you use it on, as if
they had never used it.
<li>Changed the effects of focusin, use examine on it for details
<li>Death ball now has 75% base damage instead of 52%.
<li>Rapid blast is now 2.25x harder to deflect than before because people said it was useless.
<li>All ki attacks except beams are now 50% harder to deflect, because I've noticed that deflection
seems to happen far too often even with supposedly strong attacks like Charge
<li>All beams have had their drain formulas changed and piercer has had some minor damage decrease to
lessen its extreme drain.
<li>Raised peebag bp and stat gains from 2x to 3x since apparently they are useless since nobody uses
them.
<li>Added an orbital cannon to science that can be put in space then told to monitor a certain planet
and it will destroy any ships it finds on that planet with an orbital strike, preventing anyone from
leaving the planet that way.
<li>Tripled drone AI cost
<li>New item: Focusin
<li>Accidently made time freeze cooldown 10x longer than intended. Fixed it now.
<li>Dash attack now drains 25% ki instead of 20% (energy mod decreases the drain). Also the further
away from an enemy you are when you try to dash attack them the more damage it will do if it succeeds.
One tile away only does 25% 'normal' damage, 2 tiles = 50%. 3 = 75%. 4 = 100%. 5 = 125%, and so on.
People spamming dash attack was pretty annoying, it was meant to be a finishing move not something
that is spammed.
<li>Fixed a bug with any blast when it hits a wall that it can't destroy it just lays there instead
of disappearing.
<li>BP now has more importance.
<li>New cybernetic module: Time normalizer: Makes you immune to time freeze and paralysis effects
but has quite a few drawbacks, which you can view by right clicking the module and hitting Examine.
<li>Androids/cyborgs can no longer be observed because their energy is unsensable.
<li>Nerfed time freeze by putting a long cooldown between uses so that it can't be used on someone
again as soon as it has worn off. Speed decreases the cooldown.
Each person frozen decreases your available bp.
<li>New oozaru icons from Daiguren Hyourinamru
<li>Fixed a cybernetic module bug that gives people negative resources.
<li>People with death regeneration no longer die from space.
<li>Added a 3 minute time limit on tournament matches. At the end of the time the person with the lowest
health loses. If both have the same health then it picks randomly.
<li>I think I fixed the tournament bug where it incorrectly ends the tournament when there is an
uneven amount of fighters.
<li>On tier mode when "gain tier from tournament" is enabled, the amount of tiers the winner gets
now depends on how many people joined the tournament. This was to stop a exploit where late at
night when nobody is on, one or two people would join tournaments and gain like 20 tiers easily.
If exactly 8 players join, the prize is +1 tier, if 4 joined then there is a 50% chance of +1 tier,
if 16 join it is +2 tiers, if only 1 person joined it is a 1/8th chance of gaining +1 tier, and
anywhere in between.
</ul>

v17<br><ul>
<li>I THINK I fixed a resource doubling bug using body swap, where if you body swap into someone
who has a lot of money, then unswap them while your running around, it leaves a clone of them. If
you destroy the clone you double your money.
<li>Fixed a stat bug where you take dna from an npc's dead body and imprint it on yourself to go past
the cap.
<li>Fixed the grab bug that people used to grab ungrabbable things by putting an object of the
same name on top of the ungrabbable object then grabbing it.
<li>Fixed a bug to double your str/dura with swords/armor by being body swapped, having the droid
drop the sword/armor, unswapping you, then re-equipping the sword/armor and repeat
<li>Made the first prison sentence time more severe, but lessened the time scaling for each
consecutive sentence. It used to be 20 mins then 40, then 60, then 80, etc. Now the first sentence is
36 mins, then 51, then 62, then 72.
<li>How many times you have been imprisoned now carries over between characters even if you remake
so remaking would not reset how long you have to spend in prison if you are sent there again.
<li>Fixes to sagas system
<li>Admin verb: hero-training-gives-tier. makes it so going into a hero training period gives +1 tier
upon ending but they don't actually gain any BP during.
<li>Admin verb: gain-tier-from-tournament. makes it so the tournament winner gets +1 tier on tier mode.
</ul>

v16<br><ul>
<li>Made absorb cost a lot more SP because almost everyone had it and to me it kills the feel of the
game because in DBZ absorb was more of a racial thing and although I still want people of any race
to be able to get it I think it should be much harder. Races without absorb should have to train
for their power.
<li>Changed hub password so that only people hosting this version or higher can appear
<li>Beams are 1.5x more damaging
<li>Getting inspired to get ssj meant that any normal anger you got after that would cause you to go
super saiyan. Well now there's only a 'chance' of normal anger doing it, per anger. Having better anger
mod improves your chances. A person with 1x anger (which is no anger) has a 20% chance to get super
saiyan per anger. A person with 2x has a 40% chance.
This was added because super saiyan spreads too fast thru inspiration, at least now if it fails they
have to wait 10 minutes for anger to recharge before they can try again.
<li>Recovery affects power up speed more than before.
<li>Did a few things to make defense more important since it is still the shittiest stat by far. I just
amplified the scaling effect it has on your dodging ability by a bit, and blast deflection.
<li>Swords no longer boost hokuto power
<li>Nerfed hokuto
<li>Fixed the infinite stats bug.
<li>Can only bind once per 30 minutes now. Spam binding everyone in sight was bullshit.
<li>Changed ssj3 aura.
<li>Signs now have floating text.
<li>Made bp differences between people matter less in fights.
<li>Disabled mark as evil because people only abused it and didn't use it for any legit reason. They
only used it on people they hate or are jealous of or just for the sake of trolling, to give someone
the evil person damage penalty.
<li>Brought back auto backhits due to player vote, but there is only a 5% chance of them happening now.
Auto backhits were when if you dodge a person's melee you teleport behind them and backhit, like a
counter attack, defense raises the chance.
<li>Nerfed genocide even more that shit is beyond gay and is ruining everything. Damage lowered from
1.4% to 1%, deflection difficulty lowered from 1x to 0.5x. It now cost 40 sp instead of 20.
<li>Fixed bind.
<li>Digging and npc drops have been tripled. The cost of some cheaper items was also raised. This is
just to close the huge gap between digging/npc drops and drilling.
<li>Sokidan damage raised from 33% to 67% (same as kienzan) because it sucked.
<li>Sokidan move delay raised from 1 to 1.5, kienzan has 1 so kienzan is faster.
<li>Genki dama now charges twice as fast because it had no practical use.
<li>Buffed death ball damage from 33% to 53% since it was a useless attack.
<li>Nerfed spinblast. It now does 3.3% damage with 2x offense instead of 6.6% and 4x.
<li>Buffed regular blast, it now does 2% damage instead of 1.6%, and the damage scaling for lower refire
blasts has been improved. Firing them half as fast was +41% damage, now it's +74%. Normal scaling
would mean that if you fire them half as fast then they do double damage (+100%), but it doesn't do
that because it has to factor in that you are more free to run around when you fire your blasts
slower, and that they are harder to deflect, and that you can aim the better than just spamming them
all over the place.
</ul>

v15 (10/4/2012)<br><ul>
<li>Added blood bags to science, which are used to extract blood from someone for vampires to then
drink it, which sets their hunger back to 0. Problem is each time they do this their hunger raises
back up faster, until they bite an actual person to reset it back to normal.
<li>Since defense is still terrible and the worst stat, I made it so defense plays a role in your
melee accuracy. It was that only offense played a role. Defense plays a lesser role in the accuracy,
for example doubling your defense would increase accuracy 41%, but doubling offense increases it
100%. It sort of makes logical sense, that knowledge of defensive tactics would help you bypass
those same tactics somewhat when others try to use them against you.
<li>Instead of hokuto being only based on the attacker's BP vs the defender's BP, it is now their
BP, strength, and force, versus the defender's BP, durability, and resistance.
<li>Hokuto no longer changes your stats when you use it because people could get bugged stats if
they logged while hokuto was in progress.
<li>When a hero death avoids they now properly lose the title when their logged out body is killed.
<li>Ki fields now properly block self destruct.
<li>Raised melee accuracy from 35% to 50%.
<li>Evil people can no longer have good alts, all their characters will be turned evil.
<li>Removed shockwave's exaggerated BP scaling. Shockwave at the same BP as someone did 1.5% damage
to them, but go to 4x their BP, and you do 36%, which is 24x more damage at 4x their bp than at 1x.
I put the scaling back to normal, now a 4x your bp person would do 6% damage, 4x normal damage.
<li>Removed explosion's amplified damage scaling as well.
<li>When alignment is on, good people can not take tiers from other good people. This is a major
disadvantage for them because evil people can run around spam killing anyone to get tiers. Usually
only 25% of players are evil so a good person's chances of getting a tier is greatly decreased. I
didnt add anything to counteract this problem, but certain server settings like increasing evil damage
penalty when both tiers and alignment is on will help balance it.
<li>The speed that you power up now decreases the higher you power up. It used to be the same amount
of increase all the way up.
<li>Having buffed bp decreases powerup speed by the same multiplier it is increasing your bp.
<li>Base powerup drain lowered from 0.15% to 0.1%.
<li>Base powerup speed raised from 1x to 1.5x.
<li>Powerup mastery raised from 2x to 3x.
<li>Super Saiyan no longer has a recovery nerf, because the point of it was to make them have slower
powering up, but now they have slower power up from the bp multiplier that super saiyan gives instead.
<li>Nerfed melee base damage from 4% to 3.6%.
<li>Genocide no longer hits people who are hiding power.
<li>Backhits now do 2x damage instead of 4x.
<li>Hits from the side/back are now 2x more accurate not 4x.
<li>Fixed splitforms not dividing a cyborg's BP properly.
<li>Wearing a sword no longer boosts shuriken damage.
<li>Alignment changes are now every 10 hours instead of 24 hours.
<li>Nerfed genocide damage from 10% to 4%.
<li>Fixed genocide killing people in tournaments. Killing in tournaments is bug abuse.
<li>Added a slight timer between creating many splits at once.
<li>On tiered sagas mode BP gain is now possible. When the hero enters a training session they
are the only ones who can gain BP. Other people can leech that BP by the usual ways. If global BP
leeching is on, the hero's BP becomes globally leechable 1 hour after their last training session
began.
<li>Hero now takes 25% less damage from the villain. That's in addition to their long list of other
advantages that they still somehow can't manage to succeed with.
<li>Removed auto backhits they were just too annoying.
<li>Added a sagas system. The main hero gets x2 leech rate, ability to get angry every time instead of
50% of the time, and no 10 minute wait between angers, stays KO'd 30% less time, and masters
super saiyan levels twice as fast.
When fighting anyone of evil alignment the hero will take half damage. Main villain does 2x damage
against anyone other than the main hero, who he does normal damage to. Main villain gains bp 1.3x
faster than normal. The main villain is
given 2 hours to kill the main hero or they lose the villain rank. Each main hero they kill gives them
another 2 hours of epicness. When the villain kills the main hero there is a 35% chance the hero rank
will go to someone else, but the other 65% of the time the hero will get 30 minutes of 5x increased bp
gains to train for vengeance. If the villain attacks the hero during this training period they lose
the villain rank. If the hero attacks the villain it ends their training period. If the hero dies from
anyone or anything else they lose the rank. If the villain dies at all they lose the rank. The main
hero has the advantage when fighting the main villain, but the main villain has the advantage against
everyone else. Being part of the "Z Team" with the main hero or a henchmen of the main villain
has advantages because training with them is faster. If the hero is a coward who only hides from the
villain then the villain can go on a killing spree, killing good people. If the kill count reaches a
certain amount without the hero responding then they lose the title for failing to protect the
innocent.
<li>Fixed brain transplant.
<li>Removed the admin command to change stat modes.
<li>Fixed unlock potential.
<li>Elite Saiyan now becomes an option if less than 20% of Saiyans online are already elite.
<li>Fixed anger bug from last update.
<li>You can now build closer to ship controls.
</ul>

v14<br><ul>
<li>Fixed the bug that let people use over powered guns in skill tournaments.
<li>Fixed body swap I think.
<li>Fixed the missing tabs bug.
<li>Went back to DBZ names.
<li>Magic food is now senzu beans.
<li>Unlock potential is now stronger but can not be used as often. It used to give you 1000 leeches
from the person unlocking you, and 800 leeches from a random person online. Now it gives 1000
from the person unlocking you, and 300 from the strongest person online. It can only be used once
per 12 hours.
<li>Redid Laser Beam's stats to be more appealing. It is the hardest of all beams to deflect,
because it is a laser made of light not ki. Laser Beam is a skill from a cyber module.
<li>Redid cyber charge's stats. It is similar to regular charge but does 50% damage instead of
80%, but fires twice as fast.
<li>Left clicking a spawn while next to it to bind to it now works.
<li>Binds now expire, a bind from a person with 1 energy mod lasts 1 hour. More energy mod increases
the time slightly.
<li>Time spent in the time chamber resets 36 hours after you last used it, so you can enter it again
every 36 hours.
<li>Auto backhit has been lowered to 7% chance instead of 10% and will only happen if knockbacks are
on, otherwise it assumes you are sparring and don't want to auto backhit.
<li>Swords can now be set to under 1x damage again, but it will not increase your offense stat. Instead
it will decrease your enemy's melee dodge chance. This way under 1x swords no longer give a boost to
ki attack offense, which made no sense. And over 1x swords will no longer decrease your offense,
which caused a penalty to ki attacks, which also made no sense really.
<li>Time chamber bp now counts toward the base bp requirement for super saiyan.
<li>Changed super saiyan inspiration system. It was that you needed 45%+ of a super saiyan's base bp
to be inspired by them, then the game made you wait randomly 0 to 5 years before you could go super
saiyan. Now, you need 80%+, but you don't have to wait any time afterwards. Next time you get angry
you will just go super saiyan.
<li>Saiyans can no longer leech Half-Saiyan's bp mod until the Saiyan has 5 million base bp.
</ul>

v13<br><ul>
<li>Fixed the annoying bug with rapid blasts, shurikens, and any other ki attack that fires rapidly,
where they would get stuck in front of the enemy piling up on each other but not hitting the enemy.
<li>Defense still sucked horribly and all the strongest most unbeatable people were sacrificing all
their defense as low as possible to channel it in to other stats. So I made a 10% chance that when
someone attacks you, you will zanzoken behind them. Defense increases the chance. The attacker's
offense decreases your chance.
<li>Fixed a bug that let people clone bp tiers.
<li>Fixed the shield bug that keeps KOing people over and over who have force fields (including the
module) and shield.
<li>Modules no longer decrease natural BP. Instead, cyber bp itself decreases natural bp by 25%.
It can actually be a bad thing if you have one of the highest natural bp on the server because
losing that 25% will outweigh the amount you gain from cyber bp.
<li>Fixed a bug not letting people go ssj thru death anger on tier mode.
<li>Nerfed stun gun's stun time to 1/2.5th of what it was.
<li>Restricted the change icon and color commands to only a few object types because it was causing
severe problems with the size of the item save.
<li>Added another mode called bp tier mode. When this is enabled by admins, training for bp becomes
useless. Instead you have a battle tier between 1 and 3 and your bp is based off of that. 75% of
players are tier 1, 20% are tier 2, 5% are tier 3. You can raise your tier by defeating people of a
higher tier. So instead of having to train for power your power will immediately reflect your in-game
performance, if you defeated someone stronger than you then your power will instantly reflect that
you should be more powerful than they are. Only tier 3s can get super saiyan thru death anger,
all others have to get it from being inspired.
<li>Fixed a bug making ssj1/2/3/4 much weaker than it was supposed to be.
<li>If your character was damaged in the last minute and you log out your character will be left
behind for 1 minute. This is to prevent the ridiculous amount of death avoiding that was going on.
<li>Kaioken has been completely changed and is closer to actual DBZ kaioken, you activate it if you
press G you go up 1 kaioken level and if you press H you go down 1 kaioken level. Use the examine
command on kaioken to see details.
<li>Werewolf is gone and its back to Oozaru now.
<li>Switched buffs to an additive system instead of multiplication, sort of, like before if some guy
had 4 buffs that each gave x2 bp, then he used them all at once, he would have 2x2x2x2 = 16x bp.
But now, an x2 buff means +1 bp_mult. So stacking all 4 is +4 bp multiplier, so 5x bp total.
So buff stacking is now less useful. Before, people were using special builds to get up to 30x their
base bp and bp wall anyone even tho they had really bad stats and stat mods.
<li>Because of the above feature, if your character existed before it was added, you will have to
revert from all buffs and then relog.
<li>Deleted hide energy, you now hide energy by simply powering down under 10%.
<li>Hell altar can now only be used once per 2 hours.
<li>Fixed the teach timer bug
<li>Made precog different. You now can only precog 3 times in a row before you run out of precogs
then every 3 seconds your character will recover 1 precog til it builds up to 3 again.
</ul>

v12 (9/24/2012)<br><ul>
<li>Redid the weights system so that any amount of weight you wear will still be useful, even if it
is just a small amount. I did this because before, there was a very narrow range of weight that was
useful for your character.
<li>Precog users now have 100% AOE auto dodge chance, but it will drain 10% (/ki mod) of their
remaining energy each use.
<li>Precog now dodges beams.
<li>Precog now dodges melee.
<li>Using the customize button you can set your precog chance which will let you not use it 100%
of the time if you want to conserve some energy.
<li>Fixed that annoying sound loop from shield.
<li>Added a basic ripple effect when shooting blasts across water, the icon is crappy but its all I
could find.
<li>Added beam deflection, 15% base chance, modified by attacker's offense and defender's defense and
the beam's deflect difficulty.
<li>Redid the movement system for beams so that it can accept decimal amounts, so that my only choice
for beam velocity isn't just 1, 2, or 3. Because of this I redid the velocities of all beams.
You can see the new stats by using the Examine command on the beam you want to see.
<li>Added a deflect difficulty stat to beams. Being more difficult to deflect increases the beam's
drain.
<li>People say explosion is worthless so I raised its base damage from 10% to 15% and magnified
the damage scaling so that weaker people take much more damage from it but stronger people take
very little. So, like shockwave, it is much more effective than normal on people weaker than you.
<li>There is now a chance to teleport behind an enemy and score a backhit when using melee combo
teleporting. The base chance is 10%, then modified by your enemy's defense vs your offense. This
was to make defense more useful since people consider it the most useless stat and many just
sacrifice all their defense to amp up their other stats instead.
<li>Added a 5% auto dodge chance when someone tries to hit you with an AOE attack. Only works for
shockwave, explosion, and self destruct, if there is any other AOE attacks then I forgot to add it
for those. The 5% is magnified by your defense compared to the attacker's offense. This was added
to deter people who use an 'ultimate build' which sacrifices all stats except force/resistance/durability
to amplify the damage of their AOE attacks to extreme levels. So now if they sacrifice offense
like before then their target's auto dodge chance raises a lot. Some can still be sacrificed without
increasing their dodge chance much, but taking offense down to 1 would guarantee they dodge it.
<li>Rebalanced all the teach timers. Some basic skills were teachable too soon, and some advanced
skills took too long. Brought them a bit closer together.
<li>Changed hundred crack fist a bit, it doesn't drain all the user's energy any more, but if it fails
to kill the target then the user is immediately knocked out instead. Also attack targets and destroy
targets was combined, so destroying happens automaticly now. It also cost more SP.
</ul>

v11.74 (9/22/2012)<br><ul>
<li>Death regener self destruct damage is now 1/4th as much as normal instead of 1/3rd.
<li>Removed the 20% chance that self destruct doesn't kill the user.
<li>Kaioshin planet's ability to gradually restore the youth of anyone who stays there now only works
on Kai race. Just as Hell's same ability only works on Demons.
<li>Fixed rank skills being immediately teachable and bypassing teach timer.
<li>The color of the dragon balls is now chosen by the creator of them.
<li>Dragon balls dropped in the void didn't return to their home planet and became permanently lost.
Fixed that.
<li>Ships in final realm now delete themselves.
<li>Halved planet resources to create some scarcity, since everyone was rich.
<li>NPC sense range is now 15 tiles.
<li>Only 20% of a person's gravity mastery is now leechable.
<li>Lowered time chamber bp gains to 20x instead of 50x. People were going in with 100k base, and
coming out with 800k, when the average is 80k. It should be effective but that is just ridiculous.
<li>Swords no longer can be set to do half the damage of melee, it just doesn't make any sense.
It also gave ki whores an offense boost which also made no sense.
<li>Added an admin command called where-is-everyone which tells me how many players are on each map
so that I can know where the most popular places are then figure out why they're popular.
<li>NPCs are senseable but only within 5 tiles due to lag.
<li>NPC's power now scales with players, their BP will match the average bp of the server divided by
2, times their bp mod, and they will be stat capped. NPCs have different bp mods making some more
difficult than others.
<li>Brought the prices of technology closer together, mostly by lowering the prices of the most
expensive things to about 1/100th.
<li>Planets now generate 1/100th as much resources to compensate for the re-pricing of technology.
<li>Removed synthesize from antivirus. If people want those special injections now they'll have to
do it the old fashioned way: zombie farms + zombie dna harvesting.
<li>Soul contract teleports/summons fail if the target moves.
<li>Kaio Teleport now lowers your energy to 0 two seconds before teleporting, and if you get knocked
out before the teleport occurs it interrupts the teleport.
<li>Telewatch can no longer be used when knocked out, teleport time has been increased from 2.5 seconds
to 4 seconds, and increases a lot if you move while the teleport is in progress.
<li>Added a timer to zanzoken because 1) it was never meant to be used for travel, only combat tactics.
2) it made it too easy to escape fights. The timer is lessened based on speed.
<li>Removed drill mass withdraw code.
<li>Nerfed shockwave's knockback overall but made the scaling more intense when using it on people weaker
than yourself, so its more useful on weak people but not useful on people near your power or
stronger. The old shockwave would knock someone equal to your bp 10 tiles away, someone twice your bp
5 tiles away, someone half your bp 20 tiles away. Now it'll knock someone equal to you 5 tiles away,
someone twice as strong as you 0 tiles away, and someone half your bp 28 tiles away.
<li>Lowered the price of space travel again.
<li>Went back to the old drill system, more or less.
<li>You can now set a 'mass withdraw code' on a drill by right clicking it and setting the code, then
whenever you click a drill all drills sharing that code will be withdrawn from at once no matter where
they are.
</ul>

v11.73<br><ul>
<li>Radars can no longer detect resources that are less than 1 million.
<li>Zanzoken mastery no longer provides a boost to accuracy/dodging in melee.
<li>Buffed shurikens, they really sucked.
<li>ki_power and melee_power now default to 1 each so if your server doesn't have them at 1
after updating then you probably want to set them to 1 each.
<li>Dragon balls now re-activate 10 hours after they were last wished upon, and reboots no longer
re-activate them. This means that using the dragon balls is now more rare than before.
<li>Dragon balls can now be used to wish for money, skill points, and knowledge.
<li>Fixed the bug that is letting people go ssj2/3 without needing the bp requirement.
<li>Trying out yet another drill system completely different than the "% share" system in use before.
<li>Ships and spacepods now cost more, it was too easy to travel to other players.
<li>Spacepods are now launchable by default no upgrading necessary.
<li>Removed the ability to lower someone else's stats/bp using genetics computer against their will.
<li>Fixed a way to abuse death regen and power up to power up to like 5000% and break any wall.
<li>Redid the spam kill timer display in the stats tab to be more smooth.
<li>Raised minimum drill share to 2% so that it isn't so hard for new drillers to get in the scene.
<li>Beams no longer 'hop' from tile to tile, but move smoothly. This is especially noticeable on
slow beams like Final Flash, which now look much smoother.
<li>Fixed the 'beam stun' effect which causes a person not to be able to move when being beamed by
high velocity beams such as piercer.
<li>You can now only teach 100% knowledge every 2 hours. The time decreases based on the % you teach.
So 50% is every hour. 25% every half hour. 10% every 12 minutes. And so on.
<li>Fixed a bug with the new hbtc system that caused people's hbtc_bp to train below 0 cutting their
available bp by 70%.
<li>Raised a drill's minimum resource share from 0.1% to 1%.
<li>Added skill tournaments. A certain percentage of tournaments will be skill tournaments which means
all fighters have the same power. Admins can set what percentage are skill tournaments. Default is 33%.
<li>Change icon now limits icons to 0.3MB and 160x160 pixels. It was 0.5MB and 224x224 pixels.
<li>Fixed a bug where drills dug resources in ships.
<li>Hiding on destroyed ships is now impossible. Every minute it does a check and if it finds a player
in a destroyed ship it sends them to their spawn and destroys all objects in the destroyed ship.
</ul>

v11.71<br><ul>
<li>Dropped resources with values less than 1 million no longer save because they were flooding the
item save.
<li>Time chamber has been revamped. It is now 50x bp gains. 10x stat gains. 3x sp gains. 10x gravity
mastery rate. 5x skill mastery rate. 5x adapt rate. Once the time chamber has aged your character 2
years you can not get any more gains from it. The BP from it is unleechable, stored in a seperate
variable, then added to current BP afterwards. Then for every 1 Base BP you gain you lose .7 HBTC BP,
until HBTC BP reaches 0 again, which sort of makes your BP gain feel slower after you leave the HBTC.
<li>Radar tabs now update faster.
</ul>

v11.7<br><ul>
<li>Bind is now teachable. Self learning now cost 35 sp, it was 20.
<li>Fixed the issue with dragon balls being duplicated after a server crash.
<li>Disabled weather again because it annoys me.
<li>Drills now have text above them which displays how much they dig per second.
<li>Fixed kienzaning people thru doors.
<li>Nerfed shield to 50% damage taken instead of 30%.
<li>Fixed the 'ship in a ship' bug. Ships in themselves now delete.
</ul>

v11.69<br><ul>
<li>Fixed drills hopefully. Also made it so that a drill can not have a share of the total planet's
resources less than 0.1%, so it will at least dig up something even if it only makes up 0.0001% of the
total digging happening on the planet.
</ul><p>

v11.68 (9/4/2012)<br><ul>
<li>Newton deleted the entire shell's hard drive, the pack website, all packs, host approval system,
host files, saves, everything you can imagine. EXGenesis is trying to fix it using an old backup
from June.
If your missing packs, post in the game's forum in the "Missing Packs" section so he can fix it.
Also if anyone can donate any money to EXGenesis he needs at least 25$ for some things related to this.
I would send it to him myself but my paypal is empty because packs have been at a stand still for 8
days now.
</ul><p>

v11.672<br><ul>
<li>The game can now host without checking Exgen's shell for approval temporarily since it seems
Romcio keeps crashing it and when that happens it thinks every host is banned.
</ul><p>

v11.67<br><ul>
<li>Reactivated weather due to player vote.
<li>Changed how drills work entirely. Basicly when a planet's resources refill, it gives each
drill on that planet an amount of those resources based on what percentage that drill's value is of
the total value of all drills on that planet. So if your drill is upgraded to 50m, and every other
drill on the planet combined adds up to 50m, you get half the resources each time the planet refills
even if there are 100 other drills on that planet. However the amount of resources your drill gets
each refill can not exceed 20% of the drill's upgrade level.
</ul><p>

v11.664<br><ul>
<li>Re-code-banned Romcio4 and Newton378 for crashing the server repeatedly again even tho he was
lucky enough to get unbanned the first time.
<li>Removed the stupid toxic waste thing I added.
</ul><p>

v11.663<br><ul>
<li>Halved the rate that a person can leech another person's gravity mastery, and capped it so you
can only leech half their gravity. I did this because almost everyone had maxed gravity mastery
even tho most of them never even trained in gravity. They should have to at least train SOME in actual
gravity to fully master it.
<li>If your flying, you can now transition to training without having to stop flying.
<li>Amplified the importance of speed in determining move delay.
<li>Fixed a knowledge multiplying bug.
<li>Can no longer change icon of ki jammers.
<li>Removed alt leeching because I don't like it. People can just train their alts it makes more sense.
<li>Added an exception allowing the builder of a turf to build over it even if they somehow lost
the necessary knowledge.
<li>Added toxic waste drums that if destroyed give all players nearby cancer, and they die.
</ul><p>

v11.661<br><ul>
<li>Shield now blocks dash attack, shockwave, and self destruct.
<li>When using shield, if all your energy gets drained from someone's attacks, the damage busts thru your
shield and immediately knocks you out due to your weakened state.
<li>Fixed people getting ssj1/2/3 without needing the base BP requirement. I think.
<li>Fixed stun chipping of people in tournament.
<li>Thanks to Syraf11 for reporting an item duplication bug, whether I fixed it or not is uncertain.
<li>Disabled NPC pathfinding, it is far too laggy and causes the server's cpu to spike to 100% and crash.
<li>Deleted about 35% of the NPC population.
<li>Many NPCs are now non-aggressive unless you attack first.
<li>New level 4 admin command: toggle_soul_contract_learnable. Makes soul contract self learnable or
by teaching only.
<li>Soul contract is now not self learnable by default. It is by teaching only.
<li>When blast absorb overloads it now has a cooldown before it activates again. Energy mod and recovery
both decrease the cooldown time.
<li>Revive now uses real time instead of years for it's delay. The default delay is 1 hour per revive.
<li>Disabled sacrificing your life to revive someone. It was so annoying when people you just killed alt
abuse back to life within 30 seconds.
<li>Built signs are now bolted by default.
<li>Teaching is now based on real time instead of years.
<li>You can no longer build over another person's turf if their knowledge is too far beyond yours.
<li>Cybernetic bp now increases when your energy goes over 100%. But not as much as natural bp. Going
to 200% energy increases cyber bp 32% whereas natural bp would double.
<li>Scatter shot will not allow you to use it again until all previous scatter shot blasts are gone.
<li>Scatter shots should no longer get stuck on top of their target.
<li>Players can now hold a max of 50 items in their inventory, to prevent save lag.
<li>Players can no longer use their own soul contracts.
<li>Spam killing is now impossible. A person who is killed while dead is now immune to death for 5
minutes. But while immune their available power is severely lowered so that they can not harm anyone
while invincible.
<li>New technology: Ki field generators. Stops anyone from using ki within a certain distance of it.
<li>Androids now have the same intelligence as a human, but half the knowledge
cap rate.
</ul><p>

v11.657<br><ul>
<li>Fixed the bugged Icer ascension.
<li>NPC pathfinding was hogging up the shell's cpu so I made it so an NPC can only pathfind once per
10 seconds instead of 2.5 seconds.
<li>When NPCs are booted by admins they now stay booted thru reboots until admins enable them again.
<li>Nerfed dash attack from 35% base damage to 25% and stacking strength has less affect on it.
<li>New level 4 admin verb: max_Saiyan_percent. Sets the max percent of players that can be Saiyan
before the race disappears from race selection.
<li>Code banned and sticky banned a guy crashing servers repeatedly (Romcio).
</ul><p>

v11.651 (8/17/2012)<br><ul>
<li>Made LSSj weaker. Their form now has 10% more bp than a ssj2 instead of 37.5% more bp. And their
energy drain is now exactly in the middle of a ssj2 and ssj3's drain.
<li>LSSj can no longer go SSj4, ever.
</ul><p>

v11.65 (8/16/2012)<br><ul>
<li>Flying now gives minor stat gain.
<li>Fixed the race guide on modless servers and added knowledge_cap_rate info to it.
<li>Doubled the rate that powering up increases your bp.
<li>Turns out anger has been bugged for a LONG time. It wasn't kicking in when it was supposed to,
instead you just get knocked out every time. It's now fixed thanks to EXGenesis.
<li>Also fixed an unKOable bug related to anger.
<li>Fixed body swapping in safezone.
<li>Fixed the admin verb add-log-note.
<li>Spirit doll now has equal intelligence to a human.
<li>Diversified and altered the intelligence mod of all races.
</ul><p>

v11.641 (8/15/2012)<br><ul>
<li>Code banned some bug abusers that keep ruining the wipes, they will only be unbanned if they
report how to do the bug, otherwise it is a permanent ban.
</ul><p>

v11.64 (8/8/2012)<br><ul>
<li>Fixed the tournament lag and the tournament glitches that let you do disabled stuff in tournament.
</ul><p>

v11.637<br><ul>
<li>Alignment system now toggles off correctly.
<li>Auto attack wasnt working with peebags, which made them completely worthless.
<li>You can now see how much 'untapped potential' you have left to retrain after getting killed
while dead.
<li>You can now go 25 tiles away from the tournament before you are disqualified (was 15).
<li>Fixed the bug where people stack teach prompts to teach things to multiple people at once and bypass
the teach timer (If it's not fixed someone tell me).
</ul><p>

v11.635 (8/6/2012)<br><ul>
<li>Nerfed vampire bp boost from 1.5x to 1.25x and vampire eater boost from 2x to 1.5x.
<li>Nerfed limit breaker bp boost from 2x to 1.5.
<li>Raised limit breaker regeneration boost from 2x to 3x.
<li>Limit breaker now lasts a maximum of 2.5 minutes instead of 3 minutes.
<li>Kaioken, Limit breaker, and custom buffs can no longer be combined in any order.
<li>Shockwave is now unusable during tournaments.
<li>Peebags and Punch Machines and Bounty Computers can now be bolted.
<li>Steroid bp boost has been nerfed from a max of 3x to now 1.7x.
</ul><p>

v11.633 (8/4/2012)<br><ul>
<li>Raised the importance of the offense and defense stats in melee combat since they were the least
valued stats according to my stat_info verb.
<li>Fixed another serious infinite stats bug even more severe and easier to do than the last. To do it:
1) make splitform or simulation 2) brain transplant into it 3) take its dna 4) brain transplant to
real character 5) stat imprint using the dna 6) your stats have now gone up exponentially.
<li>Sims/splitforms no longer have DNA and can not be brain transplanted.
<li>Sacrificial altar in hell now revives you like it was supposed to.
<li>Voting for super saiyan is now off by default and admins can toggle it.
</ul><p>

v11.632<br><ul>
<li>Only 15% of the population must take part in a vote for it to matter now, instead of 30%.
<li>The owner of the tournament can now take a max of 75% instead of 100% of the prize.
<li>When alignment is on, good people can not teach skills to evil people, but evil people
gain SP 15% faster than good people, which is pretty much their only advantage.
</ul><p>

v11.63<br><ul>
<li>Added an admin verb called alt_settings which lets admins set how alts are handled, such as
allowing them, disallowing them, or allowing them only if on seperate computers<br>
<li>Added an optional alignment system that is off by default and right now is just for testing to see
what happens. Basicly during creation you can choose hero/villain alignment, which affects your
character in different ways that you can read about upon choosing it. You can also change your
alignment after creation but it is on a timer<br>
<li>Added level 4 admin verb called max_villains which lets admins set the percentage of evil people
allowed on the server before all evil people start suffering penalties due to their being
too many evil people compared to good people.<br>
<li>2 new admin level 4 verbs: set_melee_power and set_ki_power each one lets the admin set a multiplier
for how much damage melee/ki attacks do on the server<br>
<li>Fixed a bug with omega knockback which when spammed caused the enemy to be frozen the entire fight
making you undefeatable and able to beat people with far more power than you. Now omega knockback
can only be done once per minute.<p>
</ul>

v11.622<br>
New admin lv4 verb: Set_strongest_persons_bp_gain_penalty. Causes the player with the strongest bp
to gain bp slower than other players.<p>

v11.621<br>
New admin lv4 verb: Set_BP_Leeching_Of_Strongest_Person. Causes all players to slowly leech the bp of
the strongest player thru normal training. Meant for servers where players are supposed to catch up
and be viable quickly with little grind.<p>

v11.62<br>
Players who become vampires due to the sacrificial altar can not mutate into vampires monsters, instead
they will die if their hunger reaches 100% the first time<br>
Players can no longer meditate when it is their turn to fight in the tournament<br>
Peebags have been made more useful, they now give 2x stats instead of 1.5x, and instead of strength,
speed, and offense being the only stats they give, they now give all stats, but still PRIMARILY
strength, speed, and offense.<br>
Meditate now gives stats as it was meant to all along but it was bugged.<br>
Added a sacrificial altar in hell where you can make sacrifices in order for things in return.
The only thing you can get right now is a revive and only if you agree to become a vampire. More
options will be added later.<br>
Tripled SP gains<br>
Updated alien precognition. It used to drain a static 5% of your remaining energy each use, but now
energy mod decreases the drain. Precognition will now only activate if deflecting the blast failed and
your shield is down, so that saves even more uneccessary energy drain. It may be actually useful now.<p>

v11.61 (8/1/2012)<br>
The infinite stats bug should now be fixed. To perform the infinite stats bug you would 1) make an
android 2) use robotics tools to open the redo stats menu 3) put all stat points how you want them 4)
with the menu open, train your stats til they cap 5) hit done 6) you now have exceeded the stat cap
and can repeat this as much as you want. Now I just have to fix the infinite resources bug and
possible infinite bp bug that is rumored to exist.<p>

v11.6 (8/1/2012)<br>
Thanks to Toruko I think the "inf stat bug" is fixed. It involved using redo stats on an android
then activating custom buffs during the redo stats. I don't get it exactly but I made it so you can't
activate buffs during redo stats so that should fix it. The people who refused to tell me this bug
will remain permanently banned for not coming forward.<p>

v11.59 (7/29/2012<br>
Fixed prison ray which was going thru walls to send people to prison<br>
Fixed people still being able to attack at tournament when it is not their turn<br>
Fixed Hundred Crack Fist<br>
Fixed death zenkai not using the actual zenkai proc and thus being overpowered<br>
People who try to enter the tournament arena when it is not their turn are teleported back out<br>
Fixed the bug that allowed people outside the tournament to come and kill people at the tournament<br>
A player can now 'own' the tournament and siphon a percent of the prize money each tournament.
A tournament control panel is located near the tournament and if they can keep control of it they own
the tournament. It builds up money each tournament like a drill.<p>

v11.58 (7/29/2012)<br>
Updated nuclear bombs, they are much less laggy, and look and act better<p>

v11.57 (7/27/2012)<br>
Fixed many bp gain unbalances<p>

v11.56 (7/25/2012)<br>
Time chamber is now 10x gains instead of 30x. Still not sure how to fix the problem of people training
in the chamber then letting an alt leech them then training that alt in the time chamber and repeating for
insane power.<br>
dragon balls are 'fixed' now because people were bug abusing them, they can't make you stronger than
the strongest person online.<br>
The advantage of training in decline has been lessened from a max of 2x gains in everything to a max of
1.41x in everything. You reach the max decline gains when your body is at 50% power.<p>

v11.53 (7/6/2012)<br>
You can now only body swap with real players<br>
You can no longer teach or racial fuse while body swapped<br>
Thanks to Doniu body swap resource/item duplication was fixed<p>

v11.52 (7/5/2012)<br>
Fixed gravity prompt stacking<p>

v11.51 (7/5/2012)<br>
I think the endless tournament bug is really fixed now<br>
Fixed an infinite bp bug thanks to Doniu, where you imprint your bp on a zombie, then inject it with
t virus, then imprint its bp back on yourself<br>
Body swap also fixed<br>
Fixed a fruit bug that was letting people get ridiculous BP and ssj in like 12 hours on slow gains<p>

v11.5 (7/5/2012)<br>
Fixed 5+ bugs thanks to ExGenesis<br>
Beams were terrible now they are twice as strong<br>
Beam stats were refigured, use Examine on them to see the changes<br>
Energy mod now causes more blasts to be fired from scatter shot and makosen<p>

v11.49 (6/21/2012)<br>
More DDOS protection thanks to ExGenesis<p>

v11.48 (5/30/2012)<br>
Fixed a security problem allowing anyone who knows how to bring down any server<p>

v11.47 (5/25/2012)<br>
Fixed a bug with weights causing infinite strength<p>

v11.46 (5/22/2012)<br>
All weights no longer divide your available bp by 2 but instead how much it is divided depends how
heavy the weights are to your character. The max division is still 2.<br>
Cyber BP has been overall nerfed. lv1 upgrades now use 70% of your knowledge instead of 80%, and lv2
upgrades use 105% instead of 160%<br>
Added an admin lv4 verb to change the 'cyber bp modifier' of the server<br>
Weights can now be upgraded to different amounts of weight which will have different impacts on your
gains<br>
When wearing weights your displayed bp mod in the stats tab will change to reflect how much the weight is
benefitting you<br>
Materialize now has different tiers which can be reached by putting more skill points into it<br>
Speed seemed not useful enough so I made it slightly increase your accuracy/dodging/deflection(of blasts).
Offense and BP has a greater effect on those than speed does. In order from greatest effect to least is
offense/bp/speed.<br>
Fixed all npcs including splitforms dying in 1 hit for no reason<br>
Elite and Legendary Saiyan now have different predefined stats than regular Saiyan<br>
Fixed ultra pack not guaranteeing Icer race<p>

v11.44<br>
The ability to choose your age during creation is disabled by default only admins can turn it on<br>
Nerfed power control by increasing the drain exponentially the higher you power up. High recovery
combined with high energy was creating a sort of squared effect making PC users far too powerful compared
to anyone else.<br>
Lowered overall game damage to make fights last longer<br>
Absorb can now kill death regenerators if the person absorbing is far enough past the BP of their victim<br>
Alts no longer count toward the voting population, where it says 'at least 30% of the population must vote'
for a vote to pass.<p>

v11.438<br>
Nerfed majin (the buff not the race) and limit breaker.<p>

v11.437 (5/12/2012)<br>
Didn't log most of the changes this time.<br>
People with dragon balls can no longer be safe in a safe zone<p>

v11.431 (5/11/2012)<br>
You now recover energy again while using shield but only at 1/5th the normal rate<br>
Fixed a bug with dash attack where you click the other side of someone as much as you can before your
character actually reaches them and it could kill people 999% your power in 1 second<br>
Fixed genocide attack timing out before reaching the target<br>
Fixed combo teleporting<br>
If a person has not been attacked in over 2 minutes they will become calm.<br>
Rebalanced all the game's sounds to be less annoying<p>

v11.43<br>
The first buff attribute has been completed and can be learned and added to any buff you create.
Aliens can now choose alien transform which is just a custom buff with transform attribute which
would normally cost 40 sp<br>
Restructured the melee attacking code because it was terrible. There may be bugs to iron out but
foundationally it is an improvement.<br>
You can no longer recover energy with ki shield on<br>
Energy swords now do 85% normal damage instead of 50%<br>
Energy swords get 70% of their damage from your strength and 30% from your force, basicly how hard
your swinging the sword matters twice as much as your force that is channeled into the sword<br>
Space pods/ships now take gradual damage like normal instead of being indestructable if you are less
than their BP<br>
Grabbing other players from inside a spacepod is now fixed<br>
Fixed an INF knowledge bug involving DNA<p>

v11.42 (5/10/2012)<br>
Dying while dead lowers a person's 'available potential'. This means their available bp will be lowered
til they train it back up. It trains back up fast especially if you use a training method with high bp
gains. You do not lose any BASE BP. Do not misunderstand how this works and bitch about it to me. It is
for when 2 dead people are fighting, and the loser who re-dies doesn't instantly come back with the same
amount of power to attack you again.<br>
Fixed knockbacks<p>

v11.41<br>
The effect of eating fruit from the make fruit ability now decreases much more with each additional
fruit after the first one you eat.<br>
The effect of wishing for power decreases drasticly every time you use it.<br>
My new official key for this game is 'Tens of DU'<p>

v11.407<br>
Movement delay system was broken. Fixed it.<p>

v11.406 (5/9/2012)<br>
Reincarnation no longer deletes all your skills<br>
Legendary can not transform until it is year 15+<br>
When a Legendary has enough BP they can transform without death anger by just powering up<br>
Lessened the overall move delay that was recently added, since it was too slow.<br>
Self destruct can now only be used once per 2 minutes<br>
Fixed Icer ascension because it actually was bugged<br>
Nerfed Icer forms a bit.<p>

v11.405<br>
Doing a forced brain transplant on someone to steal their character now cost 10b resources because
people were just running around wiping each others characters easily and for free.<p>

v11.404<br>
Spirit doll was made less sucky<br>
Gravity mastery now has a bigger impact on bp gains.<br>
Makyo star is now out 3 months of the year instead of 2<p>

v11.403<br>
Removed fart storm<br>
The Super Saiyan boost was calculated wrong and was giving too much, it now works how it was originally
intended.<br>
Your base bp now needs to be at least 1/3rd of your OY1 bp requirement, 1/4th of your OY2 requirement,
and 1/8th of your OY3 requirement, even if you have the current bp for the requirement. This is to
prevent abuse where people stack buffs/energy/etc to multiply their bp so high that they can get any
OY form<p>

v11.402 (5/8/2012)<br>
Ki shield can now have change icon used on it to change your shield icon<br>
Ki shield was apparently useless so I made it much better and it will now also block melee attacks.
Tip: The better your energy mod the less drain you will experience from shield.<br>
A Saiyan's base bp now needs to be at least 1/3rd of the amount needed to go ssj before the game will
allow them to go ssj even if the Saiyan has all the current bp needed<br>
The bp requirement for lv1 Super Saiyan has been greatly lowered because it seems that by the time Saiyan
are able to unlock the form it is already too late because races like icers/etc have already
gotten so powerful that the form is no longer useful starting out<br>
Kids born from mating no longer start with 100% of their parent's bp available to them. They still
inherit all their parent's base bp but only a certain amount of that potential is available to them
until they fully unlock 100% potential by training. Kids from normal mating are born at 1% available
potential and from eggs they are born at 50% available potential. Potential quickly rises to 100% by
training.<p>
Raised default wall bp from 8x knowledge to 12x knowledge because it is so easy to break them<br>
Telewatches can now be set to have dna verification and will self destruct if the user's dna does
not pass verification<br>
Telewatches can now not only teleport to telepads but they can also teleport to your comrades who have
telewatches with matching codes<br>
Increased the rarity of custom buffs by increasing the sp cost and teach timer<p>

v11.4<br>
Fixed the bug with dragon balls where people stack hundreds of wish prompts to get 100s of power wishes
from just 1 gathering of the dragon ba...*cough* dragon balls.<br>
Zenkai from tournaments is 1/5th of a normal zenkai<br>
Leeching someone now takes longer.<br>
Nerfed zenkai effectiveness by half because I'm told by numerous people that too much of a person's
BP comes from zenkai, even on non-Saiyan<br>
Tsujin now gain knowledge faster than humans but their cap is the same. They just hit the cap faster.
Aliens now reach the knowledge cap the fastest of all races. Tech pack increases how fast you reach
the cap by double<br>
People who put all their stats in force have been nerfed because
nobody should be able so strong with all their power focused into just force, melee people need at
least 4 stats to be effective. I did this by changing the damage formulas of attacks that ki whores use
which rely solely on force and nothing else (beams, shockwave, explosions, self destruct)
Appearance of deflecting homing blasts has been improved since they now stop homing once deflected<br>
Boosted scatter shot from 5 to 8 damage<br>
Spin blast has been improved to do 25% more damage and fire 2 blasts at once<br>
Clones now have very low decline and lifespans due to imperfect DNA replication<br>
Icer has been made a rare race that only appears if less than 10% of players online are Icers<p>

v11.3 (5/7/2012)<br>
Added league promotions<br>
Ultra pack now allows for choosing Icer even if more than 10% have it online.<br>
Fixed the bug where putting a buff's bp mult to 2 locks it from being changed<p>

The x2 bp/ki/stat/sp/mastery/leeching gains from being in decline now work differently. before,
being just 1 month past decline immediately gave you the x2 gains, even tho you were essentially still
at 99.9% power or so. Now, it is a gradual progression, if decline has divided your available bp by 2,
then your gains are x2, if divided by 1.5, gains times 1.5. If divided by 1.1, gains times 1.1. And so
on in smooth progression. x2 gains are acheived when you are at 50% or less power from decline. It will
not go past x2.<p>

(5/6/2012)<br>
Speed stat now affects how fast you move again<br>
Added league chat<br>
level 4 admins can now set the max gravity of a server, which decides how high a gravity machine can be
upgraded<p>

Changed reincarnation entirely. No longer do you lose anything, but your available power is lowered to
1%, like being powered down. Basicly most of your potential is hidden after reincarnating. As you
train the % of your potential available to you will rise til it reaches 100%. On default settings
it takes 10 minutes to reach 100% BP again thru sparring, slower thru other methods. Basicly,
being reincarnated no longer hurts your training any more because you don't lose real power it is
just that your power is hidden til your 'new character' learns to unlock it<br>
Changed the bp gaining formula. It was sort of bugged. That is why changing bp gains with the gain verb
for admins had so little effect.<p>

Demons and Kais no longer start with revive<br>
The whole concept of death has been re-imagined somewhat. Being dead is not so bad now. The main reason
to kill someone is to send them 'out of commission' so they are no longer a threat to you and no longer
in the living world right? Not as a punishment to them, but as a benefit to their killer. The killer wants
them out of commission as long as possible and the person who died wants it to not be such a punishment.
That is why I made it harder to come back to life, and made it harder to leave the afterlife, but at the
same time death now has perks. Dead people are now at 30% BP instead of 10%, they
are knocked out only half as long, heal and recover 20% faster, master skills 50% faster, can not
suffocate in space, and can not be poisoned. No teleport ability will work for a dead person except for
shunkan ido and that is only if they also have had 'keep body' used on them. The living world and afterlife
are now more seperated than they have been for a very long time.<br>
Removed the cave from hell to icer<br>
There is a new detailed guide website for this game under construction. You can find the link to it by
pressing P<p>

(5/5/2012)<br>
Poisoning an android is now impossible<br>
Nerfed 'absorbing to come back to life' by requiring your victim to be at least 75% of your base bp
instead of 20%, so if a fight is to come back to life it will have some challenge to it<br>
Made DNA stuff far more rare by raising the prices of them dramaticly<br>
Because most players are too dependant on safezones (70% of players stay in SZ 24/7) I have lowered
bp/ki/stat gains in safezones to 1/4th of what they are outside a safezone<br>
To prevent people with 10k bp stacking buffs til they have enough BP to go Super Saiyan, the game now
requires that your base bp be at least 25% of the required bp for Super Saiyan<br>
Fixed a dozens of runtime errors<p>

(5/4/2012)<br>
You can now send resources to fellow league members instantly<br>
In Customize you can now ignore soul contract and league invites<br>
Fixed many bp/stat/resource exploit bugs thanks to Doniu reporting them<p>

(5/3/2012)<br>
Added a simple 'league' creation system which may be improved later. use the Form League verb.<br>
Added a new lv4 admin verb called death_settings which has the default mode and a new mode where nobody
actually goes to the afterlife, but is just reborn with a power loss. Meaning there are no dead people
with halos running around so afterlife ceases to have any role in the game. This is mainly for my
server.<br>
Decreased android zenkai from 0.5 to 0.1 and increased android SP gain from a terrible 0.8 to now 1<br>
Androids can no longer have their potential unlocked<br>
Demons no longer start with soul contract, only the Daimao rank does.<br>
Due to soul contract being so overused that it is ruining the game experience I made it cost much more SP
and have a far longer teach timer between teachings to prevent the spread and keep it rare.<br>
More cpu optimizations<p>

(5/2/2012) CPU optimizations<p>


(3/16/2012)<br>
Fixed a bug with guns allowing for infinite ammo/precision/possibly more.<br>
Immortality now properly prevents death from old age<br>
I think I fixed what was causing the tournament to become bugged<br>
Zenkai is now triggered from ki attacks as intended<br>
Limited a buff's max bp boost to 2x because 7x is just too extreme in many cases. People could only hold
the boost for like 2 seconds but during that time they could bust any walls or kill someone with piercer<br>
There is now a 'hide energy' ability that will hide you from people's sense/observe/teleports/etc. While
using it your available bp will be very low. Getting this skill from learn will be costly, but certain
ranks, mostly earth/Namek ones, have it to teach.<p>

(3/14/2012)<br>
I put a limit on server settings (bp gain, sp gain, mass revive timer, etc) so that hosts can't set them to
ridiculous levels making the game look stupid. The most popular server as of writing this has 100x gains
in just about everything and mass revives every 1 minute. How dumb is that? Well I'm not letting it
happen. It's stupid that people pushed a server with settings like that to be the most popular in the
first place.<br>
Vampires have had their max bp boost lowered from +100% to +50% and vampire monsters from +200% to +100%<br>
Fixed a game ruining bug involving buffs and racial fusion that could get a person to have infinite
stats/bp/energy. It ruined dozens of wipes on my server (and others I'm sure) before I was finally
told how to do it.<p>

(2/27/2012)<br>
Removed the ruin code and am never putting it back in<p>

(2/16/2012)<br>
Level 4 admins now have a Set Reincarnation Loss verb which lets them set how much power is lost from
reincarnation. The default is that the person will retain 80% of their BP/stats/ki when they
reincarnate.<p>

(2/14/2012)<br>
The infinite resources bug wasn't fixed. I have made another attempt to fix it. It seems fixed now.<p>

(2/11/2012)<br>
OK. The INF BP bug was finally fixed (hopefully it is the only one), it had to do with learning third
eye, using it, forgetting it, then repeating. Each time you would get 1.3x bp and x2 meditation bp gains.
The INF ENERGY bug is also supposedly fixed since it was from reincarnation supposedly, and reincarnation
is now replaced with a much simpler version til it can be fixed (I couldn't recreate the bug to fix it).
The INF RESOURCES bug was also fixed it was done with 2 people, 1 gets in a spacepod the other grabs
a very expensive drill and soul contract teleports the drill to the person inside the spacepod, then
they blueprint the spacepod and duplicate it then destroy the spacepods and double their resources each
time. This still does not explain the INF STATS bugs, which likely will continue to ruin wipes.<p>

(2/10/2012)<br>
Dash Attack could be made to be severely overpowered by people who put all their stats into strength, then
use Dash Attack as their only move. So now, dash attack can be dodged, having better offense decreases the
chance of it being dodged, it is still highly accurate as far as most moves go. Speed will determine
the velocity at which you reach your target using dash attack.<br>
Clones will no longer have the same SP as the original<br>
Due to reincarnate being so buggy and in need of being recoded I have replaced it with a much simpler
version that does not allow you to choose a different race and actually make a new character, but instead
simply revives you and respawns you at a slight power loss<br>
Fixed a bug where people blueprint a genetics computer, spawn it on top of a door, make a clone, brain
transplant into the clone, grab their body, and walk right in the door.<br>
Clones will no longer have any soul contracts from the original character<br>
Names can no longer be URLS<br>
Fixed a bug that allowed a person to double their resources each time by using Body Swap combined
with cloning<br>
Fixed a bug that allowed a person to create guns with as high of damage as they want<p>

(2/9/2012)<br>
Fixed a bug with buffs that allowed a person to have infinite stats<br>
All you have to do to upgrade and make dense someone's walls at once is to get next to the wall and then
left click it. Super easy.<p>

(2/8/2012)<br>
Only earth, Namek, Vegeta, arconia, and icer can have dragon balls made on them now<br>
A system to ban hosts or allow specific hosts only was added. Thanks to ExGenesis<p>

(2/7/2012)<br>
Fixed the shockwave bug where someone grabs you then shockwaves the crap out of you doing huge damage
while your stuck being grabbed<br>
To use a teleport watch you must stand still the more you move the more time is added before it can lock
on and teleport you<br>
The benefit of giving power drops off more severely as the person recieving the energy goes past 100%
energy, because previously people were reaching 500%+ energy/bp/health just from simply 1 person
giving them power. That should take like 3 people at least to reach 5x bp.<p>

(2/6/2012)<br>
Using Absorb abilities will grant you some knowledge if the person was more intelligent than you<br>
Body swap can no longer be used on people in a safezone<br>
Cyborgs now gain BP at 25% the normal rate and do not leech at all<br>
Made it so all a person's anger isn't channeled just into BP because a Saiyan can make 10x anger and
get SSj1+2+3 at the same time every time. Now instead of being a huge BP boost, anger increases BP
and causes you to rapidly recover lost health and energy.<br>
You can now exit a ship just by walking into the controls<br>
Beams will no longer push people out of safezones<p>

(2/4/2012)<br>
When a bounty head is sent to prison the prison takes their resources and adds it to the prison's
money, which it will use to occasionally increase the bounty amount placed by players to make hunting
more worthwhile.<br>
Space Prison will now send automated drones to observe bounty heads. These drones have the ability to
teleport bounty hunters to the bounty head's location. The drones can not get to you on built turf.<br>
To teleport directly to a bounty head you view their bounty on the bounty computer, and if a drone
is nearby them that can teleport you, it will ask if you want to teleport.<p>

(2/3/2012)<br>
There is now an 'Im Trapped' verb in Other tab that can be used hourly to send you to your spawn if
you get trapped by turrets or something.<br>
Added an Interdimensional Space Prison! When you place bounties on someone, instead of them dying like
normal when you hunt them, they are teleported to the high tech space prison for containment until their
sentence expires.<p>

(2/2/2012)<br>
Custom Buff now have actual verbs instead of having to click them in a tab<br>
The Buff Options verb to change the buff is in the Other tab<br>
Optimized 2 big sources of lag: Activate_NPCs and Turret_Loop<p>

(2/1/2012)<br>
You can now set the refire of your rapid blasts. The slower the more powerful<br>
You can now 'bind' to a spawn by getting next to it and clicking it.<p>

(1/31/2012)<br>
New admin verb Set Max Zombies sets the max zombies that can exist at once<br>
There is now a Set Max Players verb for admins to set a max amount of players on the server<br>
Getting to the Final Realm thru any sort of teleport ability should now be impossible<br>
Training of any kind in the Final Realm is now useless<p>

(1/29/2012)<br>
While in a safezone, bp/ki/stat gains are halved<br>
People who are inactive for more than 30 seconds after their tournament match has begun are
disqualified<p>

(1/27/2012)<br>
You can now make your own custom 'opening transformation graphics' for buffs and Super Saiyan!<br>
Public hosting is back temporarily<br>
The preset buffs expand, focus, and giant are removed because they will be soon recreatable as custom
buffs, and I can't have them stacking with the custom buffs creating balance problems.<p>

(1/24/2012)<br>
Added in a buff creation system. See 'learn'.<br>
Taiyoken now has a 'tell' before it goes off, and if you face away in time, you will not be blinded.
You have 1.2 seconds to face away<br>
Genetics Computers can now imprint knowledge from DNA<br>
Sense lv3 can now sense knowledge<br>
When teaching knowledge of technology, the teacher can now choose a percentage of their knowledge to
teach<br>
Player's bp gains are accelerated by a sort of bp catch-up system, until they reach the average base bp.
The catch-up gains diminish the closer you get to the average.<br>
It now takes an average of 10 hits to blast someone's tail off instead of 1<br>
Using an artificial moon will grow your tail back<br>
Splitforms will now automatically attack the same target your attacking<br>

(1/21/2012)<br>
Aliens who choose the transform ability will lose some ascension power<br>
New icons given by Exgenesis<br>
Exgenesis now decides who can or cannot host on the hub.<p>

(1/13/2012) Aliens can now have transformations thanks to ExGenesis. Right now it can only be given by admins because
it needs to be tested still to find possible problems.<p>

(12/29/2011) Fixed a bug with focus reverting multiple times and ruining characters.<p>

(12/26/2011) Added 3 new packs, which are melee, ki, and intelligence themed.<p>

(12/1/2011) Fixed a bug that allows Unlock Potential to be spammed for insane power<p>

(11/30/2011) Fixed a way to bug abuse for BP by spamming absorb in safezone<p>

(11/29/2011) Fixed a form of BP bug abuse using dragon balls<p>

(11/21/2011)<br>
Every character now has personal upgrade caps instead of being reliant on the global average BP. You raise your
character's knowledge of technology by having the science tab open, and if the global upgrade cap goes higher than
your personal upgrade cap, your personal upgrade cap will start to rise slowly. This does not work if your afk more
than 5 minutes<br>
Knowledge of Technology can now be taught.<br>
Made an option for Admin 4s to make it so any Saiyan can go Omega from death anger instead of just the first Omega
Saiyan<p>

(11/13/2011)<br>
Admin 4s can now alter how fast Super Saiyan is mastered for the server<br>
Hokuto Shinken no longer works on people in safezones<p>

(11/12/2011)<br>
When a drill is destroyed some of the resources used to make it will be dropped by the drill<br>
Deadzone no longer affects people in a safezone<br>
Teleporting people out of safezone is fixed<br>
Absorbing in tournaments is fixed<br>
Dead Zone can no longer be opened inside a person's house from outside the walls<br>
Admin 4s now have verbs to change the server's health regeneration and energy recovery rates<br>
People who spend more than 2 years in the time chamber will have no further benefits<p>

(11/9/2011)<br>
Made it so people who are auto ranked can remake freely<br>
Radars are now fixed<p>

(11/8/2011)<br>
The revive ability can now be used more than the timer allows if the reviver sacrifices their own life<br>
dragon balls now scatter as soon as they are created<br>
By clicking a spawn while next to it you can bind to that spawn and respawn there instead of your racial spawn.<br>
Admin 4s now have a Change KO Time verb which lets them modify how long KO Time for the server is<br>
Auto attack now only works on mobs because it was annoying when it is accidently left on and it destroys valuables
such as gravity machines or dropped resources.<br>
When a person dies they now keep 10% of their resources<p>

(11/6/2011)<br>
Wall strength now has a modifier that admins can set<br>
Votes are now ignored by default<p>

(11/5/2011)<br>
Safezone distance can now be altered by admins<br>
When perma death is on no longer does it delete your character, instead you are automatically reincarnated with a \
large stat loss<p>

(11/4/2011)<br>
Turrets can now not be built within 40 tiles of a spawn<p>

(11/3/2011)<br>
Turrets and DNA Containers are now disabled in tournaments<br>
NPCs can now be killed/etc in safezones<br>
Nobody can be knockbacked in safezones now<br>
Admin 4s can now turn on auto ranking which will give out a rank to the appropriate race if that rank has not yet
been given.<br>
A new melee finishing move called Dash Attack was added. It requires Zanzoken.<p>

(11/2/2011)<br>
People in caves belonging to the same planet can now be sensed<br>
A person can now have their potential unlocked every 5 years instead of just once<p>

(11/1/2011)<br>
Wishing for power on dragon balls hardly did anything, now it should.<br>
Fixed a bug with dragon balls disappearing because people give them to NPCs and when the NPC deletes so do the
Spheres. All dragon balls will now have to be remade.<br>
Blast Homing is improved because it will no longer deviate from its path if it detects there is a target straight
ahead<br>
Soul Contract bugs are now fixed because the soul contract is now bound to the soul's key not Mob_ID<br>
Ships and pods now have a Move Randomly option which will cause them to move around randomly til you stop it<br>
Fixed regenerator's heal injuries upgrade option<br>
Ship computers now tell you how long it has been since someone last entered the ship<br>
Every cave is now diggable based on the planet it belongs to<br>
Radars can now detect cave entrances<br>
Taiyoken duration was shortened to 20 seconds divided by the square root of the victim's regeneration<br>
Fixed a bug where Super Saiyan would be kept after reincarnating into a non Saiyan<br>
To prevent spam building, each tile now cost 1000 resources to build, instead of appearing from nothing.<br>
Build tab does not appear by default, you must turn it on in the customize button. This is to prevent spam builders
who don't know what they're doing.<p>

(10/29/2011)<br>
Fixed a bug that allowed people to make the tech cap go to infinite<p>

(10/24/2011)<br>
Players can now rate a server as good or bad in the Voting verb and that rating will show on the hub. Individual
ratings expire after 4 days.<br>
Went back to public hosting due to player vote<p>

(10/21/2011)<br>
Fixed a bug with modless stat mode<br>
Public hosting is now gone due to a player vote<p>

(10/18/2011)<br>
Auto alt leeching is disabled I don't remember why it exists anyway<br>
Made it so that any item/buff that changes stat mods can not be used while redoing stats to prevent bug abuse, thanks
to RyuShinto<br>
Fixed a bug where people stacked swords and armor thanks to Mint Condition<br>
Slowed down leeching of BP<p>

(10/17/2011)<br>
Alien skills are now chosen last to prevent a form of bug abuse.<br>
Demons and Kais are now immune to Zombie Infection.<br>
Made it so important ranks can not remake<br>
Updated the Game Rules. All servers have til the 18th to fix rules that defy the Game Rules.<br>
Fixed an infinite money and infinite gravity bug thanks to Freemen<p>

(10/16/2011)<br>
Added 'Game Rules' which governs the entire game and over-rules any host made rules that defy it. It can be
viewed with the Game Rules verb in the Other tab. Any host who defies it will be ruined.<br>
Added new ruin code that will hopefully prevent it from being found out so easily.<p>

(10/15/2011)<br>
Only v3 servers or better will show on the hub<br>
Disabled ruin since I can't figure out how to stop people from figuring out the ruin code.<br>
Servers with less than 10 players are hidden from the hub<p>

(10/13/2011)<br>
Weights were very ineffective so I improved the BP gains from them. Previously without weights I went from 10k to
12.3k, and with them only from 10k to 13.4k.<p>

(10/12/2011)<br>
Dying from old age was bugged making everyone immortal. Fixed.<br>
I set the power up noise to 10% volume because someone said it was too loud.<br>
Admins can now start deathmatch tournaments for some reason<br>
Androids will no longer sometimes be born Vampires because it makes no sense.<br>
When stats are set to "No cap" or "Modless" modes, Adaptation (leech_rate var) now gives a small boost to a player's
stat catchup gains (not base stat gains, those stay the same for all races). Stat catchup gains are multiplied by
(leech_rate**0.25). A human has adaptation of 3, so thats x1.31 stat catchup gains compared to a Saiyan's 1x. This does
not mean they have faster stat gains, it is just the catchup stat gains, which run out pretty fast.<br>
Updated the forum to be used with this game. The forum is completely empty now.<p>

(10/10/2011)<br>
Made it so gravity can not be mastered in safe zones (If there are any) because they can go endlessly without
damage otherwise.<br>
Reset the version to 0 for no real reason.<br>
Whisper, Say, and Emote code was redone because it was surprisingly long and redundant compared to what it should be.
It was also very old code.<p>

(10/7/2011)<br>
Entries in admin logs more than 4 days old are removed automatically.<br>
Added a verb for Level 4 Admins to enable or disable safezones within a certain distance of spawn points. It is off
by default.<br>
There is a new stat mode called "Modless Mode", it's too complex to explain. Level 4 Admins can set it.<br>
BP now has more influence than it did before (Player Voted)<br>
The Teach verb is now more user friendly and categorizes skills into skills you can teach, cant teach yet, and skills the
learner already has.<p>

(9/28/2011)<br>
Zenkai has been revamped. There is no waiting period between Zenkais, but the more often you use your Zenkai the
less you will get each time. It will refill back to maximum over time.<br>
There is now a Race_Guide verb which tells you detailed stat information on every race.<p>

(9/27/2011)<br>
All blasts are slightly homing now as long as the target is roughly in front of them<br>
Modify_Tournament_Prize verb for level 4 admins<p>

(9/24/2011)<br>
Pixel Moving can now be turned on and off by admins. The feature is incomplete and is unappealing currently.<p>

(9/23/2011)<br>
Drones can now be set to kill Vampires and Zombies<br>
Genetics computers can now use DNA to imprint 70% of someone's battle power onto another person, similar to how
stat imprinting already works.<br>
BP gains for new characters are accelerated until their BP reaches 10% of the server's average BP<br>
Forget Skill verb allows you to forget a skill you self-learned to get back 90% of the skill points from it<br>
Android intelligence is raised to 0.8x<br>
New technology: Intelligence Booster<p>

(9/21/2011)<br>
Races are now sorted by popularity in character creation. By popularity, I mean the races with the most online appear
at the top.<br>
T Virus serums can now be directly synthesized by right click an Antivirus. This is much more expensive than the
other way, which involves taking DNA directly from Zombies, but also less dangerous.<br>
The effects of steroids have been changed<p>

(9/18/2011)<br>
Fixed Injure and Time Freeze<p>

(9/13/2011)<br>
Alts will slowly leech each other automatically. So by logging on as many as possible you avoid having to train
all of them, you can just train 1 and the others will slowly catch up by just being logged on.<p>

(9/9/2011)<br>
New Ki attack: Buster Barrage<p>

(9/6/2011)<br>
Level 4 Admins can now adjust the Base Stat Gain (the verb has the same name)<br>
Enemy AI was recoded and should be improved dramatically.<br>
All human icons were replaced with better ones thanks to ExGenesis.<p>

(9/4/2011)<br>
Vote timer extended from a 1 to a 3 hour wait.<br>
Admin3 'Lag' verb was replaced with the FPS verb to set the frames per second of the server.<p>

(9/2/2011)<br>
Train and Learn verb can be disabled by admin (Voted)<br>
Namek bp mod was raised from 1.8x to 2x (Voted)<br>
Half-Saiyan bp mod was raised from 2x to 2.5x (Voted)<p>

(8/29/2011)<br>
Added an lv4 admin verb called Minimum Starting BP which lets them choose the minimum bp a new character will
start at.<p>

(7/29/2011)<br>
A mass pay system was put into the game which allows players to get money just for playing the game, if they
register their paypal using the Register Paypal verb in the 'Other' tab. You must have a paypal to get paid.
Servers with less than 20 players will not be included in the payments to prevent abuse.<p>

(7/24/2011)<br>
oozaru form was changed from 10x bp to 3x<br>
Vampire Eater was changed from 4x bp to 3x<p>

(7/15/2011)<br>
Fixed a bug with all manner of force fields and shields, they were unbeatable due to this bug.<br>
Give Power is revamped<p>

(7/14/2011)<br>
After 3000 x Ki Mod energy, ki gains are slowed to 1/10th<br>
Distance indicators can now go beyond 127<br>
Radars are now a seperate object from Scouters<br>
Nav Systems now have autopilot<br>
Building in space is disabled (Player Voted)<p>

(7/13/2011)<br>
Children of Vampires are now also Vampires<br>
You can now mate with other players<br>
People on destroyed planet's are now automatically sent to space<p>

(7/12/2011)<br>
New Technology: Door Hacker, it can bypass the password on doors if it is more upgraded than the door.<br>
Absorb, Self Destruct, Hokuto Shinken, and Shockwave are disabled in Tournaments<br>
Icer form bp boost has been reduced. (Player Voted)<br>
Icer form recovery boost has been reduced. (Player Voted)<p>

(7/11/2011)<br>
Guns now attempt to auto reload when they reach 0 ammo<br>
Relying on force fields in battle halves your adaptation (leech gains) because your not using your own
skills/energy/power in the fight so it isn't training you as much. (Player Voted)<br>
Makyo Star now comes out once per year instead of per 10 years. It comes out for 1 month.<br>
Critical hits have been added to melee, defense is the primary way of avoiding them. This was added to make
defense more valuable because players think it is mostly useless.<br>
You can now mate every month (Player Voted)<br>
The first SSj can only be given by admin or player vote. After the first SSj is made, others can go SSj by
being around another SSj, which motivates them to eventually get SSj, or by getting enraged at the death of
someone. But you still need the BP.<br>
Level 4 Admins can now set how often auto tournaments occur or disable them.<br>
BP from cybernetic upgrades was reduced 60% because almost every time it makes you the strongest online.<br>
Fixed a bug where beams are always lethal<p>

(7/10/2011)<br>
Automated Tournaments every 30 minutes or admin triggered!<br>
Level 4 Admins have a verb called Perma Death Toggle which allows them to turn on/off if a player who dies
when dead, has their character deleted. (Player Voted)<p>

(7/9/2011)<br>
Half Saiyan BP Mod was lowered from 3 to 2 because admins keep disabling them for being overpowered<br>
Demigod race<p>

(7/8/2011)<br>
Gun's spread firing mode was improved.<br>
Being KO in gravity no longer slows your mastery, but you will not gain stats from it.<br>
Blueprints can now blueprint ANYTHING made with science<br>
Blank android bodies are now made using Cybernetics Computers<br>
Spirit Dolls now have half intelligence, less adaptation, but more meditation BP gain, to make up for the fact
that they were superior to Humans in every way due to having infinite flight.<p>

(7/7/2011)<br>
Up to 50% of a person's ki is now leechable due to player vote<br>
Injure verb now works again<br>
More soul contract options<br>
You can now click a Sim Fighter and they will disappear.<br>
Level 4 Admins have a 'Ki Gains' verb to set the server's energy gain.<br>
If a player makes a spawn point for Half Saiyan, the race will be choosable.<br>
The person who bolted an object can now unbolt it.<br>
Gravity's BP gain boost was lessened, 500x gravity was 500x bp gain, now it is roughly 22x<br>
If a person is has been cured of vampirism, this trait passes down to their children and they will also
be immune to the vampire virus.<br>
Soul Contracts are now able to give/take years of life from the soul, extending/reducing your own lifespan.<br>
Demons can now eat rotten dead bodies without getting poisoned<p>

(7/5/2011)<br>
Level 4 Admins now have an Illegal Races verb which enables/disables races.<br>
Characters with 2+ force start with meditate level 2 and double energy.<br>
You can now build after your character is just 2 months old instead of 1 year old.<br>
You can now choose your starting age during character creation, for instance if you wanted to start in decline<br>
Majins now master skills 5x faster and probably the fastest of all races.<br>
Description verb is now called Examine.<br>
Each time a Kienzan slices thru something its damage is decreased.<br>
When Namek use Heal it will drain only half the energy it does for other races who use it.<br>
For 5 billion resources players can now create spawn points for any race<br>
Level 4 Admins can now disable ki attacks for the server, which would be good for a 'guns only' mode<br>
Level 4 Admins can now cap BP for the server with the Cap BP verb<br>
The Level 5 Admin verb 'Objects' is now Level 1<br>
Turrets now attack and kill NPCs, this would be good against zombies.<br>
Projectiles are now lethal to any non-player even if the player has ki set to non-lethal<p>

(7/4/2011)<br>
Demons now start with the ability to offer 'soul contracts' to people in exchange for their souls, which
gives them certain powers over that soul.<p>

(6/23/2011)<br>
Regenerators will not bust in <25x gravity now, so any planet can have them.<p>

(6/22/2011)<br>
A 'Server Info' verb that shows some stats related to server settings<br>
Level 4 Admins now have a verb which lets them alter how much resources planet's get<br>
Scrap Absorb is fixed<br>
Absorbing a living person under certain conditions can bring you back to life<br>
Mastering fly is now 3x easier. It was way too hard before.<p>

(6/20/2011)<br>
Stat gain is now more 'even' instead of new characters gaining stats in huge chunks. This is accomplished by
capping stat gain per tick to no more than +1%. So no more jumping from 1 to 250 in a stat instantly.<p>

(4/19/2011)<br>
You can right click your resource bag and click Show Resources to show everyone around you how much resources you
have.<br>
You can now unlock your own potential.<br>
Players can now vote to have someone banned as long as 70% are in favor. Admin 4's can disable this using the
Allow Ban Votes verb.<br>
Level 4 Admins have a verb called SP Multiplier which multiplies SP gain across the server.<p>
"}
var/Event_Guide={"<html>
<head><body>
<body bgcolor="#000000"><font size=3><font color="#CCCCCC">

This guide is for Admins who are Event Masters.<p>

If you overcomplicate an event it will just fade out and nothing will ever happen. There is only a certain
amount of things you can realistically do without having an impossible amount of things to keep track of.
This is how I suggest doing events.<p>

There are two sides to a typical event, good and evil. Keeping track of more than 2 sides has in the past
always proven a bad idea and the event goes nowhere.<p>

On each side there are two figures to keep track of. Do not keep track of anyone else, it will prove too
much effort and the event will fail. Here are their definitions:<p>

Main Hero: This is the head figure of the good side. There is only one at a time and it is always a
player. Ranks cannot be the MH, their purpose is to help the MH and his allies in a support role. MH is
not a title, it is not a rank, it is not a static position of any kind. It is like a spotlight, it shines on whoever is
doing best out of everyone else. One player may have the spotlight shining on him at one time, but as soon as someone comes
along who deserves it more, the spotlight will shine on the new person. This also means if the person who has the spotlight
on them stops acting deserving of it and stops being heroic, the spotlight leaves them, because they are no longer worthy
of it. Admins do not make heroes, heroes make themselves. The spotlight just shines on the best hero of the moment.
This is not something players who expect things to be given to them, or expect to be given "permission" to do things,
will ever have. Only someone who really understands the IC universe around them and the impact they and others have within
it can follow the path of the hero without tripping and become the Main Hero. It has nothing to do with power, that
can easily be fixed with boosts.<p>

Event Villain: This is the character that drives the entire evil side of the event. Usually a player won't
have what it takes to do this so an Event Master plays the Event Villain themselves. Give the Event Villain
some evil goal to accomplish, and then have them go and attempt to accomplish it. Make them the most
powerful being in existance at that time. The MH and their allies will be built up through the event to
face the EV one day. If a villain never actually does anything evil they are not really a villain at all,
so as the EV you must actually have an evil goal and do whatever evil things you have to to accomplish it.
Give an EV their own personality, and think about how they would act using that personality when another
player is interacting with them. Stick to your character. If you have the personality of Freeza, act and
react like Freeza. The Event Villain does not have to be an Event Master, if Event Master's think a certain
player is worthy to play it go for it. But 2 Event Masters still need to stick with the EV side in the
shadows for boosts and story recording purposes.<p>

Main Hero and Event Villain are like spotlights. They are the only 2 spotlights, anything that is not within those 2
spotlights is not acknowledged for the story. A MH's friends and enemies are in his spotlight, an EV's allies and enemies
are in his spotlight. There are not to be any other spotlights that have nothing to do directly or indirectly with the MH
or EV. If there are, they will just be a distraction to the Event Masters and will cause the 2 most important spotlights
to become more neglected. There is only so much focus to go around and 50% needs to be on the MH side and 50% on the EV
side.<p>

Do not alter player's natural actions to conform to an event. Events are not preset, they are flexible.
You merely put all the peices on the chess board and the game can play out 1000 different ways based on
the actions of the individual peices. The Event Villain goes to accomplish their goal and reacts naturally
to however other players act or react to them. Do not try to force players to roleplay however you want
them to, just stick to your character and react naturally to them based on the personality you have given
to yourself as the Event Villain. Improvise.<p>

An Event Villain's true goal isn't just to wipe out everything in their path to achieving their goal.
Their IC actions are just a facade to mask the Event Villain's true OOC purpose. The EV's true purpose
is to create situations which drive potential heroes out where Event Masters can see them. That way
Event Masters can more easily determine which player has the most motivation and potential to be the hero
of this event, then they can keep track of them and help them behind the scenes as each new challenge
comes to them.<p>

The EM playing the EV tries to NOT go directly to where the Main Hero is before they MH stands any
sort of chance. Like at the start of dragon ball X, Freeza didn't come to Earth personally and massacre
Carrot_Man, he sent an appropriate challenge, Raditz. If your the Event Villain and you have henchmen, try to use
your henchmen to provide appropriate challenges to the MH and their friends to build them up. Don't send
100% death sentences. To anyone OTHER than the HC, you just massacre them if you want, but you do it
differently when it comes to the HC, because it has been decided they are the most worthy to one day
defeat you. The challenge you send could be too strong for the MH alone to defeat it, that is why they
need friends. If the MH doesn't have friends he isn't a hero at all, because a hero protects things, and
without friends they have nothing to protect and no reason to either.<p>

There should be 2 Event Masters watching the Main Hero and their friends/allies, and 2 Event Masters
watching the Event Villain and their allies/henchmen. That means 2 EMs to watch the good side and 2 to watch
the evil side. This is for story recording purposes, and for rewarding during crucial periods of the event.<p>

Event Masters must work as a team and communicate with each other. Do not go doing your own stuff. Do ONE
event at a time all together until it's over. Do not flood the story with incoherent crap that goes nowhere
and has nothing to do with anything else in the story. If it's not about the main event on the MH or EV
side, it does NOT go in the story.<p>

By using the EditNotes and Notes verbs you will see there is a spot to fill out to list who the HC, EV,
and their allies/henchmen/friends are. This is Omega important. Update it whenever there is a change.
Such as if the MH changes, or the EV is defeated. This should be updated by an Event Master every day that
it changes at least. That way other Event Masters can keep up with figures in the event.<p>

As an EM on the good side, one of your purposes is to reward the MH and his friends when they need it.
Rewards aren't always boosts, many times they are rank training, but usually both. The reward is given
during rank training so they think they actually got it from the training. MH always gets first dibs on
rank training and boosts as well, they are the underdog that always pulls through when the time is right,
so long as they remain worthy of it. You can order a rank to train them if you have to, just remember to
keep it a secret. As the EV sends challenges to the MH and his friends, or they are threatend by some
other source, help them overcome it. Do not pre-emptively help them. The threat must exist ALREADY, and
they must have had some sort of initial conflict with it, or else they have no reason to overcome something
that has not yet conflicted with them, and you have no reason to boost them.<p>

Event Masters are supposed to keep their activities secret as much as possible. We are like spies. We are
like "gods" watching from behind the scenes and "blessing" the "worthy ones" for actions they have already
taken the first steps towards accomplishing, but need "the blessing of the gods" to succeed in their
quest that we have deemed they deserve to succeed in.<p>

Don't keep a Main Hero who has become unworthy of the role. As I said its a flexible concept not a
static position or rank. If the Main Hero is not as deserving as once thought, change it to someone
who is when you find someone more deserving. If one of their friends deserve to be MH more than the current
one, change it to them instantly. If the MH is unavailable, switch to the next best person at that time, if
the former MH becomes available again and still deserves to be MH more than the current one, just switch it
again. Main Hero is based on who deserves it most at that time and switches easily.<p>

The Event Villains true purpose has already been stated but there are efficient and inefficient ways to
accomplish that purpose. Anyway, your goal, once a Main Hero is found, is to challenge them with
appropriate obstacles til they are built up to you. The challenge you send should be life threatening if
the good side does not handle it in an adequate way. Such as if the MH tries to fight the threat on their
own they would probably lose, they would need their friends to either help them defeat it, or temporarily
retreat to get some sort of rank training then return to defeat the threat. That would be the most
desirable things to happen, the good side Event Masters will focus on rewarding the MH and helping them
beat the challenge as long as the MH keeps playing their cards right and continues to deserve to be the HC.<p>

Do not tell people they are the Main Hero just help them behind the scenes and never talk about what is
going on behind the scenes with other players while the event is still going on, only after it is over if
you still want to.<p>

If someone has been made the Main Hero, they were at one time thought to be worthy of it. But sometimes
they prove otherwise later on. For example: A person was made Main Hero, they somehow find out
they are Main Hero (Or they don't, this example works either way), they stop waiting for threats to
come to them, and instead they go straight to the Event Villain and get all cocky and start a fight with
them, in other words, they start acting like Vegeta. If they start the fight they are not protecting
anything, if they aren't protecting anything they aren't heroic, if they aren't heroic they aren't the
Main Hero. So at that very moment they cease to be the Main Hero, leave them to their fate,
do not help them succeed in winning any fight they have started themselves for selfish reasons. Odds are
they would now be killed by the Event Villain for being a foolish obstacle to the EV's goal, but if they
somehow survive and you think they will not act so foolish again, you can optionally still consider them as
the Main Hero. The moment the MH stops protecting things and becomes the aggressor, they are not the
HC anymore, abandon them and go to the next most worthy person you can get.<p>

When you make an Event Villain make them the strongest being in existance at that time. No player should
be able to beat them unless they become the Main Hero and are built up to beat the EV because they
have proven themselves worthy to do so.<p>

When a battle between good and evil is going on, think for a second, which side deserves to win the most?
Then push the battle in that side's favor. If they already have the advantage don't give any boosts, let
the conflict play out however it plays out. If the side that deserved to win and seemed to have the
advantage loses anyway, even if they die, thats only "round 1", and you should help them get to "round 2".
Like think how when Carrot_Man was killed by Raditz, he was dead sure, but did it end there? Nope. They found
some way for him to come back because it was like a freak accident (Actually it was part of their plan,
but that just proved even more how much he DESERVED to be the HC), and he was brought back using IC
methods, and then he won "round 2" and just about every other round afterwards.<p>

There is an optional character called a Player Villain (PV). Player Villains are like "set it and forget it"
villains. This is just a regular player that wanted power to accomplish some evil goal they have, and
Event Masters thought they were worthy to do this. So the Event Masters give them the power and skills
they need to accomplish that goal and be the evil character the player envisioned. Do not make them anywhere
near as strong as the EV. Only make them twice as strong as the average player max. You can see averages
using the Reward verb. Actions of a PV do not go in the story. The only exception is if they come into
conflict with the MH side or the EV side. Then they would be in the story but only because the MH or EV
was involved, and important happenings on those 2 sides go in the story.<p>

Don't assign EVs, HCs, or PVs without getting the input of other EMs first and telling them about it and
why.

When rewarding the good side, give them whatever boost they need to overcome their challenge. But first,
think whether or not they still DESERVE to overcome the challenge. If they don't, stop helping them and get a
new HC. But if they DO deserve to overcome the challenge, give them whatever help they need to win. It
doesn't matter how big the boost is or how much rank training or skills they need. Just don't make them
more than twice the power of the current challenge they are facing, that is just over kill.<p>

The evil side gets boosts too but it is of a very different kind. If the Event Villain has henchmen, you
give them a "henchmen" boost. What I do, is think what kind of henchmen does this person DESERVE to be,
is it regular? Elite? Omega Elite? Commander? Let's say I'm the Event Villain played by an Event Master,
I am 500'000 bp. I get a new henchmen and think he only deserves to be regular, so I give him 1% of my
power, which makes him 5'000 bp. I see another I think deserves to be an Elite Henchmen, I make him
2-3% my power, which is 10'000-15'000 bp, I also give them some decent skills. I make a Omega Elite
5-15% my power, they are 25'000-75'000 bp. I then make a Commander or two, they are 20% my power,
100'000 bp. That's what I would do if I were Freeza, but really you can make them whatever percentage of
your power you think they deserve to be, just don't make them strong enough to be any threat to you.
This doesn't only count for henchmen either, sometimes the Event Villain has allies as well, like with
Freeza, King Vegeta may have been more of a "forced ally" rather than a henchmen. Either way, allies
would be boosted using the same methods you would boost a henchmen.<p>

The difference between boosts on the evil side compared to boosts on the good side is, the good side is
given gradual boosts based on the challenges they face relative to whether or not they deserve to overcome
that challenge still. The evil side allied with the Event Villain gets a sudden, often one-time boost
taking them to whatever % of the EV's power they deserve to be as his servant, and the evil side boost
is much easier to get than any boosts for the good side, because the standards aren't as high and they
don't need an actual reason for the boost story-wise except that they are allied with the EV.<p>

Before you reward someone on the good side with a power boost, think first if rank training from a
certain rank would be enough to give them the edge, if it would give them a significant enough edge,
do rank training instead of giving them a power boost. Or do both if it's not over kill. But always consider
doing rank training before boosts.<p>
"}
var/SuggestedRanks={"<html>
<head><body>
<body bgcolor="#000000"><font size=3><font color="#CCCCCC">

You are given a rank because you were thought to deserve it. But there are guidelines, and if you are
not willing to follow these guidelines you should not have asked for or accepted a rank and should be
stripped.<p>

Sometimes a Event Master may tell you to train someone for event purposes. If an Event Master tells you
to do something IC do not reveal that you were told to do it by Event Masters until at least a day
later and only after you have already done it. Event Masters act for secret reasons in the shadows, and
they don't reveal those reasons while the event is going on.<p>

Ranks get many skills, but some are only taught for event purposes. There are 3 skill levels: Common,
Moderate, and Rare. You can teach common skills to anyone you think deserves it as long as it is done IC.
For moderate skills you should think they deserve it even more before teaching them, and preferably have
them complete some sort of challenge first, such as "basic training" before you will allow them to
learn such skills. For Rare skills, do not teach them EVER unless it is to someone that Event Masters told
you to train. If you are an evil rank this doesn't apply to your rare skills, teach them to whoever you
think is worthy.<p>

Having a rank means you are either good or evil and cannot change. Regular players can be whatever
alignment they want, but if you get a rank you must abide by your alignment.<p>


Common: Blast, Charge, Beam, Fly, Zanzoken, Power Control, Spin Blast, Explosion, Sokidan, Give Power, Heal,
Shield, Telepathy, Shockwave.<br><br>

Moderate: Kamehameha, Death Ball, Final Clash, Galic Gun, Homing Finisher, Dodompa, Genocide, Kienzan,
Kikoho, Makosen, Masenko, Piercer, Ray. Focus. Expand. Split Form.<br><br>

Rare: Kaioken, Genki Dama, Shunkan Ido, Mystic, Majin<br><br>

If a Rank dies, other ranks of the same alignment who have the capability of reviving are supposed to help
them get revived, and get back to their rightful position on whatever planet they are supposed to be on.
Ranks are not allowed to remake without ranker permission. This paragraph does not count for
Skill Masters, Teachers, or Kaio Helpers.<br><br>

Each rank and their purpose:<br>
Earth<br>
- Kami: The Guardian has automatic knowledge of and is acquianted with every other rank on earth, as well
	as the Cardinal Kaio and Kaioshin, as well as any other good-aligned afterlife rank, although they are
	above him in status. Kami fulfills the purpose of protecting the earth from evil, although most times
	indirectly, doing what is necessary to help earth defend itself from threats which are serious enough to
	require Kami's attention. If Kami is a Namek they must make dragon balls immediately and scatter them.<br>
- Korin: Korin is much like Kami, but of a slightly lesser status.<br>
- Kame Sennin: Has no specific purpose, except to help the side of good when necessary. Kame Sennin has
	knowledge of Korin and Kami.<br>
- Tsuru Sennin: Has no specific purpose at all and is of any alignment. Tsuru Sennin has knowledge of
	Kame Sennin.<br><br>

Namek<br>
- Elder: The Namek Elder is much like the Kami of Earth. He has knowledge of all Teachers on Namek and
	is of good alignment. The Elder must make dragon balls immediately and scatter them.<br><br>

Afterlife<br>
- Kaioshin: Kaioshin are on the side of good in the Afterlife. They try to keep the afterlife as a peaceful
	and good place, they have knowledge of every rank on every planet. Their status exceeds all ranks of the
	good alignment. Kaioshin as well as all Kaio Ranks attempt to "police" the Demons and keep them from
	causing trouble, using the various techniques Kaioshin and other Kaio Ranks possess. There are no evil
	Kaioshin, or other Kaio Rank. All Kaio Ranks allow those who deserve it to keep their body while dead,
	and even revive people who really deserve it and/or have a reason for it.<br>
- Cardinal Kaio: These serve the same purpose as Kaioshin. They are one status level lower than the
	Kaioshin.<br>
- Kaio Helper: These are one status level above regular Kaio. Kaio Helpers focus mainly on using keep body
	and revive on those who deserve it and have good souls.<br><br>
- Daimao:	This is the highest rank held by Demons, it is always of evil alignment. Their job is to do evil
	things in general, preferably on a grand scale. They must provide active and noticeable opposition to the
	Kaio and everyone on the good side in afterlife, the Daimao must be constantly at war with the side of
	good, and they hate the Kaioshin.<p>
"}
var/Notes={"<html>
<head><title>Notes</title><body>
<body bgcolor="#000000"><font size=2><font color="#CCCCCC">

Main Hero (HC):<br>
HC's Important Friends:<br>
Event Villain (EV):<br>
EV's Important Underlings:<p>

"}
var/rank_window={"<html>
<head><title>Ranks</title><body>
<body bgcolor="#000000"><font size=2><font color="#CCCCCC">

*Earth*<br>
Guardian:<br>
Korin:<br>
Turtle Hermit:<br>
Crane Hermit:<br>
<br>

*Namek*<br>
Elder:<br>
<br>

*Arconia*<br>
Yardrat Master:<br>
<br>

*Heaven / Checkpoint*<br>
Kaioshins:<br>
North Kaio:<br>
South Kaio:<br>
East Kaio:<br>
West Kaio:<br>
<br>

*Hell*<br>
Daimaous:<br>
<br>
"}
var/Jobs={"<html>
<head><body>
<body bgcolor="#000000"><font size=2><font color="#CCCCCC">

This is a guide on how the admin system should be run.<br><br>

The work of an admin team needs divided among types of admins which are experts in that one thing. Everyone
doing a little bit of everything has proven never to work.<br><br>

So we need to list here, what each admins primary focus is. Below this there will be definitions of each
type of Admin.<br><br>

Head Admins:<br>
Event Masters:<br>
Rankers:<br>
Enforcers:<br><br>

As a certain type of admin you must not let your primary purpose suffer by neglecting it too much by
doing other admin things. You can do other admin things but only if your purpose is not neglected.
You can do other things so long as the main thing your supposed to do does not need done at that time.<br><br>

Head Admins: Manage the entire admin team, they decide who gets admin, and removes anyone who abuses. They
also decide what type of Admin that person will be. They keep the admin team pure and get rid of abuse.<br><br>

Event Masters: They manage the story. They work together on one coherent story at once, they do not go all
willy nilly and each make their own individual story entries that are just incoherent random things added
to the story that affect nothing lead nowhere. Only one event is worked on at a time. Communication between
event masters is important. Event Masters communicate with Ranks through Rankchat on a deep level to help
make events as interesting as possible. This is the most important admin type.<br><br>

Rankers: Rankers manage the ranks. All rankers must agree before the person gets the rank and nobody should
be ranked without consent of the other rankers, if they do it is abuse. Rankers decide who will get a rank
and they remove ranks who are abusive or do not live up to the rank's expectations. Communication between
Rankers is important. This is an important admin type.<br><br>

Enforcers: This is mostly for level 1 admins. They keep spammers out and ban those who deserve it. This is a
very abusable job in the wrong hands. This isn't really as crucial to have as the other admin types but it
still fulfills a necessary purpose.<br><br>

To-Do List for Admins at the start of a wipe:<p>

<li>Assign Admin Jobs<p>

<li>Assign Ranks. Do not delay assigning ranks when there are perfectly deserving people available. Give
the ranks to those who deserve it as they appear without delay.<p>

<li>Make at least 5 Skill Masters on each planet. For Vegeta, this means giving them Saiyan Elite as well.
If there are not 5 deserving people lower your standards a bit just don't give it to noobs who will nonrp
people. If there are not 5 people at all, just don't worry about it. It is important to have at least 5
Saiyan Elites starting out because most people die/remake/become hermits anyway and odds are only 2 of them
will remain long term in the wipe. Do not delay this for any reason, if worthy people are available
give it to them immediately. There is no reason to wait.<p>

<li>Start the Event as soon as there are enough people on and it is a good time of day. Do not delay it
til a "certain year" or whatever other reason. Do it as soon as possible without sacrificing quality.<p>

<li>Start giving out the "non-noob boost" to anyone who is not a threat of nonrp attacking/killing/stealing/
trapping people. This isn't something you do all at once you just do it over the course of the wipe each
time you spot someone who deserves it give it to them. Just do it in the background during the course of
your casual actions.<p>

Non-Noob Boost Definition: This is a boost you give to anyone who does not fit this game's description of
"noob". Only give this to them if you think there is no potential in them to nonrp others. The non-noob
boost means boosting anyone under 5 RP Power, TO 5 RP Power. You can see the average RP Power in the
Reward verb. If the average gets far enough past 5 RP Power, go ahead and start boosting them to half of
what the average is. The purpose of the Non-Noob Boost is to protect the people you give it to, FROM noobs.
So admins don't have to as much.<p>

"}
var/Rules={"<html><head><title>Rules</title><body><body bgcolor="#000000"><font size=3><font color="#CCCCCC">

Roleplaying:<br>
1) To RP with people most of your name must be pronounceable. It can't be all symbols. That's just 1 example.<br>

2) Situations that require a roleplay+countdown before doing it: Attacking, killing, stealing, grabbing, or anything
else that will negatively affect a player.<br>

2.1) The exception is breaking into buildings, it's what you do inside that counts.<br>

2.2) If you have specific targets each of them must see the roleplay before you can do it, you can
not do it off screen.<br>

2.3) If you do not have specific targets, for example using a nuke, then you must roleplaying nuking
in a place where there are players to see it.<br>

2.4) Countdowns can be skipped if the target(s) allow it<br>

3) If someone attacks/kills/steals/grabs you first, then you can fight back to the death without any response or
countdown if you choose to do it that way. But you must first wait until they have actually started the action or
their countdown is up (If they even did one).<br>

3.1) If their action was an accident this rule does not apply.<br>

4) When using any communication verb other than OOC, you must remain In Character. To use those verbs Out of Character
you must put brackets around your message so people know it is OOC.<br>

5) IC and OOC knowledge must be kept seperate.<br>

6) Demons can attack other races without warning in hell. Notice I said ATTACK, not kill, steal, or anything else.<br>

7) Say and Emote are -both- roleplaying, because they are both IC. They are both equally valid as a roleplay in any
situation. Each one is suited to different situations more than the other but that's for you to decide.<br>

8) Fights are verb by default. Anything other than that must be agreed by all participants in the fight.<br>
"}
var/Game_Rules={"<html><head><title>Rules</title><body><body bgcolor="#000000"><font size=3><font color="#CCCCCC">

This is a Bill of Rights for the entire game and over-rides any rules that defy it. A host that defies this
will be ruined. These rules are not open to interpretation, their meaning is obvious. If any host or admin
tries to twist these rules they do so at their own peril. Nobody will be fooled by their attempt to manipulate
the true meaning and their server will be ruined.<p>

Host/Admin Limits:<br>
<ul>
<li>When banning someone the 'reason' area must be filled in with a serious reason. To leave it blank or not enter
a valid reason is abuse.
<li>Rules or exceptions to rules can not be made for specific players or groups of players. For example a rule can not
be made to stop a certain guy from doing something others are allowed to do just because the host dislikes the guy.
Rules about different races in the game are fine, just no rules against specific players or 'types' of players.
<li>No punishment in any way for anything not stated in the rules. (Bans, Nerfs, Mutes, Deletions). Adding a rule
after someone did something then punishing them for doing it before that rule existed is abuse.
<li>No package discrimination. Packaged players can not be treated differently than anyone else. No special rules or
restrictions can be placed on them.
<li>Host/Daemon/Pager banning a player for offenses in-game will not be tolerated. Use in-game bans.
Host/Daemon/Pager bans are permitted against people who have attempted to harm the host computer or threatened to.
Permanent bans are not allowed unless it is on someone who has harmed the host computer or other player's computers.
<li>A player can not be punished for the same thing twice. If they do it again, or do something new, they can of course
be punished for that. This does not mean that if a person got banned for spam already that they are now immune to ever
being banned for spam again.
<li>The owner can not be banned for any reason.
</ul>

Player Rights:<br>
<ul>
<li>Freedom of speech. Players can say whatever they want without punishment, even if it is insults, sexual, racist,
or whatever else. Players may post links as long as the content does not harm a player's computer or lock up their
browser. It is not the host or admins place to tell people what they can or can not conversate about. Legitimate
spamming is punishable. An admin labeling something as spam when it is not spam is abuse. Exceptions: Admins CAN
outlaw speaking in 'caps' and sexual or racist talk (but ONLY in OOC) if they choose to. If players are arguing in OOC
an admin can tell them to not argue in OOC and only if they persist can they be punished. IC in OOC is not included in
freedom of speech.
<li>Freedom of speech also translates to Freedom of RP. A person can RP as whatever they want, and any situation
they want. There are a few exceptions if the admins choose to make them, including: RPing as well known characters,
for example from any anime. RPing as if they are descended from or personally know a well known character. These
are permitted by default but can be made illegal if the admin chooses. Your character's name is not protected by
freedom of RP.
<li>Players can post links to other servers of this game as long as they do not do it more than once per hour.
<li>Players can only be punished if there is proof they are guilty. Such as an admin seeing it personally, or a
screenshot. One or more people simply saying a person did something is not proof. It is too easy to frame someone. A
player can not just be assumed guilty. They are innocent until proven guilty.
<li>Rules defying this bill of rights are void and players should defy those rules, the ones who
made them, and the abusive server itself, and are permitted by any means necessary.
</ul>

"}
var/Story={"<html>
<head><title>Story</title><body>
<body bgcolor="#000000"><font size=2><font color="#CCCCCC">



</body><html>"}
/*mob/verb/Bill_of_Rights()
	set category="Other"
	src<<browse(Game_Rules,"window=Game Rules,size=650x600")*/
mob/proc/Race_Guide()
	set category="Other"
	var/T={"<html><head><body><body bgcolor="#000000"><font size=2><font color="#CCCCCC">
	This will show you the stat gains of all races in the game. The most popular races are listed at the top.
	All stats from energy to anger are the race's base stats -before- you change them by adding stat points.<p>
	"}
	var/list/L=Race_List()
	for(var/V in L)
		T=Race_Info(T,V)
		L-=V
	T=Race_Info(T,"Elite")
	src<<browse(T,"window=Race Information;size=650x600")
proc/Race_Info(T,V)
	var/mob/M=new
	switch(V)
		if("Half Saiyan")
			M.Half_Saiyan()
		if("Legendary Saiyan")
			M.Legendary_Saiyan()
			M.Race="Legendary Saiyan"
		if("Alien") M.Alien()
		if("Android") M.Android()
		if("Bio-Android") M.Bio()
		if("Demigod") M.Demigod()
		if("Demon") M.Demon()
		if("Icer") M.Icer()
		if("Human") M.Human()
		if("Kai") M.Kai()
		if("Makyo") M.Makyo()
		if("Majin") M.Majin()
		if("Namek") M.Namek()
		if("Spirit Doll")
			M.Doll()
			M.Race="Spirit Doll"
		if("Tsujin") M.Tsujin()
		if("Saiyan") M.Saiyan(0)
		if("Elite")
			M.Saiyan(0)
			M.Elite_Saiyan()
			M.Race="Elite Saiyan"
	M.Racial_Stats(M,0,modless_check=0)
	T+={"
	[M.Race]<br>
	[M.Points] Stat Points to use during creation<br>
	[M.bp_mod]x Battle Power<br>
	[M.Eff]x Energy<br>
	[M.strmod]x Strength<br>
	[M.endmod]x Durability<br>
	[M.formod]x Force<br>
	[M.resmod]x Resistance<br>
	[M.spdmod]x Speed<br>
	[M.offmod]x Offense<br>
	[M.defmod]x Defense<br>
	[M.regen]x Regeneration<br>
	[M.recov]x Recovery<br>
	[M.max_anger/100]x Anger<br>
	[M.sp_mod]x Skill Points<br>
	[M.mastery_mod]x Skill Mastery<br>
	[M.leech_rate]x Adaptation (How fast you catch up to people your fighting)<br>
	[M.Intelligence]x Intelligence (Used for creation of better and cheaper technology)<br>
	[M.knowledge_cap_rate]x Knowledge cap rate (does not increase cap, only intelligence does)<br>
	[M.Gravity_Mod]x Gravity Mastery<br>
	[M.Decline] decline age. [round(M.Lifespan(),0.1)] year lifespan. (Both increase by gaining energy)<br>
	[M.Regenerate]x Death Regeneration<br>
	[M.med_mod]x Meditation BP<br>
	[M.zenkai_mod*M.bp_mod]x Zenkai (How much stronger you get from being defeated (Knocked out or killed))<br>
	[M.power_absorb_mod()]x Power absorb mod (BP you get from absorbing people)<br>
	[M.knowledge_absorb_mod()]x Knowledge absorb mod<br>
	[M.potential_mod()]x hidden potential (amount you gain when unlock potential is used on you)<br>
	Blast homing chance: [M.Get_blast_homing_chance()]% per step<br>
	[M.stun_resistance_mod]x stun resistance<br>
	BP loss from low Ki: [M.Get_bp_loss_from_low_ki()]x (lower is better)<br>
	BP loss from low Health: [M.Get_bp_loss_from_low_hp()]x (lower is better)<br>
	"}
	if(!(M.Race in list("Saiyan","Half Saiyan")))
		T+="Stage 1 Ascension BP: [Commas(M.Stage1_Ascension_BP()*M.bp_mod)]<br>\
		Stage 2 Ascension BP: [Commas(M.Stage2_Ascension_BP()*M.bp_mod)]<br>"
	if(incline_on)
		T+="Incline Age: [M.incline_age]<br>\
		Incline Mod: [M.incline_mod] (lower is better)<br>"
	T+="<br>"
	//Anger failure chance: [100-M.anger_chance()]%<br>
	return T










mob/proc/Sagas_Guide()
	src<<browse(sagas_guide,"window=Sagas Guide;size=700x600")
var/sagas_guide={"<html><head><body><body bgcolor="#000000"><font size=3><font color="#CCCCCC">

By default sagas and alignment are off on servers. But some may have it on. They can both be turned on
independantly. Alignment means a player can be either good or evil, which comes with different advantages and
disadvantages. A person can change their alignment every 10 hours. Sagas means that one good person will be
chosen to be a main hero and one evil person chosen
to be the main villain. Hero and villain have advantages and disadvantages. Read more for details.<p>

Good alignment:<br>
<ul>
<li>Can not harm other good people, including stealing from them and many other things
<li>Can not destroy planets because that is evil
<li>Can not teach skills to evil people
<li>Can not get the Daimao rank
<li>Give power ability is 35% stronger
<li>50% stronger bind against evil people
<li>Can use bind slightly more often against evil people
</ul><p>

Evil alignment:<br>
<ul>
<li>11% faster BP gain
<li>25% faster stat capping
<li>25% faster skill point gain
<li>Master skills 25% faster
<li>Unlock potential is half as effective on evil people
<li>-10% leech rate when fighting evil people
<li>-90% leech rate when fighting good people (Evil and Good are not really allowed to train together)
<li>Can not get Namek Elder, Turtle Hermit, or any Kai rank unless they got it before turning evil
<li>Can not get death anger because evil people do not care who dies
<li>Depending on server settings evil people will have a damage penalty if there is too many evil people
and not enough good people on the server, to force some evil people to switch to good. This damage penalty
will display in your stats tab, if nothing is there then you have no damage penalty. Most of the time this is off.
<li>Can not have good alts, they will all be set to evil
<li>Give power ability is 50% weaker
</ul><p>

Hero rank:<br>
<ul>
<li>Takes 35% less damage from evil people who aren't the main villain
<li>Takes 25% less damage from the main villain
<li>Leech everyone 2x faster
<li>Gets up from knockouts 30% quicker
<li>Will always get anger when needed
<li>Master all super saiyan levels 2x faster
<li>If the hero dies from anyone other than the villain they lose the hero rank
<li>If the villain kills the hero there is a 50% chance the hero will lose the rank, and a 50%
chance they will enter a 'training period', which lasts 30 minutes and has 10x bp gains
<li>Do x2 damage against any npcs, and take half damage from all npcs
</ul><p>

Villain rank:<br>
<ul>
<li>Does 35% more damage to anyone who is not the hero
<li>Is given 150 minutes to kill the hero or they will lose the villain rank
<li>Killing the hero refills the time back to 150 minutes
<li>If the hero is a coward they do not deserve the hero rank, so in this case the villain can go
on a killing spree. If the villain kills 3 unique players within a certain time period it will start a
killing spree. The hero and everyone else will be alerted that the villain is on a killing spree and if the
hero does not respond then they will lose the hero rank. If the villain then kills 7 more unique players within
a 15 minute time period the hero will lose the rank for being a coward. (Or afk, but oh well)
<li>If the villain attacks the hero while they are in their 'training period' then the villain will lose
the rank. If the hero attacks first then they will not lose the rank and the training period will end.
</ul><p>

Leagues work differently for the main villain, but only if the server is set to PVP mode. People in their league become like
henchmen to them. The members will recieve a paycheck once in a while. Members will take 2x more damage and do 2x less damage to the
main villain. The more members the villain gets the worse things become for anyone who is not a member, because the paychecks come out
of the global resource pool used to refill planet resources, random resource drops on planets, and the tournament prize.
<p>

"}







mob/proc/Strong_guide()
	src<<browse(strong_guide,"window=Strong Guide;size=700x600")
var/strong_guide={"<html><head><body><body bgcolor="#000000"><font size=3><font color="#CCCCCC">

This is what I do to get strong when I play. It doesn't require you to
know anyone to help you. There are 2 separate methods, the first requires less work and no technology, the
second requires some technology and a scientist alt, and is harder to do, but more effective. The last part
is about core training, which is my main form of training and statistically has the best gains of any
form of training. This guide was
written on May 11th 2014 so it may become outdated. I'm sure some
people do it better but here it is:<p>

Barbarian method:<br>
<ol>
<li>Make a character that has as much points in energy/anger/regeneration/recovery as you want to have.
<li>Put all remaining points evenly as possible into durability and resistance. (Not defense it won't help you
very much against stronger people since the odds of you dodging them are low. This build is not for combat it is
a leeching build, you can change it later using a genetics computer to reproportion your stats.
<li>Use the train command til you get 1 skill point, then learn shadow spar
<li>Begin shadow sparring, if you are any good at it you should cap your stats in 3 minutes or less. No, you do
not need packs to use shadow spar, it is the fastest way to cap stats regardless. And I can actually shadow spar
quite a bit faster manually than a packer can automatically.
<li>Master flying til you can fly for at least 1 minute.
<li>If the server's SP gains are good, shadow spar til you can learn a custom buff.
<li>Use Buff-options and make the buff have 0.7x strength/speed/force/offense/defense/regeneration.
<li>Use the extra 18 buff points and put 9 into durability and 9 into resistance.
<li>Activate the buff
<li>If you can get armor somehow at this point, do so, right click it and set its protections to the maximum, then
wear it
<li>Learn sense.
<li>Get weights if possible but it is not neccessary do not waste much time trying to get them. Wear them because
they increase leeching rate when fighting stronger people.
<li>Your durability and resistance should be pretty insane by now, so your goal is to leech people stronger than you.
You should fight people between 200% and 500% your power, or higher if they are the only ones available. Fighting
people under 200% is usually a waste of time unless they are the only ones available.
<li>Fight people much stronger than you over and over without caring if you live or die, but your goal is to last
as long as possible against them to leech their power. if you die just fight them in afterlife.
Once you do this for about 10 minutes you should have really good BP. If you do not then continue until you feel your
bp IS good. Fight people as strong as possible while still being able to last at least 30 seconds against them,
even if they are 999%.
<li>If you can, get sense level 2 and 3. Click yourself to bring up a sense tab and check your gravity mastery.
More gravity mastery = more BP gains. If it is under 200x that is bad. You should sense other people who have more
gravity mastered than you, and go fight them to leech it. You can skip this step if you want because it takes
a long time because gravity mastery leeches very slowly, but you really need at least 60x mastered. The faster
way is to use a gravity machine which is like 20 times faster than leeching, but those are expensive.
<li>It usually takes me about 20 minutes to get to this point.
<li>Once you feel that your bp is pretty high compared to what most people have, make your way to Earth somehow,
and kill monsters until one of them drops a time chamber key. There is about a 1% chance of this happening per kill.
Some servers have it set so that you can not get a time chamber key this way, so try to find that out.
<li>Once you get a key on Earth go to coordinates 200,200 and somewhere around there is the entrance to Kami's
tower. Go all the way up and somewhere there is the entrance to the time chamber.
<li>You -need- weights by this time. Good ones. And splitform.
<li>Use your all durability and resistance buff you made. Set your knockback to 0%. Wear armor if you have it.
Enter the time chamber, and
fly spar your own splitform til your time is up. Do not use any other form of training except sparring or it is a
complete waste of time. Every minute counts, and you only get 20.
<li>If you did everything right then by the time you get out of the time chamber you should be in the top 5% of
strongest players. If you are not then most likely you messed up by not sparring people stronger than you enough,
and thinking you had leeched enough BP when really you didn't.
<li>It usually takes me about 1 hour to get this far. Once you are powerful it is pretty easy to stay that
way the entire wipe.
<li>You are now done with the temporary build used for leeching, and you can find a genetics computer to
reproportion your stats how you actually want them using the genetics computer's "Lower Stat" command, afterwards
just shadow spar for 3 minutes or less to re-cap your stats.
<li>Use the time chamber as often as possible, you can use it once every 21 hours. Do not "save it" that is
pointless. Use it as frequently as possible.
</ol><p>

Complex method:<br>
<ol>
<li>Basically the same as the barbarian method, but before making your fighting character you make a scientist
alt, preferably a Tsujin or Human, with the goal of making enough resources to create a maxed out gravity machine,
which your fighting character
will then train in.
<li>Do not bother training the scientist character at all.
<li>A good way to get some money starting out is to run around the planet looking for a random resource drop.
Somewhere in the universe every 30 seconds a random resource bag will spawn containing something like 400,000 to
600,000 resources. The only reason there would not be any on the planet you are on is if someone has Drones
collecting them all, or if someone used a resource radar to collect all of them recently.
<li>It usually takes 5 minutes or less to find one of these bags, once you find enough, create a radar. Drop 1
resource in front of you and right click the radar and set it to detect resources. Click the radar to equip it
and view your Radar tab, you should see all resources on the planet. Go to them and collect them.
<li>Odds are you will collect a couple million easily this way in about 5 minutes.
<li>Create a nav system and a spacepod. Upgrade the nav to the max so it can detect all planets.
<li>Power down so that you are undetectable to others, and avoid contact with other people at all costs or they
will most likely kill you.
<li>Get in the pod and leave for space
<li>On every map you go on, including space, check your radar tab and collect any worthwhile amount of resources
you detect. It can take up to like 10 seconds for the radar tab to refresh.
<li>Create a drill and click it to check how many resources are left in the planet. If there are none left forget
about it and move on. If there is any worthwhile amount left, upgrade the drill enough to dig them out within
3 minutes or less, take them, scrap the drill, and move on.
<li>Do this on all planets on your radar.
<li>Usually after doing this I end up with more than enough for a maxed gravity. Usually like 30 million resources
or so.
<li>The problem is, that at the time of writing this, not many people use resource radars and go collecting them
this way, but now that I have written this guide, that may all change, and it may not be so easy any more.
<li>Now that you have a maxed gravity machine, you can make your fighter character, and train it in the gravity in a
safe house somewhere, hidden and out of the way.
<li>After your fighter has good gravity mastery, you can do most of the barbarian method, and it will be even more
effective since your high gravity mastery means higher BP gains.
</ol><p>

Using Planet Vegeta's Core:<br>
<ol>
<li>I go to Planet Vegeta's Core often as training, but only if I am a Saiyan or a race with good zenkai,
because zenkai influences gains
there. Planet Vegeta's Core is a dangerous place meant for survival/torture training, there are explosions
everywhere and acid smog, and strong monsters. Killing the monsters there will refill your health. The core and
sparring and time chamber are my main sources of power, and the best forms of training in the game, I do not
ever use train or meditate or anything else as training, they are complete wastes of time, and will actually make
you weaker compared to everyone else who trains better, because by the time you gain 1 bp, they'll gain 5, you are
becoming weaker by comparison, and they will just stay 5x stronger than you are. It accomplishes nothing. A dead
zone amulet is the best way to escape the core before dying.
<li>You need to be fairly powerful just to survive in the
core, use the server-info command to see the average BP of the server, if your normal unweighted base power is
less than 3 times the average, you are too weak for the core. You should be able to survive the core at least
7 minutes per session, I usually do 15 minutes per session then take a break. Your goal is to NOT DIE, but to
escape alive after you are done training there. If you die it is bad.
<li>The only stats that matter in the core are strength (or force if your a ki user), durability, speed, and
offense. Resistance or defense will not protect you against the explosions, acid smog, or monsters there.
Regeneration does not matter because you do not heal from the constant acid smog damage there.
<li>Using the core requires preparation
before-hand to survive, you NEED to wear armor with maxed protections, wear maxed weights, and make a buff made
specifically for core training, which has 0.7x energy/force (unless your going to use force in there which I do
not recommend)/resistance/defense/regeneration/recovery. Put the extra 18 buff points as evenly as possible into
strength/durability/speed/offense. Use that buff the entire time in the core. If you do not use the armor and the
buff exactly as I described you will die guaranteed. Even with them it will be difficult.
<li>While in the core you should power down as much as possible to make the training harder, but without dying,
because the more difficult it is the more you will gain.
<li>Upon entering the core one of three possible songs will play, if you hear Vegeta's training theme, then you
are getting the maximum possible gains, so do not power down any further if you hear that song. If you hear Ginyu's
theme then you have slightly too much power and are not getting maximum gains. If you hear Pikkon's theme then
you are too powerful and not gaining hardly anything, and need to power down more to make it harder. It is only
really worth it if you hear Vegeta's training theme.
<li>Stay on the move in the core to avoid explosions, do not let them hit you. You should get hit 5% of the time or
less. If you do not dodge them you will die. You can avoid 95% of the explosions simply by running in a
straight line without stopping.
<li>Sense out some Core Demons and kill them to restore your health, only fight them 1 on 1, if you fight more
than 1 at a time you will
die. You might get lucky doing 2 on 1 but eventually you will die. If you do 3 on 1 or more you will die
gauranteed. So if more than 1 is coming at you, run far away til they lose track of you and fight a different one.
<li>If you manage to survive 10 minutes while wearing maxed weights, with good gravity mastery, and with Vegeta's
training theme playing at least 70% of the time, you should come out having gained a ton of power.
</ol><p>


"}