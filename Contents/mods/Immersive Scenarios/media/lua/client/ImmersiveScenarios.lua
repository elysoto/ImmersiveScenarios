
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
