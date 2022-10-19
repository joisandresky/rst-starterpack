# RST Starterpack for QBCore

This is Just simple Starterpack Script, that player can use for Redeem Server Starterpack. (used in my server)


# Extra Commands

1. `/setstarterpack citizen_id status` 
	- This Command is for Set Players (online/offline ) status for Claiming Starterpack. in case you already giving some players Starterpack With Manual Way.
	- citizen_id is value from table **players**
	- status value is: true or false
2. `/checkstarterpack citizen_id` 
	- This Command is for Checking Players (online/offline ) status for Claiming Starterpack
	- citizen_id is value from table **players**

## How To Install

1. Clone or Download as Zip this Repository
2. Go to qb-core resource folder `qb-core/server/player.lua`
3. And Add this code into `QBCore.Player.CheckPlayerData(source,  PlayerData)`
	```lua
	PlayerData.metadata['starterpack'] = PlayerData.metadata['starterpack'] or  false
	```
	add this code below others metadata configuration in ``QBCore.Player.CheckPlayerData`` Function.
4. ensure ``rst-starterpack`` in your server.cfg
5. Check ``config.lua`` for Configuration like Ped Location, Items and Vehicle for Starterpack

## Preview

TODO

## Need To care

Please Provide Valid Garage name in ``config.lua`` , cause Vehicle you gave is gonna stored at garage that you use in ``config.lua`` when Player Redeem the Starterpack.