
IScnHospital = {}

IScnHospital.Add = function()
    addChallenge(IScnHospital);
end

IScnHospital.OnGameStart = function()

    --check if it's a new game  
    iscnModData = getPlayer():getModData(); 
    if iscnModData.startconditionsset == nil and getPlayer():getHoursSurvived() <=1 then
        Events.OnGameStart.Add(IScnHospital.OnNewGame);
    end

end

IScnHospital.OnNewGame = function()

        IScnHospital.DifficultyCheck();

        local pl = getPlayer();
        local inv = pl:getInventory();
        local playerName = pl:getDescriptor():getForename()

        --Remove all clothes and give player a hospital gown and socks
        pl:clearWornItems();
        pl:getInventory():clear();
        inv:AddItem("Base.KeyRing");
        clothes = inv:AddItem("Base.HospitalGown");
        pl:setWornItem(clothes:getBodyLocation(), clothes);
        clothes = inv:AddItem("Base.Socks_Ankle");
        pl:setWornItem(clothes:getBodyLocation(), clothes);

        --Set stats 
        pl:getStats():setDrunkenness(50+iscnModData.drunkmodifier); -- 0 to 100
        pl:getStats():setThirst(0.25); -- from 0 to 1
        pl:getStats():setHunger(0.25); -- from 0 to 1
        pl:getStats():setFatigue(0.25); -- from 0 to 1

        IScnHospital.ApplyInjuries();
        IScnHospital.AddZombies();

        print("IScn Difficulty Finished")

        IScnHospital.addBarricade(12931, 2043, 2, 4, true); -- Spawn Room
        IScnHospital.unlockDoor(12931, 2043, 2); -- Spawn Room
        
        IScnHospital.addBarricade(12949, 2013, 0, 2, false);
        IScnHospital.addBarricade(12950, 2013, 0, 2, false);
        
        IScnHospital.addBarricade(12941, 2036, 1, 2, false);        
        IScnHospital.addBarricade(12941, 2037, 1, 2, false);
        IScnHospital.addBarricade(12927, 2036, 1, 2, true);

        IScnHospital.addBarricade(12931, 2017, 2, 2, false);        
        IScnHospital.addBarricade(12930, 2017, 2, 2, false);
        
        IScnHospital.addBarricade(12944, 2042, 2, 1, true);
        
        IScnHospital.addBarricade(12946, 2023, 1, 2, true);
        IScnHospital.addBarricade(12946, 2022, 1, 2, true);

        IScnHospital.addBarricade(12941, 2043, 1, 2, false);
        IScnHospital.addBarricade(12941, 2044, 1, 2, false);
        
        IScnHospital.addBarricade(12937, 2089, 0, 4, false);
        IScnHospital.addBarricade(12938, 2089, 0, 3, false);
        
        IScnHospital.addBarricade(12948, 2089, 0, 2, false);
        IScnHospital.addBarricade(12949, 2089, 0, 2, false);

        IScnHospital.addBarricade(12984, 2023, 0, 2, false);
        IScnHospital.addBarricade(12984, 2024, 0, 2, false);
        
        IScnHospital.addBarricade(12984, 2031, 0, 2, false);
        IScnHospital.addBarricade(12984, 2032, 0, 2, false);
        
        IScnHospital.addBarricade(12965, 2017, 0, 2, true); 
        IScnHospital.addBarricade(12966, 2017, 0, 2, true);        

        door, key = IScnHospital.lockDoor(12931, 2035, 2) -- +6
        door, key = IScnHospital.lockDoor(12931, 2038, 2)        
        door, key = IScnHospital.lockDoor(12958, 2037, 2)
        door, key = IScnHospital.lockDoor(12924, 2028, 2)        
        door, key = IScnHospital.lockDoor(12948, 2057, 2)
        
        door, key = IScnHospital.lockDoor(12930, 2048, 1) -- +3
        door, key = IScnHospital.lockDoor(12973, 2023, 1)
        door, key = IScnHospital.lockDoor(12971, 2017, 1)
        door, key = IScnHospital.lockDoor(12957, 2013, 1)
        door, key = IScnHospital.lockDoor(12931, 2050, 1)
        
        door, key = IScnHospital.lockDoor(12955, 2046, 0)
        
        door, key = IScnHospital.lockDoor(12968, 2018, 0)
        
        door, key = IScnHospital.lockDoor(12960, 2026, 0)

        print("IScn Doors Locked")

        local sq = getCell():getGridSquare(12925, 2041, 2);
        if sq ~= nil then
            local sheet = InventoryItemFactory.CreateItem("Base.Sheet")
            sq:AddWorldInventoryItem(sheet, 0, 0, 0.35)
        end

        local sq = getCell():getGridSquare(12923, 2044, 2);
        if sq ~= nil then
            local hammer = sq:AddWorldInventoryItem("Base.Hammer", 0.9, 0.9, 0.5);
            hammer:setCondition(1);
        end

        local sq = getCell():getGridSquare(12926, 2040, 2);
        if sq ~= nil then
            sq:AddWorldInventoryItem("Base.WaterBottleEmpty", 0.9, 0.7, 0.40);
        end

        local sq = getCell():getGridSquare(12923, 2042, 2);
        if sq ~= nil then
            local apple = sq:AddWorldInventoryItem("Base.Apple", 0.9, 0.9, 0.45);
            apple:setAge(75);                    
            --sq:AddWorldInventoryItem("Base.ButterKnife", 0.9, 0.9, 0.40);
            --sq:AddWorldInventoryItem("Base.Fork", 0.9, 0.9, 0.37);
            --sq:AddWorldInventoryItem("Base.Spoon", 0.9, 0.9, 0.35);
            --sq:AddWorldInventoryItem("Base.Plate", 0.7, 0.9, 0.37);            
            
            --sq:AddWorldInventoryItem("Base.ButterKnife", 0, 0, 0.25);
            --sq:AddWorldInventoryItem("Base.Fork", 0, 0, 0.25);
            --sq:AddWorldInventoryItem("Base.Spoon", 0, 0, 0.25);
            --sq:AddWorldInventoryItem("Base.Plate", 0, 0, 0.25);            
        end

        local sq = getCell():getGridSquare(12929, 2043, 2);
        if sq ~= nil then
            local body = createRandomDeadBody(sq, 10);
            if body:isFemale() then
                familyName = "Aunt Jane"
            else
                familyName = "Uncle Rob"
            end
            
            local c = body:getContainer();
            for i = 0, 3 do
                c:AddItem("Base.Nails");
            end
            local gun = sq:AddWorldInventoryItem("Base.Revolver", 0.9, 0.9, 0.5)
            gun:setCondition(0);
        end

        local sq = getCell():getGridSquare(12928, 2043, 2);
        if sq ~= nil then
            local noteBook = sq:AddWorldInventoryItem("Base.Journal", 0.5, 0.5, 0);
            noteBook:setCanBeWrite(true);
        
            noteBook:addPage(1, "Day 0:\n\nDear Diary,\nI'm on my way to see my family in Louisville after a year. It's a long 8 hour drive through the night, but I should be able to manage. Can't wait to see them all, especially the little ones.");
            noteBook:addPage(2, "Day 1:\n\n"..playerName.." you must have fallen asleep at the wheel and crashed. It was bad and you almost didn't make it. You've been in a coma for a week already. I feel terrible. I've been staying next to you hoping you will wake up. I'm sorry for writing in your journal, but hopefully you will appreciate it.\n\n-"..familyName);
            noteBook:addPage(3, "Day 2:\n\nIt has been a strange day. Traffic was unusually light and there was a crowd of people at the hospital reception. Some of the family couldn't come visit you because they caught the flu. I think I'll stay the night in your room and keep you company.\n\n-"..familyName);
            noteBook:addPage(4, "Day 3:\n\nThis is crazy. The radio and TV broadcasts have been telling everyone to stay indoors and quarantine. Apparently there is a new highly contagious disease that has been spreading. I'll stay overnight again and make sure you are taken care of. This is scary.\n\n-"..familyName)
            noteBook:addPage(5, "Day 4:\n\nToday the air is heavy with an odd, sour smell, like a mix of dampness and decay. It is eerie, to say the least. I keep looking through the window, hoping for some reassurance, but all I see are empty streets.\n\n-"..familyName);
            noteBook:addPage(6, "Day 5:\n\nAnother day in the hospital. The smell seems to have intensified and there is chaos in the hospital with nurses and doctors running through the halls. I can't find anyone to talk to. I grabbed whatever food I could from the lunchroom and locked myself in your room. I've been hearing the odd screams coming from the hallways.\n\n-"..familyName)
            noteBook:addPage(7, "Day 6:\n\nThe sick people have become monsters. Maybe it's something like rabies. The halls are filled with screams and odd noises. I managed to break apart a chair and boarded up our room so they won't get us. My heart races every time I hear a nearby noise. I'm just waiting for the police or military or someone to save us.\n\n-"..familyName)
            noteBook:addPage(8, "Day 7:\n\nI've got it. Whatever everyone has, I've got it. I have a fever and my eyesight is getting blurry. There are dozens of crazies in the hallway. I won't turn into them, I've seen what they do. I'm sorry. I'll see you in the next life.\n\n-"..familyName)
            noteBook:setName(playerName.."'s Journal");
        end            

        local sq = getCell():getGridSquare(12928, 2043, 2);
        if sq ~= nil then
            addBloodSplat(sq, 10, 1);
        end             
        
        local sq = getCell():getGridSquare(12926, 2040, 2);
        if sq ~= nil then
            local objs = sq:getObjects();
            for i = 0, objs:size()-1 do
                local o = objs:get(i);
                local c = o:getContainer();
                if c ~= nil then
                    print("Found a Countainer")
                    c:emptyIt(); 
                    c:AddItem("Base.Magazine");                    
                    c:setExplored(true);
                    break;
                end
            end
        end
        
        local clim = getClimateManager()
        
        local thunder = clim:getThunderStorm();
        thunder:triggerThunderEvent(12929, 2043, true, true, true)

        local dur = 48      
        clim:triggerCustomWeatherStage(WeatherPeriod.STAGE_HEAVY_PRECIP, dur);
        
        IScnHospital.switchLight(12936, 2050, 2, true) -- Spawn Room
        
        IScnHospital.switchLight(12934, 2030, 2, false)
        IScnHospital.switchLight(12941, 2016, 2, false)     
        IScnHospital.switchLight(12940, 2020, 2, false)     
        IScnHospital.switchLight(12952, 2021, 2, false) 
        IScnHospital.switchLight(12932, 2016, 2, false)     
        IScnHospital.switchLight(12927, 2016, 2, false)
        IScnHospital.switchLight(12929, 2029, 2, false)
        IScnHospital.switchLight(12930, 2049, 2, false)
        IScnHospital.switchLight(12930, 2059, 2, false)
        IScnHospital.switchLight(12930, 2044, 2, false)
        IScnHospital.switchLight(12934, 2030, 2, false)
        IScnHospital.switchLight(12923, 2074, 2, false)
        IScnHospital.switchLight(12935, 2035, 2, false)
        IScnHospital.switchLight(12933, 2024, 2, false)
        IScnHospital.switchLight(12944, 2024, 2, false)
        IScnHospital.switchLight(12947, 2065, 2, false)
        IScnHospital.switchLight(12950, 2057, 2, false)
        
        --local allRooms = IScnHospital.GetBuildingRooms(pl);
        --local allBuildingGridSquares = IScnHospital.GetBuildingGridSquares(allRooms);
                                                    
        iscnModData.doAlarm = false       
        if iscnModData.hardMode then            
            iscnModData.doAlarm = true 
        end     
        
        -- This executes once at startup and every ten min
        Events.EveryTenMinutes.Add( IScnHospital.EveryTenMin );

        Events.OnGameStart.Add(IScnHospital.setSandBoxVars);
                
        iscnModData.startconditionsset = true;

end

IScnHospital.EveryTenMin = function()
    
    print("IScn::EveryTenMin")

    local pl = getPlayer();
    iscnModData = pl:getModData();

    iscnModData.minCounter = iscnModData.minCounter + 10;   

    local clim = getClimateManager()
    local thunder = clim:getThunderStorm();
    thunder:triggerThunderEvent(12929, 2043, true, true, true)

    if iscnModData.minCounter > iscnModData.timeUntilPower then
    
        -- Restore Power                
        print("IScn::Restoring Power")
        
        local sandbox = getSandboxOptions()
        local elecShutModifier = iscnModData.sandboxCopy:getOptionByName("ElecShutModifier"):getValue()         
        sandbox:set("ElecShutModifier", elecShutModifier)
        sandbox:toLua()
        sandbox:applySettings()

        pl:playSound("LightFlicker");

    elseif iscnModData.minCounter > iscnModData.timeUntilPower+10 then

        if iscnModData.doAlarm then
            plbuilding:getDef():setAlarmed(true);
        end

        Events.EveryTenMinutes.Remove(IScnHospital.EveryTenMin)
    end
    
end

IScnHospital.switchLight = function(x, y, z, onOff)

    print("switchLight: " ..x.." "..y.." "..z)
    local sq = getCell():getGridSquare(x, y, z);
    if sq then
        for i=0, sq:getObjects():size() -1 do
            local object = sq:getObjects():get(i);
            --if instanceof(object, "IsoLightSwitch") and object:canSwitchLight() and object:isActivated() then
            if instanceof(object, "IsoLightSwitch") and object:canSwitchLight() and object:isActivated() ~= onOff then
                --print(object)
                local args = { x = x, y = y, z = z}
                print("switchLight::Light Toggled " ..x.." "..y.." "..z)
                sendClientCommand(getPlayer(), 'object', 'toggleLight', args)           
                
                --if object:hasLightBulb() then
                    --print("turnOffLights::Bulb Removed " ..x.." "..y.." "..z)
                    --ISTimedActionQueue.add(ISLightActions:new("RemoveLightBulb",getPlayer(), object));                        
                --end
                
                break
            end
        end
    else
        print("Square not found "..x.." "..y.." "..z)
    end
end

IScnHospital.openDoor = function(x,y,z, north)
    
    local doorLocked = true
    local sq = getCell():getGridSquare(x, y, z);
    if sq then
        if sq and sq:getDoor(north) then
            --local door = sq:getDoor(north);
            obj:getProperties():Set("forceLocked", "false")
            --door:setLocked(false);
            --door:setLockedByKey(false);
            --door:ToggleDoorSilent();
        end
    end
    if doorLocked == true then
        print("IScn::openDoor - Door Not Found " ..x.." "..y.." "..z)
    end 
end

IScnHospital.lockDoor = function(x, y, z)
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
                --end             
                obj:getProperties():Set("forceLocked", "true")
                --local door = sq:getDoor(north);
                --obj:setLockedByKey(door:isLocked());
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

IScnHospital.unlockDoor = function(x, y, z)
    local doorLocked = true
    local sq = getCell():getGridSquare(x, y, z);
    if sq then
        for i=0, sq:getObjects():size() -1 do
            local obj = sq:getObjects():get(i);
            if instanceof(obj, "IsoDoor") then
                obj:getProperties():Set("forceLocked", "false")
                obj:setLocked(false);
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

IScnHospital.addBarricade = function(x, y, z, num, faceAway)
    local objFound = false
    local sq = getCell():getGridSquare(x, y, z)
    if sq then
        for i = 0, sq:getObjects():size()-1 do
            local o = sq:getObjects():get(i);
            if instanceof(o, "IsoWindow") then
                o:addBarricadesDebug(ZombRand(2,5), false);
                break;
            end
            if instanceof(o, "IsoDoor") then
                print("IScn::BarricadeDoor")
                for i=0, num-1 do
                    local barricade = IsoBarricade.AddBarricadeToObject(o, faceAway)
                    local plank = InventoryItemFactory.CreateItem('Base.Plank')
                    barricade:addPlank(getPlayer(), plank)
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

function IScnHospital.GetBuildingRooms(_player)
    local buildingRooms = {};

    local buildingDef = _player:getCurrentBuildingDef();
    if buildingDef == nil then return nil; end

    local arrayOfRooms = buildingDef:getRooms();
    for i = 0, arrayOfRooms:size()-1 do
        local currentRoom = arrayOfRooms:get(i);
        local currentIsoRoom = currentRoom:getIsoRoom();
        table.insert(buildingRooms, currentIsoRoom)
    end

    return buildingRooms;
end

function IScnHospital.GetBuildingGridSquares(_allRooms)
    local buildingGridSquares = {};
    for key,value in pairs(_allRooms) do
        local currentRoom = value;
        local currentRoomSquares = currentRoom:getSquares(); -- This gives us a LIST of all the room squares.
        for i = 0, currentRoomSquares:size()-1 do
            local currentRoomSquare = currentRoomSquares:get(i)
            table.insert(buildingGridSquares, currentRoomSquare);
        end
    end
    return buildingGridSquares;
end

IScnHospital.DifficultyCheck = function()
    ModOptions:getInstance(IScnModOptions)
    local pl = getPlayer();
	iscnModData = pl:getModData();
    
    if ModOptions and ModOptions.getInstance then
        iscnModData.easyMode = IScnModOptions.options.easyMode
        iscnModData.normalMode = IScnModOptions.options.normalMode
        iscnModData.hardMode = IScnModOptions.options.hardMode
    end  
    
    if IScnModOptions.options.easyMode == nil then
        IScnModOptions.options.easyMode = false;
    end
    if IScnModOptions.options.normalMode == nil then
        IScnModOptions.options.normalMode = false;
    end
    if IScnModOptions.options.hardMode == nil then
        IScnModOptions.options.hardMode = false;
    end 

    if IScnModOptions.options.easyMode and IScnModOptions.options.normalMode and IScnModOptions.options.hardMode then
        IScnModOptions.options.normalMode = true;   
    end

    if iscnModData.easyMode then
        iscnModData.easyMode = true;
        iscnModData.normalMode = false;
        iscnModData.hardMode = false;
    elseif iscnModData.hardMode then
        iscnModData.easyMode = false;
        iscnModData.normalMode = false;
        iscnModData.hardMode = true;
    else
        iscnModData.easyMode = false;
        iscnModData.normalMode = true;
        iscnModData.hardMode = false;
    end

    iscnModData.minCounter = 0;

    if iscnModData.easyMode then
        iscnModData.difficultymodifier = 0;
        iscnModData.injurytimemodifier = 0;
        iscnModData.drunkmodifier = 0;
        iscnModData.timeUntilPower = 90;
    elseif iscnModData.hardMode then
        iscnModData.normalMode = false;
        iscnModData.difficultymodifier = ZombRand(10,20);
        iscnModData.injurytimemodifier = ZombRand(10,30);
        iscnModData.drunkmodifier = 50;
        iscnModData.timeUntilPower = 360;
    else
        iscnModData.difficultymodifier = ZombRand(5,10);
        iscnModData.injurytimemodifier = ZombRand(10,20);
        iscnModData.drunkmodifier = 25;
        iscnModData.timeUntilPower = 720;
    end

end

IScnHospital.ApplyInjuries = function() 
    local pl = getPlayer();
    iscnModData = pl:getModData();

    damage = 30 + iscnModData.difficultymodifier;
    injurytime = 35 + iscnModData.injurytimemodifier;

    if iscnModData.normalMode or iscnModData.hardMode then
        print("Adding Leg Injury")
        -- leg injury
        local leg = ZombRand(4)+1;
        if leg == 1 then
            pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):AddDamage(damage);
            pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):setFractureTime(injurytime);
            pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):setSplint(true, .8);
            pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):setBandaged(true, 5, true, "Base.AlcoholBandage");
        elseif leg == 2 then
            pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):AddDamage(damage);
            pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):setFractureTime(injurytime);
            pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):setSplint(true, .8);
            pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):setBandaged(true, 5, true, "Base.AlcoholBandage");
        elseif leg == 3 then
            pl:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):AddDamage(damage);
            pl:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):setFractureTime(injurytime);
            pl:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):setSplint(true, .8);
            pl:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):setBandaged(true, 5, true, "Base.AlcoholBandage");
        elseif leg == 4 then
            pl:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):AddDamage(damage);
            pl:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):setFractureTime(injurytime);
            pl:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):setSplint(true, .8);
            pl:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):setBandaged(true, 5, true, "Base.AlcoholBandage");
        end
    end
    
    local arm = ZombRand(2)+1;
    if iscnModData.normalMode then 
        print("Adding Secondary Arm Injury")
        -- arm injury       
        if arm == 1 then
            pl:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):AddDamage(damage);
            pl:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):setFractureTime(injurytime);
            pl:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):setSplint(true, .8);
            pl:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):setBandaged(true, 5, true, "Base.AlcoholBandage");
        else
            pl:getBodyDamage():getBodyPart(BodyPartType.LowerArm_L):AddDamage(damage);
            pl:getBodyDamage():getBodyPart(BodyPartType.LowerArm_L):setFractureTime(injurytime);
            pl:getBodyDamage():getBodyPart(BodyPartType.LowerArm_L):setSplint(true, .8);
            pl:getBodyDamage():getBodyPart(BodyPartType.LowerArm_L):setBandaged(true, 5, true, "Base.AlcoholBandage");
        end
    end
    
    if iscnModData.hardMode then
        print("Adding Primary Arm Injury")
        if arm == 1 then
            pl:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):AddDamage(damage);
            pl:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):setFractureTime(injurytime);
            pl:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):setSplint(true, .8);
            pl:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):setBandaged(true, 5, true, "Base.AlcoholBandage");
        else
            pl:getBodyDamage():getBodyPart(BodyPartType.LowerArm_R):AddDamage(damage);
            pl:getBodyDamage():getBodyPart(BodyPartType.LowerArm_R):setFractureTime(injurytime);
            pl:getBodyDamage():getBodyPart(BodyPartType.LowerArm_R):setSplint(true, .8);
            pl:getBodyDamage():getBodyPart(BodyPartType.LowerArm_R):setBandaged(true, 5, true, "Base.AlcoholBandage");
        end
    end
end

IScnHospital.AddZombies = function()    
        
    addZombiesInOutfit(12947, 2053, 2, 1, "Nurse", 0);          
        
    addZombiesInOutfit(12927, 2061, 2, 1, "Nurse", 0); 
    addZombiesInOutfit(12927, 2061, 2, 1, nil, 0); 
    
    addZombiesInOutfit(12947, 2042, 2, 1, "Nurse", 0); 
    addZombiesInOutfit(12947, 2042, 2, 1, nil, 0);
            
    addZombiesInOutfit(12932, 2010, 2, 1, "Doctor", 0);                 
    addZombiesInOutfit(12932, 2010, 2, 3, "Nurse", 0); 
    addZombiesInOutfit(12932, 2010, 2, 1, "HospitalPatient", 0);                 
            
    addZombiesInOutfit(12960, 2009, 2, 1, "Doctor", 0);             
    addZombiesInOutfit(12955, 2009, 2, 1, "HospitalPatient", 0);
    addZombiesInOutfit(12926, 2024, 2, 1, "Nurse", 0);
            
    addZombiesInOutfit(12954, 2024, 2, 3, nil, 0);              
            
    addZombiesInOutfit(12933, 2033, 1, 2, "Doctor", 0);
    addZombiesInOutfit(12933, 2033, 1, 3, "Nurse", 0); 
    addZombiesInOutfit(12933, 2033, 1, 6, "HospitalPatient", 0); 
            
    addZombiesInOutfit(12950, 2060, 1, 2, "Nurse", 0); 
    addZombiesInOutfit(12950, 2060, 1, 2, "HospitalPatient", 0);
    
    addZombiesInOutfit(12952, 2029, 1, 8, "OfficeWorker", 0);
    
    addZombiesInOutfit(12973, 2021, 1, 2, "OfficeWorkerSkirt", 0);
    
    addZombiesInOutfit(12942, 2011, 1, 3, nil, 0);
    
    addZombiesInOutfit(12928, 2026, 1, 2, "Doctor", 0);
    
    addZombiesInOutfit(12949, 2010, 0, 1, "Doctor", 0);                 
    addZombiesInOutfit(12949, 2010, 0, 2, "Nurse", 0); 
    addZombiesInOutfit(12949, 2010, 0, 2, "HospitalPatient", 0);        
    
    addZombiesInOutfit(12930, 2048, 0, 3, "OfficeWorker", 0);
            
    addZombiesInOutfit(12957, 2001, 0, 1, "Doctor", 0); 
    addZombiesInOutfit(12957, 2001, 0, 4, "HospitalPatient", 0); 
    addZombiesInOutfit(12957, 2001, 0, 6, nil, 0); 
    
    addZombiesInOutfit(12935, 2016, 0, 8, nil, 0); 
    
    addZombiesInOutfit(12974, 2015, 0, 4, nil, 0); 
    
    addZombiesInOutfit(12958, 2014, 0, 3, nil, 0); 
    
    addZombiesInOutfit(12959, 2008, 0, 2, "MallSecurity", 0); 
    addZombiesInOutfit(12952, 2048, 0, 2, "MallSecurity", 0); 
    
    addZombiesInOutfit(12931, 2066, 0, 1, "PharmacistM", 0); 
    
    addZombiesInOutfit(12946, 2053, 0, 1, "PharmacistM", 0); 
    addZombiesInOutfit(12945, 2049, 0, 1, "PharmacistM", 0); 
    addZombiesInOutfit(12946, 2059, 0, 6, nil, 0); 
    
    addZombiesInOutfit(12949, 2074, 0, 4, nil, 0); 

    addZombiesInOutfit(12966, 2029, 0, 4, "Doctor", 0);
    addZombiesInOutfit(12966, 2029, 0, 4, "Nurse", 0); 
    addZombiesInOutfit(12966, 2029, 0, 8, "HospitalPatient", 0);        

end

IScnHospital.setSandBoxVars = function()
    local options= {}
    
    pl = getPlayer();
    iscnModData = pl:getModData();
    local sandbox = getSandboxOptions()
    
    --start time is returned as the index of the list, not the time.
    --7 am is 1
    --9am is 2, noon is 3, 2 pm is 4, 5pm is 5, 9pm is 6, 12am is 7, 2am is 8,5am is 9
--  hourvalue = 7;
--  hourset = options:getOptionByName("StartTime"):getValue();
--  if hourset == 1 then return 
--  elseif hourset == 2 then hourvalue = 9;
--  elseif hourset == 3 then hourvalue = 12;
--  elseif hourset == 4 then hourvalue = 14;
--  elseif hourset == 5 then hourvalue = 17;
--  elseif hourset == 6 then hourvalue = 21;
--  elseif hourset == 7 then hourvalue = 0;
--  elseif hourset == 8 then hourvalue = 2;
--  else hourvalue = 5 ;
--  end 
    
    hourvalue = 21; -- Force Nighttime
    
    gt = getGameTime();
    gt:setTimeOfDay(hourvalue);
    --gt:setDay(sandbox:getOptionByName("StartDay"):getValue());
    --gt:setStartDay(sandbox:getOptionByName("StartDay"):getValue());
    --gt:setMonth(sandbox:getOptionByName("StartMonth"):getValue()-1);
    
    iscnModData.sandboxCopy = SandboxOptions.new()
    iscnModData.sandboxCopy:copyValuesFrom(sandbox) -- Save Sandbox
    
    print("ElecShutModifier: "..sandbox:getOptionByName("ElecShutModifier"):getValue())
    
    -- Turn off electricity temporarily
    sandbox:set("ElecShutModifier", -1)
    sandbox:toLua()
    sandbox:applySettings()
    
    print("ElecShutModifier: "..sandbox:getOptionByName("ElecShutModifier"):getValue())

end

-- Default LastStand functions below

IScnHospital.OnInitWorld = function()
        
    print("OnInit")
    Events.OnGameStart.Add(IScnHospital.OnGameStart);

end

IScnHospital.OnCreatePlayer = function()
end

IScnHospital.RemovePlayer = function(p)
end

IScnHospital.AddPlayer = function(p)
end

IScnHospital.Render = function()
end

local xcell = 43
local ycell = 6
local x = 20
local y = 236
local z = 2

-- map.six.ph
if z == 2 then
    x = x + 6;
    y = y + 6;
elseif z == 1 then
    x = x + 3;
    y = y + 3;
end

IScnHospital.id = "IScnHospital";
IScnHospital.image = "media/lua/client/LastStand/IScnHospital.png";
IScnHospital.gameMode = "IScnHospital";
IScnHospital.world = "Muldraugh, KY";
IScnHospital.xcell = xcell;
IScnHospital.ycell = ycell;
IScnHospital.x = x;
IScnHospital.y = y;
IScnHospital.z = z;
IScnHospital.enableSandbox = true;

IScnHospital.spawns = {
        {worldX = xcell, worldY = ycell, posX = x, posY = y, posZ = z}, 
}

IScnHospital.hourOfDay = 7;

Events.OnChallengeQuery.Add(IScnHospital.Add)