
ImmersiveScenarios = {}

ImmersiveScenarios.getContainer = function(x, y, z)
    print("IScn:getContainer: " ..x.." "..y.." "..z)
    local sq = getCell():getGridSquare(x, y, z);
    if sq ~= nil then
        local objs = sq:getObjects();
        for i = 0, objs:size()-1 do
            local o = objs:get(i);
            local c = o:getContainer();
            if c ~= nil then
                print("IScn::Found Container " ..x.." "..y.." "..z)
                return c;
            end
        end
    end
    return nil;
end

ImmersiveScenarios.switchLight = function(x, y, z, onOff)

    print("IScn:switchLight: " ..x.." "..y.." "..z)
    local sq = getCell():getGridSquare(x, y, z);
    if sq then
        for i=0, sq:getObjects():size() -1 do
            local object = sq:getObjects():get(i);
            if instanceof(object, "IsoLightSwitch") and object:canSwitchLight() and object:isActivated() ~= onOff then
                --print(object)
                local args = { x = x, y = y, z = z}
                print("IScn:switchLight::Light Toggled " ..x.." "..y.." "..z)
                sendClientCommand(getPlayer(), 'object', 'toggleLight', args)
                break
            end
        end
    else
        print("Square not found "..x.." "..y.." "..z)
    end
end

ImmersiveScenarios.openDoor = function(x,y,z, north)
    
    local doorClosed = true
    local sq = getCell():getGridSquare(x, y, z);
    if sq then
        if sq then
            local door = sq:getDoor(north);
            if door then
                obj:getProperties():Set("forceLocked", "false")
                obj:setLockedByKey(false);
                obj:setLocked(false);
                door:ToggleDoorSilent();
                doorClosed = false;
            end
        end
    end
    if doorClosed == true then
        print("IScn::openDoor - Door Not Found " ..x.." "..y.." "..z)
    end 
end

ImmersiveScenarios.lockDoor = function(x, y, z)
    local key = -1
    local obj = nil
    local sq = getCell():getGridSquare(x, y, z);
    local doorLocked = false
    if sq then
        for i=0, sq:getObjects():size() -1 do
            obj = sq:getObjects():get(i);
            if instanceof(obj, "IsoDoor") then
                print("IScn::lockDoor "..x.." "..y.." "..z)
                --local keyID = obj:checkKeyId()
                --if keyID == -1 then
                --  keyID = ZombRand(100000000)
                --  local key = InventoryItemFactory.CreateItem('Base.Key1')
                --  obj:setKeyId(keyID)
                    
                    --local buildingDef = getPlayer():getCurrentBuildingDef();
                    --local square = BuildingHelper.getFreeTileFromBuilding(buildingDef)
                    --square:AddWorldInventoryItem(key, 0.5, 0.5, 0);
                --  print("IScn::Generated Key")
                    --local door = sq:getDoor(north);
                    --obj:setLockedByKey(door:isLocked());                
                --end             
                obj:getProperties():Set("forceLocked", "true")
                obj:setLocked(true);
                doorLocked = true
                return obj, key;
            end
        end
    else
        print("Square not found "..x.." "..y.." "..z)       
    end
    if doorLocked == false then
        print("IScn::lockDoor - Door Not Found " ..x.." "..y.." "..z)
    end
end

ImmersiveScenarios.unlockDoor = function(x, y, z)
    local doorLocked = true
    local sq = getCell():getGridSquare(x, y, z);
    if sq then
        for i=0, sq:getObjects():size() -1 do
            local obj = sq:getObjects():get(i);
            if instanceof(obj, "IsoDoor") then
                print("IScn::unlockDoor "..x.." "..y.." "..z)
                obj:getProperties():Set("forceLocked", "false")
                obj:setLockedByKey(false);
                obj:setLocked(false);
                doorLocked = false;
                return obj;
            end
        end
    else
        print("Square not found "..x.." "..y.." "..z)       
    end
    if doorLocked == true then
        print("IScn::unlockDoor - Door Not Found " ..x.." "..y.." "..z)
    end    
end

ImmersiveScenarios.hardenWindow = function(x, y, z, healthMult)    
    healthMult = healthMult or 1.0
    
    local objFound = false
    local sq = getCell():getGridSquare(x, y, z)
    if sq then
        for i = 0, sq:getObjects():size()-1 do
            local o = sq:getObjects():get(i);            
            if instanceof(o, "IsoWindow") then        
                --local health = o:makeWindowInvincible)
                --print(o.MaxHealth)
                --print(o.Health)
                --mat:setCondition(health * healthMult)                
                print("IScn::hardenWindow "..x.." "..y.." "..z)
                print("Does not work yet")
                objFound = true             
                break;
            end
        end
    else
        print("Square not found "..x.." "..y.." "..z)
    end
    if objFound == false then
        print("IScn::hardenWindow - Obj Not Found " ..x.." "..y.." "..z)
    end
end

ImmersiveScenarios.addBarricade = function(x, y, z, num, faceAway, healthMult, material)    
    healthMult = healthMult or 1.0
    material = material or "Plank"
    
    local objFound = false
    local sq = getCell():getGridSquare(x, y, z)
    if sq then
        for i = 0, sq:getObjects():size()-1 do
            local o = sq:getObjects():get(i);            
            if instanceof(o, "BarricadeAble") then                
                for i=0, num-1 do
                    local barricade = IsoBarricade.AddBarricadeToObject(o, faceAway)
                    local mat = InventoryItemFactory.CreateItem('Base.'..material)
                    local health = mat:getCondition()
                    mat:setCondition(health * healthMult)
                    print("IScn::Barricade "..material.." "..mat:getCondition().." @"..x.." "..y.." "..z)
                    if material == 'MetalBar' then
                        barricade:addMetalBar(getPlayer(), mat)          
                    elseif material == 'SheetMetal' then
                        barricade:addMetal(getPlayer(), mat)          
                    else -- if material == 'Plank' then
                        if barricade:canAddPlank() then
                            barricade:addPlank(getPlayer(), mat)                    
                        end
                    end
                end
                objFound = true             
                break;
            end
        end
    else
        print("Square not found "..x.." "..y.." "..z)
    end
    if objFound == false then
        print("IScn::addBarricade - Obj Not Found " ..x.." "..y.." "..z)
    end
end

ImmersiveScenarios.GetBuildingRooms = function(pl)
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

ImmersiveScenarios.GetBuildingGridSquares = function(rooms)
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

ImmersiveScenarios.CreateZombieBody = function(x, y, z, outfit, male, direction, reanimate, reanimateHourOffset, fakeDead, crawling)
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
            print("IScn:Weapon Condition Adjusted")
            item:setCondition(ZombRand(0,25), false)
		end
	end    
    
    local containers = inventory:getAllCategory("Container")
	for i=0, containers:size() - 1 do
		local item = containers:get(i)
        if not item:isHidden() then
            print("IScn:Removed Container")
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

ImmersiveScenarios.CreateZombieEater = function(zombieBody, x, y, z, outfit, distRelease, soundfile, distSound, distGiveUp, reanimate, reanimateHourOffset, fakeDead, crawling)
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
    if direction == IsoDirections.N then
        zombieEater:setDir(IsoDirections.E);
        zombieEater:setX(x-0.9)
        zombieEater:setY(y)
        zombieEater:setZ(z)
    elseif direction == IsoDirections.S then
        zombieEater:setDir(IsoDirections.W);
        zombieEater:setX(x+0.5)
        zombieEater:setY(y-0.5)
        zombieEater:setZ(z)
    elseif direction == IsoDirections.E then
        zombieEater:setDir(IsoDirections.N);
        zombieEater:setX(x-0.3)
        zombieEater:setY(y+0.5)
        zombieEater:setZ(z)
    elseif direction == IsoDirections.W then
        zombieEater:setDir(IsoDirections.S);
        zombieEater:setX(x)
        zombieEater:setY(y-0.6)
        zombieEater:setZ(z)      
    end

    table.insert(iscnModData.triggerZombies, {zombieEater, x, y, z, soundfile, distSound, distRelease, distGiveUp, zombieBody[2], reanimate, reanimateHourOffset, fakeDead, crawling});
    
    return zombieEater;
end

ImmersiveScenarios.OnPlayerMove = function(pl)

    local x = math.floor(pl:getX())
    local y = math.floor(pl:getY())
    local z = math.floor(pl:getZ())

    local iscnModData = ModData.get("IScnData")
    for i=#iscnModData.triggerZombies,1,-1 do
        local zI = iscnModData.triggerZombies[i]
        local zombEater = zI[1]
        local triggerX = zI[2]
        local triggerY = zI[3]
        local triggerZ = zI[4]    
        local soundfile = zI[5]
        local distSound = zI[6]
        local distRelease = zI[7]        
        local distGiveUp = zI[8]
        local zombieBody = zI[9]
        local reanimate = zI[10]
        local reanimateHourOffset = zI[11]
        local fakeDead = zI[12]
        local crawling = zI[13]        
               
        if zombEater == nil then
            print("IScn:Trigger Error " ..triggerX.." "..triggerY.." "..triggerZ)
            table.remove(iscnModData.triggerZombies, i)
        else
            local dist = pl:getDistanceSq(zombEater)
        
            if soundfile ~= nil and distRelease == nil then
                -- Environmental Sound Only
                distGiveUp = 10000
                dist = IsoUtils.DistanceTo(x,y,z,triggerX,triggerY,triggerZ)
                if (distSound ~= nil and dist < distSound and z == triggerZ) or
                   (x == triggerX and y == triggerY and z == triggerZ) then
                    print("IScn:Playing soundfile "..soundfile)
                    zombEater:getEmitter():playSound(soundfile)
                    table.remove(iscnModData.triggerZombies, i)    
                elseif dist > distGiveUp then
                    table.remove(iscnModData.triggerZombies, i)    
                end                
            elseif soundfile ~= nil and distSound ~= nil then
                if dist < distSound and z == triggerZ then
                    print("IScn:Playing soundfile "..soundfile)
                    getWorld():getFreeEmitter():playSound(soundfile, zombEater:getX(), zombEater:getY(), zombEater:getZ())                
                    zI[5] = nil -- Play sound only once
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
                
                print("IScn:Releasing Zombie " ..triggerX.." "..triggerY.." "..triggerZ.." "..dist)
                table.remove(iscnModData.triggerZombies, i)
            end
        end
    end
     
    if #iscnModData.triggerZombies == 0 then
        print("IScn: Finished Zombie Triggers")
        Events.OnPlayerMove.Remove(ImmersiveScenarios.OnPlayerMove)
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
    print("Easy Mode = ", IScnModOptions.options.easyMode)
    print("Normal Mode = ", IScnModOptions.options.normalMode)
    print("Hard Mode = ", IScnModOptions.options.hardMode)
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
            local worldName = "IScnHospital-"..ZombRand(100000)..ZombRand(100000)..ZombRand(100000)..ZombRand(100000);
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
        self:setVisible(false);
        MainScreen.instance.soloScreen:setVisible(true, self.joyfocus)
    else
        orig_onOptionMouseDown(self, button, x, y)
    end 
    
end
