
require "StashDescriptions/StashUtil";

local stashMap = StashUtil.newStash("IScnHospital_Stash_WP", "Map", "Base.WestpointMap", "Stash_AnnotedMap");

--stashMap.traps = "1"
stashMap.barricades = 80;
stashMap.zombies = 8;
stashMap.buildingX = 11129
stashMap.buildingY = 6851

stashMap.spawnTable = "SurvivorCache1";

stashMap:addStamp("House", nil, 11134, 6853, 0, 0, 1)
stashMap:addStamp(nil, "Meet up with the family", 11061, 6860, 0, 0, 1)
stashMap:addStamp(nil, "at Grandpa's old farm", 11072, 6877, 0, 0, 1)
stashMap:addStamp(nil, "Tool shed", 11072, 6793, 0, 0, 0)
stashMap:addStamp(nil, "Bridge blocked", 12272, 6756, 0, 0, 0)
stashMap:addStamp(nil, "Gun shop is locked", 12016, 6735, 0, 0, 0)
stashMap:addStamp("Skull", nil, 12166, 6899, 1, 0, 0)
stashMap:addStamp("ArrowWest", nil, 12150, 6900, 1, 0, 0)
stashMap:addStamp("ArrowSouth", nil, 12231, 6918, 0, 0, 1)
stashMap:addStamp(nil, "Don't go through town!", 12099, 6870, 1, 0, 0)
stashMap:addStamp("ArrowWest", nil, 12162, 7182, 0, 0, 1)
stashMap:addStamp("ArrowNorthWest", nil, 11751, 7184, 0, 0, 1)
stashMap:addStamp("ArrowWest", nil, 11693, 6901, 0, 0, 1)
stashMap:addStamp("Wrench", nil, 11064, 6802, 0, 0, 0)
stashMap:addStamp("Question", nil, 12316, 6735, 0, 0, 0)
stashMap:addStamp("Gun", nil, 12056, 6762, 0, 0, 0)
stashMap:addStamp("FaceDead", nil, 11936, 6804, 1, 0, 0)
stashMap:addStamp("Skull", nil, 11934, 6888, 1, 0, 0)
