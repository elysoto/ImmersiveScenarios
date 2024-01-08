
require "StashDescriptions/StashUtil";

local stashMap = StashUtil.newStash("IScnHospital_Stash_WP", "Map", "Base.WestpointMap", "Stash_AnnotedMap");

stashMap.barricades = 80;
stashMap.zombies = 8;
stashMap.buildingX = 11129
stashMap.buildingY = 6851

stashMap.spawnTable = "SurvivorCache1";
stashMap:addStamp("House", nil, 11135, 6851, 0, 0, 1)
stashMap:addStamp(nil, "Meet up with the family\n\nat Grandpa's old farm", 11050, 6865, 0, 0, 1)
stashMap:addStamp(nil, "Check the\ntool shed!", 11084, 6777, 0, 0, 0)
stashMap:addStamp(nil, "Bridge might\nbe blocked", 12275, 6768, 0, 0, 0)
stashMap:addStamp(nil, "Gun shop is locked", 12042, 6769, 0, 0, 1)
stashMap:addStamp("Skull", nil, 12174, 6899, 1, 0, 0)
stashMap:addStamp("ArrowWest", nil, 12150, 6900, 1, 0, 0)
stashMap:addStamp("ArrowSouth", nil, 12231, 6918, 0, 0, 1)
stashMap:addStamp(nil, "Don't go through town!", 12150, 6850, 1, 0, 0)