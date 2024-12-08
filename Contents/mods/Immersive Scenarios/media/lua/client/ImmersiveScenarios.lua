
ISCN = {}

ISCN.getContainer = function(x, y, z)
    DebugLog.log("IScn:getContainer: " ..x.." "..y.." "..z)
    local sq = getCell():getGridSquare(x, y, z);
    if sq ~= nil then
        local objs = sq:getObjects();
        for i = 0, objs:size()-1 do
            local o = objs:get(i);
            local c = o:getContainer();
            if c ~= nil then
                DebugLog.log("IScn::Found Container " ..x.." "..y.." "..z)
                return c;
            end
        end
    end
    return nil;
end

ISCN.removeGuns = function(x, y, z)
    local c = ISCN.getContainer(x, y, z);        
    if c ~= nil then
        
        local containerItems = c:getItems()
        if containerItems then
            local itemsToRemove= {};
            for i = 0, containerItems:size()-1 do
                local item = containerItems:get(i);
                if item then 
                    local itemName = item:getName()
                    local dispCategory = item:getDisplayCategory()
                    local ammoType = item:getAmmoType()
                    --print(itemName) -- Gun Case
                    --print(item:getGunType())
                    --print(item:getDisplayCategory()) -- Ammo
                    --print(item:getDisplayName())
                    --print(item:getCategory())
                    --print(item:getAmmoType()) -- ~= nil 
                    if string.find(itemName, "Gun Case") or string.find(dispCategory, "Ammo") or ammoType ~= nil then
                        DebugLog.log("IScn::Removing "..itemName)
                        itemsToRemove[i] = item
                    end
                end
            end
            for k, itemToRemove in pairs(itemsToRemove) do
                c:Remove(itemToRemove)
            end
            itemsToRemove = {}
        end
    end
end        

ISCN.switchLight = function(x, y, z, onOff)

    DebugLog.log("IScn:switchLight: " ..x.." "..y.." "..z)
    local sq = getCell():getGridSquare(x, y, z);
    if sq then
        for i=0, sq:getObjects():size() -1 do
            local object = sq:getObjects():get(i);
            if instanceof(object, "IsoLightSwitch") and object:canSwitchLight() and object:isActivated() ~= onOff then
                --DebugLog.log(object)
                local args = { x = x, y = y, z = z}
                DebugLog.log("IScn:switchLight::Light Toggled " ..x.." "..y.." "..z)
                sendClientCommand(getPlayer(), 'object', 'toggleLight', args)
                break
            end
        end
    else
        DebugLog.log("Square not found "..x.." "..y.." "..z)
    end
end

ISCN.openDoor = function(x,y,z)

    
    local doorClosed = true
    local sq = getCell():getGridSquare(x, y, z);
    if sq then
        if sq then
            local door = sq:getIsoDoor();
            if door then
                door:getProperties():Set("forceLocked", "false")
                door:setLockedByKey(false);
                door:setLocked(false);
                door:ToggleDoorSilent();
                doorClosed = false;
            end
        end
    end
    if doorClosed == true then
        DebugLog.log("IScn::openDoor - Door Not Found " ..x.." "..y.." "..z)
    end 
end

ISCN.lockDoor = function(x, y, z)
    local key = -1
    local obj = nil
    local sq = getCell():getGridSquare(x, y, z);
    local doorLocked = false
    if sq then
        for i=0, sq:getObjects():size() -1 do
            obj = sq:getObjects():get(i);
            if instanceof(obj, "IsoDoor") then
                DebugLog.log("IScn::lockDoor "..x.." "..y.." "..z)  
                obj:getProperties():Set("forceLocked", "true")
                obj:setLocked(true);
                doorLocked = true
                return obj, key;
            end
        end
    else
        DebugLog.log("Square not found "..x.." "..y.." "..z)       
    end
    if doorLocked == false then
        DebugLog.log("IScn::lockDoor - Door Not Found " ..x.." "..y.." "..z)
    end
end

ISCN.unlockDoor = function(x, y, z)
    local doorLocked = true
    local sq = getCell():getGridSquare(x, y, z);
    if sq then
        for i=0, sq:getObjects():size() -1 do
            local obj = sq:getObjects():get(i);
            if instanceof(obj, "IsoDoor") then
                DebugLog.log("IScn::unlockDoor "..x.." "..y.." "..z)
                obj:getProperties():Set("forceLocked", "false")
                obj:setLockedByKey(false);
                obj:setLocked(false);
                doorLocked = false;
                return obj;
            end
        end
    else
        DebugLog.log("Square not found "..x.." "..y.." "..z)       
    end
    if doorLocked == true then
        DebugLog.log("IScn::unlockDoor - Door Not Found " ..x.." "..y.." "..z)
    end    
end

ISCN.fixBarricade = function(_x, _y, _z)    

    local sq = getCell():getGridSquare(_x, _y, _z)
    if sq then
        for i = 0, sq:getObjects():size()-1 do
            local barricadeable = sq:getObjects():get(i);   
            if instanceof(barricadeable, "BarricadeAble") then
                sendClientCommand(getPlayer(), "ISCNmodule", "ISCN_FixBarricades", {
                    x = barricadeable:getX(),
                    y = barricadeable:getY(),
                    z = barricadeable:getZ(),
                    index = barricadeable:getObjectIndex(),
                });
                break;
            end
        end
    end
end

---@param _command string
---@param _player IsoPlayer
---@param _barricadeable IsoDoor|IsoWindow|IsoThumpable
---@param _plankNumber integer
---@param _plankHealthMult float
function ISCN.BarricadeCommand(_command, _player, _barricadeable, _plankNumber, _plankHealthMult)
    if not _command then _command = "ISCN_BarricadePlayerSide" end
    if not _player then _player = getPlayer() end
    if not _plankNumber then _plankNumber = 1 end
    if not _plankHealthMult then _plankHealthMult = 1.0 end

    sendClientCommand(_player, "ISCNmodule", _command, {
        x = _barricadeable:getX(),
        y = _barricadeable:getY(),
        z = _barricadeable:getZ(),
        index = _barricadeable:getObjectIndex(),
        plankNumber = _plankNumber,
        plankHealthMult = _plankHealthMult,
    });
end

ISCN.addBarricade = function(x, y, z, num, faceAway, healthMult)    
    healthMult = healthMult or 1.0
    
    local objFound = false
    local sq = getCell():getGridSquare(x, y, z)
    if sq then
        for i = 0, sq:getObjects():size()-1 do
            local o = sq:getObjects():get(i);            
            if instanceof(o, "BarricadeAble") then
                local command = nil
                --command = "ISCN_BarricadeBothSides"
                if faceAway then
                    command = "ISCN_BarricadeOppositePlayerSide"
                else
                    command = "ISCN_BarricadePlayerSide"
                end
                ISCN.BarricadeCommand(command, getPlayer(), o, num, healthMult)
                objFound = true             
                break;
            end
        end
    else
        DebugLog.log("Square not found "..x.." "..y.." "..z)
    end
    if objFound == false then
        DebugLog.log("IScn::addBarricade - Obj Not Found " ..x.." "..y.." "..z)
    end
end

ISCN.GetBuildingRooms = function(pl)
    local buildingRooms = {};

    local buildingDef = pl:getCurrentBuildingDef();
    if buildingDef == nil then return nil; end

    local arrayOfRooms = buildingDef:getRooms();
    for i = 0, arrayOfRooms:size()-1 do
        local currentRoom = arrayOfRooms:get(i);
        local currentIsoRoom = currentRoom:getIsoRoom();
        table.insert(buildingRooms, currentIsoRoom)
    end

    return buildingRooms;
end

ISCN.GetBuildingGridSquares = function(rooms)
    local buildingGridSquares = {};
    for key,value in pairs(rooms) do
        local currentRoom = value;
        local currentRoomSquares = currentRoom:getSquares(); -- This gives us a LIST of all the room squares.
        for i = 0, currentRoomSquares:size()-1 do
            local currentRoomSquare = currentRoomSquares:get(i)
            table.insert(buildingGridSquares, currentRoomSquare);
        end
    end
    return buildingGridSquares;
end

ISCN.CreateZombieBody = function(x, y, z, outfit, male, direction, reanimate, reanimateHourOffset, fakeDead, crawling)
    male = male or nil
    direction = direction or nil
    reanimate = reanimate or false
    reanimateHourOffset = reanimateHourOffset or 2
    fakeDead = fakeDead or true
    crawling = crawling or false

    if male == nil then
        if ZombRand(2) == 1 then
            male = true
        else
            male = false
        end
    end

    if direction == nil then
        local num = ZombRand(4)
        if num == 0 then
            direction = IsoDirections.W
        elseif num == 1 then
            direction = IsoDirections.E
        elseif num == 2 then
            direction = IsoDirections.S
        else
            direction = IsoDirections.N
        end
    end

    local zombie = createZombie(x, y, z, nil, 0, direction);
    while male ~= zombie:isFemale() do
        zombie:removeFromWorld();
        zombie:removeFromSquare();
        zombie = createZombie(x, y, z, nil, 0, direction);
    end
    if outfit == nil then
        zombie:dressInRandomOutfit()
    else
        zombie:dressInNamedOutfit(outfit)
    end
    --zombie:getVisual():setSkinTextureIndex(1 to 10 tested);
    --zombie:resetModelNextFrame();
    zombie:DoZombieInventory();
   
    for i=0, 20 do
        -- void addBlood(BloodBodyPartType part, boolean scratched, boolean bitten, boolean allLayers)
        zombie:addBlood(nil, false, true, true);
        zombie:addHole(nil, true);
        zombie:addDirt(nil, nil, true) -- Not Working?
    end    
    
    zombie:DoCorpseInventory()
    
	local inventory = zombie:getInventory()

    local weapons = inventory:getAllCategory("Weapon")
	for i=0, weapons:size() - 1 do
		local item = weapons:get(i)
        if not item:isHidden() then
            DebugLog.log("IScn:Weapon Condition Adjusted")
            item:setCondition(ZombRand(0,25), false)
		end
	end    
    
    local containers = inventory:getAllCategory("Container")
	for i=0, containers:size() - 1 do
		local item = containers:get(i)
        if not item:isHidden() then
            DebugLog.log("IScn:Removed Container")
            inventory:Remove(item)
		end
	end
    
    local body = IsoDeadBody.new(zombie, false);
        
    body:setX(x);
    body:setY(y);
    body:setZ(z);
        
    if reanimate then
        if reanimateHourOffset > 0 then
            body:reanimateLater() -- Reanimates Immediately
            body:setReanimateTime(GameTime:getInstance():getWorldAgeHours()+reanimateHourOffset) -- based on getWorldAgeHours(), Must be after reanimateLater()
        else
            body:reanimate() -- Reanimates instantly
        end
        body:setFakeDead(fakeDead)
        body:setCrawling(crawling)
    end

    return {zombie, body, direction}
end

ISCN.CreateZombieEater = function(zombieBody, x, y, z, outfit, distRelease, soundfile, distSound, distGiveUp, reanimate, reanimateHourOffset, fakeDead, crawling)
    distRelease = distRelease or 10
    soundfile = soundfile or nil
    distSound = distSound or 30
    distGiveUp = distGiveUp or 100000
    reanimate = reanimate or true
    reanimateHourOffset = reanimateHourOffset or 2
    fakeDead = fakeDead or false
    crawling = crawling or false
        
    local iscnModData = ModData.get("IScnData") -- Remove to optimize
    
    local zombieEater = addZombiesInOutfit(x, y, z, 1, outfit, 0):get(0);
       
    zombieEater:canBeDeletedUnnoticed(20000)
       
    -- if soundfile == nil then
        -- soundfile = "zombieeating"
        -- -- if zombieEater:isFemale() then
            -- -- soundfile = "PZ_FemaleZombieEating"
        -- -- else
            -- -- soundfile = "PZ_MaleZombieEating"
        -- -- end
    -- end
       
    zombieEater:setForceEatingAnimation(true);
    
    direction = zombieBody[3]
    local zX = nil
    local zY = nil
    local zZ = nil
    if direction == IsoDirections.N then
        zombieEater:setDir(IsoDirections.E);
        zX = x-0.9
        zY = y
        zZ = z
        zombieEater:setX(zX)
        zombieEater:setY(zY)
        zombieEater:setZ(zZ)         
        zombieEater:setX(x-0.9)
        zombieEater:setY(y)
        zombieEater:setZ(z)
    elseif direction == IsoDirections.S then
        zombieEater:setDir(IsoDirections.W);
        zX = x+0.5
        zY = y-0.5
        zZ = z
        zombieEater:setX(zX)
        zombieEater:setY(zY)
        zombieEater:setZ(zZ)
    elseif direction == IsoDirections.E then
        zombieEater:setDir(IsoDirections.N);
        zX = x-0.3
        zY = y+0.5
        zZ = z
        zombieEater:setX(zX)
        zombieEater:setY(zY)
        zombieEater:setZ(zZ)
    elseif direction == IsoDirections.W then
        zombieEater:setDir(IsoDirections.S);
        zX = x
        zY = y-0.6
        zZ = z
        zombieEater:setX(zX)
        zombieEater:setY(zY)
        zombieEater:setZ(zZ)      
    end
    
    local bX = zombieBody[2]:getX()
    local bY = zombieBody[2]:getY()
    local bZ = zombieBody[2]:getZ()
    
    table.insert(iscnModData.triggers, {
        {x, y, z, soundfile, zX, zY, zZ, distSound}, 
        {zombieEater, zX, zY, zZ, distRelease, distGiveUp}, 
        {zombieBody[2], bX, bY, bZ,
        reanimate, reanimateHourOffset, fakeDead, crawling}
        });
    
    return zombieEater;
end

ISCN.CreateOutfitZombies = function(x, y, z, totalZombies, outfit, femaleChance, isCrawler, 
    isFallOnFront, isFakeDead, isKnockedDown, health)
    --boolean isFakeDead, boolean isKnockedDown, float health)
    --addZombiesInOutfit(int x, int y, int z, int totalZombies, String outfit,
    --Integer femaleChance, boolean isCrawler, boolean isFallOnFront,
    --boolean isFakeDead, boolean isKnockedDown, float health)
    -- femaleChance 0 to 100
    
    local zombies = nil
    if isCrawler == nil then
        zombies = addZombiesInOutfit(x, y, z, totalZombies, outfit, femaleChance);
    else        
        zombies = addZombiesInOutfit(x, y, z, totalZombies, outfit, femaleChance,
            isCrawler, isFallOnFront, isFakeDead, isKnockedDown, health);
    end
    --addZombiesInOutfit(x, y, z, count, outfit, Integer femaleChance, crawler, isFallOnFront, isFakeDead, knockedDown, float health);
    --addZombiesInOutfit(12939, 2043, 2, 1, "Nurse", 100, true, false, true, true, 10); This Works, dead!
    --addZombiesInOutfit(12939, 2043, 2, 1, "Doctor", 100, true, true, true, true, 1); -- This WORKS dead!
    --addZombiesInOutfit(12941, 2043, 2, 1, "Doctor", 0, true, true, false, true, 1); -- This WORKS crawler
    --addZombiesInOutfit(12941, 2043, 2, 1, "Doctor", 0, false, false, true, false, 1); -- This WORKS standing!
    --addZombiesInOutfit(12941, 2043, 2, 1, "Doctor", 0, false, false, false, true, 10); -- This WORKS standing, turns into fakeDead when killed!
    --addZombiesInOutfit(12941, 2043, 2, 1, "Doctor", 0, false, false, false, false, 10); -- This WORKS standing, but won't turn into fakeDead when killed!        
        
    for zI=zombies:size()-1,0,-1 do
        local zombie = zombies:get(zI);
        if zombie then
            zombie:canBeDeletedUnnoticed(20000)
        end
    end
    
    return zombies
end

-------------------
--TESTING INFO
--------------------
-- Sounds
--PZ_FemaleBeingEaten_Death
--fscream1
--PZ_FemaleZombieEating
--PZ_MaleZombieEating

-------------------
--local zombieBody = addZombiesInOutfit(12940, 2043, 2, 1, "Party", 0):get(0);         
--zombieBody2:setBecomeCrawler(true) -- This is working
--zombieBody2:knockDown(false) -- This is working
--zombieBody2:setAlwaysKnockedDown(true)
-------------------
--local zombieBody = addZombiesInOutfit(12938, 2043, 2, 1, "Nurse", 0):get(0); 
--zombieBody:becomeCorpse()
--zombieBody:addRandomBloodDirtHolesEtc()    
--zombieBody:setDir(IsoDirections.S);
-------------------
--FUNCTIONS OF INTEREST
-------------------    
--void addZombieSitting(int x, int y, int z)
--void addZombiesEating(int x, int y, int z, int totalZombies, boolean skeletonBody)
--IsoDeadBody createRandomDeadBody(IsoGridSquare square, int blood) -- WORKS
--zombieBody:Kill(nil) -- Works
--Kill(IsoGameCharacter killer, boolean bGory)    
--setAlwaysKnockedDown(boolean alwaysKnockedDown)
--setCanWalk(boolean bCanStand)
--setForceFakeDead(boolean bForceFakeDead)
--void spotted(IsoMovingObject movingObject, boolean boolean1) -- Works!
--Wander() -- Maybe
--setReanimate(boolean reanimate)
--setReanimateTimer(float) - Does not work
--void setAsSurvivor() -- Didn't do anything    
--void setCrawler(boolean boolean1) -- Didn't work
--void setCrawlerType(int int1)
--void toggleCrawling() -- Didn't work
-- setReanimate(false) -- Didn't work
--addRandomVisualDamages()    
--boolean shouldGetUpFromCrawl()
--setSitAgainstWall(boolean boolean1) -- Didn't work        
--void setTarget(IsoMovingObject movingObject) -- Didn't work by itself
--void setTargetSeenTime(float float1)        
--void burnCorpse(IsoDeadBody deadBody)

ISCN.CreateSoundTrigger = function(x, y, z, soundfile, sX, sY, sZ, distSound)
    local iscnModData = ModData.get("IScnData") -- Remove to optimize
        
    table.insert(iscnModData.triggers, {{x, y, z, soundfile, sX, sY, sZ, distSound}, nil, nil});
end

ISCN.LoadTriggers = function()

    local iscnModData = ModData.get("IScnData")
    for i=#iscnModData.triggers,1,-1 do
        local zI = iscnModData.triggers[i]
        
        local triggerX = nil
        local triggerY = nil
        local triggerZ = nil
        local soundfile = nil
        local sX = nil
        local sY = nil
        local sZ = nil
        local distSound = nil

        local zombEater = nil
        local zX = nil
        local zY = nil
        local zZ = nil   
        local distRelease = nil   
        local distGiveUp = nil

        local zombieBody = nil
        local bX = nil
        local bY = nil
        local bZ = nil           
        local reanimate = nil
        local reanimateHourOffset = nil
        local fakeDead = nil
        local crawling = nil    
        
        local soundTable = zI[1]
        if soundTable ~= nil then
            triggerX = soundTable[1]
            triggerY = soundTable[2]
            triggerZ = soundTable[3]
            soundfile = soundTable[4]
            sX = soundTable[5]
            sY = soundTable[6]
            sZ = soundTable[7]
            distSound = soundTable[8]
        end
        
        local zombTable = zI[2]
        if zombTable ~= nil then
            zombEater = zombTable[1]
            zX = zombTable[2]
            zY = zombTable[3]
            zZ = zombTable[4]        
            distRelease = zombTable[5]        
            distGiveUp = zombTable[6]
        end
        
        local bodyTable = zI[3]
        if bodyTable ~= nil then
            zombieBody = bodyTable[1]
            bX = bodyTable[2]
            bY = bodyTable[3]
            bZ = bodyTable[4]           
            reanimate = bodyTable[5]
            reanimateHourOffset = bodyTable[6]
            fakeDead = bodyTable[7]
            crawling = bodyTable[8]
        end
                
        if zombTable ~= nil then
            local foundEater = false
            local foundBody = false
            local sq = getCell():getGridSquare(zX, zY, zZ);
            if sq ~= nil then
                zombieEater = sq:getZombie();
                if zombieEater ~= nil then
                    zombTable[1] = zombieEater
                    zombieEater:setForceEatingAnimation(true);
                    DebugLog.log("IScn::Found ZombEater " ..zX.." "..zY.." "..zZ)
                    foundEater = true
                end
            end

            local sq = getCell():getGridSquare(bX, bY, bZ);
            if sq ~= nil then                                
                local bodies = sq:getDeadBodys();
                for bI=bodies:size()-1,0,-1 do
                    local body = bodies:get(bI);
                    if body then
                        bodyTable[1] = body
                        DebugLog.log("IScn::Found ZombBody " ..bX.." "..bY.." "..bZ)
                        foundBody = true
                    end
                end
            end

            if foundEater == false or foundBody == false then
                DebugLog.log("IScn::Trigger not loaded " ..bX.." "..bY.." "..bZ)
                table.remove(iscnModData.triggers, i)
            end            
        end
    end
end

ISCN.OnPlayerMove = function(pl)

    local x = math.floor(pl:getX())
    local y = math.floor(pl:getY())
    local z = math.floor(pl:getZ())

    local iscnModData = ModData.get("IScnData")
    for i=#iscnModData.triggers,1,-1 do
        local zI = iscnModData.triggers[i]

        local triggerX = nil
        local triggerY = nil
        local triggerZ = nil
        local soundfile = nil
        local sX = nil
        local sY = nil
        local sZ = nil
        local distSound = nil

        local zombEater = nil
        local zX = nil
        local zY = nil
        local zZ = nil   
        local distRelease = nil   
        local distGiveUp = nil

        local zombieBody = nil
        local bX = nil
        local bY = nil
        local bZ = nil           
        local reanimate = nil
        local reanimateHourOffset = nil
        local fakeDead = nil
        local crawling = nil    
        
        local soundTable = zI[1]
        if soundTable ~= nil then
            triggerX = soundTable[1]
            triggerY = soundTable[2]
            triggerZ = soundTable[3]
            soundfile = soundTable[4]
            sX = soundTable[5]
            sY = soundTable[6]
            sZ = soundTable[7]
            distSound = soundTable[8]
        end
        
        local zombTable = zI[2]
        if zombTable ~= nil then
            zombEater = zombTable[1]
            zX = zombTable[2]
            zY = zombTable[3]
            zZ = zombTable[4]        
            distRelease = zombTable[5]        
            distGiveUp = zombTable[6]
        end
        
        local bodyTable = zI[3]
        if bodyTable ~= nil then
            zombieBody = bodyTable[1]
            bX = bodyTable[2]
            bY = bodyTable[3]
            bZ = bodyTable[4]           
            reanimate = bodyTable[5]
            reanimateHourOffset = bodyTable[6]
            fakeDead = bodyTable[7]
            crawling = bodyTable[8]
        end  
               
        if zombTable == nil then
            -- Environmental Sound Only
            distGiveUp = 10000
            dist = IsoUtils.DistanceTo(x,y,z,triggerX,triggerY,triggerZ)
            if (dist < distSound and z == triggerZ) then
                DebugLog.log("IScn:Playing soundfile "..soundfile)
                --zombEater:getEmitter():playSound(soundfile)
                getWorld():getFreeEmitter():playSound(soundfile, sX, sY, sZ)
                table.remove(iscnModData.triggers, i)    
            elseif dist > distGiveUp then
                table.remove(iscnModData.triggers, i)    
            end
        else
            local dist = pl:getDistanceSq(zombEater)
        
            if soundfile ~= nil and distSound ~= nil then
                if dist < distSound and z == triggerZ then
                    DebugLog.log("IScn:Playing soundfile "..soundfile)
                    getWorld():getFreeEmitter():playSound(soundfile, zombEater:getX(), zombEater:getY(), zombEater:getZ())                
                    soundTable[4] = nil -- Play sound only once
                end
            elseif (dist < distRelease and z == triggerZ) or dist > distGiveUp then
                
                zombEater:setForceEatingAnimation(false);
                
                if reanimate then
                    if reanimateHourOffset > 0 then
                        zombieBody:reanimateLater() -- Reanimates Immediately
                        zombieBody:setReanimateTime(GameTime:getInstance():getWorldAgeHours()+reanimateHourOffset) -- based on getWorldAgeHours(), Must be after reanimateLater()
                    else
                        zombieBody:reanimate() -- Reanimates instantly
                    end
                    zombieBody:setFakeDead(fakeDead)
                    zombieBody:setCrawling(crawling)
                end                
                
                DebugLog.log("IScn:Releasing Zombie " ..zX.." "..zY.." "..zZ.." "..dist)
                table.remove(iscnModData.triggers, i)
            end
        end
    end
     
    if #iscnModData.triggers == 0 then
        DebugLog.log("IScn: Finished Zombie Triggers")
        Events.OnPlayerMove.Remove(ISCN.OnPlayerMove)
    end
end

-- These are the settings.
IScnModOptions = {
  options = { 
    easyMode = false,
    normalMode = true,
    hardMode = false,
  },
  names = {
    easyMode = "Easy",
    normalMode = "Normal",
    hardMode = "Hard",
  },
  mod_id = "ImmersiveScenarios",
  mod_shortname = "Immersive Scenarios",
}

-- Connecting the settings to the menu, so user can change them.
if ModOptions and ModOptions.getInstance then
    ModOptions:getInstance(IScnModOptions)

    local opt1 = IScnModOptions.options_data.easyMode
    local opt2 = IScnModOptions.options_data.normalMode
    local opt3 = IScnModOptions.options_data.hardMode

    opt2:set(true)

    function opt1:onUpdate(val)
        if val then
          opt2:set(false) -- disable the second option if the first option is set
          opt3:set(false) -- disable the third option if the first option is set
        end
    end
    
    function opt2:onUpdate(val)
        if val then
          opt1:set(false) -- disable the first option if the second option is set
          opt3:set(false) -- disable the third option if the second option is set
        end
    end

    function opt3:onUpdate(val)
        if val then
          opt1:set(false) -- disable the first option if the third option is set
          opt2:set(false) -- disable the second option if the third option is set
        end
    end

end

-- Check actual options at game loading.
Events.OnGameStart.Add(function()
    DebugLog.log("Easy Mode = "..  tostring(IScnModOptions.options.easyMode))
    DebugLog.log("Normal Mode = ".. tostring(IScnModOptions.options.normalMode))
    DebugLog.log("Hard Mode = ".. tostring(IScnModOptions.options.hardMode))
end)

local orig_clickPlay = NewGameScreen.clickPlay
-- Override to enable Sandbox Options
function NewGameScreen:clickPlay()
    self:setVisible(false);

    MainScreen.instance.charCreationProfession.previousScreen = "NewGameScreen";
    getWorld():setGameMode(self.selectedItem.mode);

    MainScreen.instance:setDefaultSandboxVars()

    if self.selectedItem.mode == "Challenge" then
        getWorld():setDifficulty("Hardcore");
        LastStandData.chosenChallenge = self.selectedItem.challenge;
        
        if LastStandData.chosenChallenge and LastStandData.chosenChallenge.enableSandbox == true then                     
            local worldName = LastStandData.chosenChallenge.id.."-"..ZombRand(100000)..ZombRand(100000)..ZombRand(100000)..ZombRand(100000);
            doChallenge(self.selectedItem.challenge);
            getWorld():setWorld(sanitizeWorldName(worldName));
            
            local globalChallenge = LastStandData.chosenChallenge;
            globalChallenge.OnInitWorld();
            --Events.OnGameStart.Add(globalChallenge.OnGameStart); -- Direct call. Normally called by OnInitWorld()
            
            getWorld():setMap("DEFAULT")
            MainScreen.instance.createWorld = true                  
            MapSpawnSelect.instance:useDefaultSpawnRegion()
            
            getWorld():setGameMode("Sandbox")
            MainScreen.instance.sandOptions:setVisible(true, self.joyfocus)
    
            return
        end
    end

    orig_clickPlay(self)
end

local orig_onOptionMouseDown = SandboxOptionsScreen.onOptionMouseDown
-- Override to back button for Sandbox Options
function SandboxOptionsScreen:onOptionMouseDown(button, x, y)

    if button.internal == "BACK" and LastStandData.chosenChallenge and LastStandData.chosenChallenge.enableSandbox == true then
        Events.OnInitGlobalModData.Remove(IScnHospital.OnInitGlobalModData);   
        Events.OnInitGlobalModData.Remove(IScnHunting.OnInitGlobalModData);        
        self:setVisible(false);
        MainScreen.instance.soloScreen:setVisible(true, self.joyfocus)
    else
        orig_onOptionMouseDown(self, button, x, y)
    end 
    
end
