
require "StashDescriptions/StashUtil";

local stashMap = StashUtil.newStash("IScnHospital_Map_WP", "Map", "Base.WestpointMap", "Stash_AnnotedMap");

--stashMap.traps = "1"
stashMap.barricades = 80;
stashMap.zombies = 8;
stashMap.buildingX = 11129
stashMap.buildingY = 6851

stashMap.spawnTable = "SurvivorCache1";

stashMap:addStamp("House", nil, 11134, 6853, 0, 0, 1)
stashMap:addStamp(nil, "Meet up with the family", 11145, 6843, 0, 0, 1)
stashMap:addStamp(nil, "at Grandpa's old farm", 11162, 6868, 0, 0, 1)
stashMap:addStamp(nil, "Tool shed", 11092, 6769, 0, 0, 0)
stashMap:addStamp(nil, "Bridge blocked", 12272, 6756, 0, 0, 0)
stashMap:addStamp(nil, "Gun shop is locked", 12016, 6735, 0, 0, 0)
stashMap:addStamp("Skull", nil, 12158, 6899, 1, 0, 0)
stashMap:addStamp(nil, "Don't go through town!", 12094, 6870, 1, 0, 0)
stashMap:addStamp("Wrench", nil, 11096, 6794, 0, 0, 0)
stashMap:addStamp("Gun", nil, 12056, 6762, 0, 0, 0)
stashMap:addStamp("FaceDead", nil, 11936, 6804, 1, 0, 0)
stashMap:addStamp("Skull", nil, 11934, 6888, 1, 0, 0)
stashMap:addStamp(nil, "", 12187, 6979, 0, 0, 1)
stashMap:addStamp("Checkmark", nil, 12232, 7011, 0, 0, 1)
stashMap:addStamp("Checkmark", nil, 11966, 7182, 0, 0, 1)
stashMap:addStamp("Checkmark", nil, 11700, 7117, 0, 0, 1)
stashMap:addStamp("Checkmark", nil, 11650, 6900, 0, 0, 1)


local stashMap = StashUtil.newStash("IScnHunting_Map_WP", "Map", "Base.WestpointMap", "Stash_AnnotedMap");

stashMap.barricades = 0;
stashMap.zombies = 0;
stashMap.buildingX = 4247
stashMap.buildingY = 7229

stashMap:addStamp("House", nil, 4246, 7226, 0, 0, 1)
stashMap:addStamp("ArrowWest", nil, 4323, 7241, 0, 0, 1)
stashMap:addStamp("ArrowNorthWest", nil, 4418, 7310, 0, 0, 1)
stashMap:addStamp("Fish", nil, 4268, 7273, 0, 0, 0)

local stashMap = StashUtil.newStash("IScnHuntingHome_Map_WP", "Map", "Base.WestpointMap", "Stash_AnnotedMap");

--stashMap.traps = "1"
stashMap.barricades = 80;
stashMap.zombies = 8;
stashMap.buildingX = 11129
stashMap.buildingY = 6851

stashMap.spawnTable = "SurvivorCache1";

stashMap:addStamp("House", nil, 11134, 6853, 0, 0, 1)
stashMap:addStamp(nil, "Meet up with the family", 11145, 6843, 0, 0, 1)
stashMap:addStamp(nil, "at Grandpa's old farm", 11162, 6868, 0, 0, 1)