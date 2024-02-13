
IScnHunting = {}

IScnHunting.Add = function()
    addChallenge(IScnHunting);
end

IScnHunting.OnGameStart = function()
        
    if ModData.exists("IScnData") == false then
        -- Scenario inactive
        print("IScn:Scenarios Inactive")
        return;
    end
    
    local iscnModData = ModData.get("IScnData")
    if iscnModData.id ~= IScnHunting.id then
        -- Scenario inactive
        print("IScn:"..IScnHunting.id.." Scenario Inactive")
        return;
    end
        
      --check if it's a new game      
    if iscnModData.startconditionsset ~= true and getPlayer():getHoursSurvived() <=1 then
        print("IScnHunting:OnGameStart - New Game")
        Events.OnGameStart.Add(IScnHunting.OnNewGame);
    elseif iscnModData.startconditionsset and iscnModData.scenarioFinished ~= true then        
        print("IScnHospital:Loading Scenario Event")
        ISCN.LoadTriggers();
    else
        print("IScnHunting:Unknown Condition")
    end

end

IScnHunting.OnNewGame = function(player, square)

        print("IScnHunting:New Game Scenario Event")

        IScnHunting.DifficultyCheck();

        local pl = getPlayer();
        local inv = pl:getInventory();
        local iscnModData = ModData.get("IScnData")
        iscnModData.playerName = pl:getDescriptor():getForename()
        
        iscnModData.hourOffset = IScnHunting.hourOfDay - 7

        --Remove all clothes and give player a hospital gown and socks
        pl:clearWornItems();
        pl:getInventory():clear();
        inv:AddItem("Base.KeyRing");
        inv:AddItem("Base.Belt");
        local clothes = inv:AddItem("Base.Vest_Hunting_Orange");
        pl:setWornItem(clothes:getBodyLocation(), clothes);
        clothes = inv:AddItem("Base.Socks_Ankle");
        pl:setWornItem(clothes:getBodyLocation(), clothes);
        clothes = inv:AddItem("Base.Shirt_CamoGreen");
        pl:setWornItem(clothes:getBodyLocation(), clothes);
        clothes = inv:AddItem("Base.Shorts_CamoGreenLong");
        pl:setWornItem(clothes:getBodyLocation(), clothes);
        clothes = inv:AddItem("Base.Shoes_BlackBoots");
        pl:setWornItem(clothes:getBodyLocation(), clothes);

        --Set stats 
        pl:getStats():setThirst(0.25); -- from 0 to 1
        pl:getStats():setHunger(0.25); -- from 0 to 1
        pl:getStats():setFatigue(0.25); -- from 0 to 1

        pl:setKnockedDown(true);

        IScnHunting.ApplyInjuries();

        DebugLog.log("IScn Difficulty Finished")

        ISCN.openDoor(4247, 7231, 0); -- Cabin
        ISCN.unlockDoor(4246, 7229, 0); -- Cabin Inside
        ISCN.unlockDoor(4250, 7228, 0); -- Cabin Inside
        ISCN.unlockDoor(4232, 7215, 0); -- Outhouse

        local sq = getCell():getGridSquare(4242, 7226, 0);
        if sq ~= nil then
            local sheet = InventoryItemFactory.CreateItem("Base.Sheet")
            sq:AddWorldInventoryItem(sheet, 0, 0, 0.35)
        end
        local sq = getCell():getGridSquare(4242, 7228, 0);
        if sq ~= nil then
            local sheet = InventoryItemFactory.CreateItem("Base.Sheet")
            sq:AddWorldInventoryItem(sheet, 0, 0, 0.35)
        end
        local sq = getCell():getGridSquare(4242, 7230, 0);
        if sq ~= nil then
            local sheet = InventoryItemFactory.CreateItem("Base.Sheet")
            sq:AddWorldInventoryItem(sheet, 0, 0, 0.35)
        end

        local sq = getCell():getGridSquare(4250, 7226, 0);
        if sq ~= nil then
            local sheet = InventoryItemFactory.CreateItem("Base.Sheet")
            sq:AddWorldInventoryItem(sheet, 0, 0, 0.35)
        end              

        local car = addVehicleDebug("Base.PickUpTruck", IsoDirections.W, nil, getCell():getGridSquare(4260, 7234, 0));
		car:repair();
		car:getPartById("Engine"):setCondition(0);
		car:getPartById("DoorFrontLeft"):setCondition(ZombRand(10,80));
		car:getPartById("DoorFrontRight"):setCondition(ZombRand(10,80));
        car:getPartById("EngineDoor"):setCondition(ZombRand(10,80));
        car:getPartById("HeadlightLeft"):setCondition(ZombRand(10,80));
        car:getPartById("HeadlightRight"):setCondition(ZombRand(10,80));
        car:getPartById("HeadlightRearRight"):setCondition(ZombRand(10,80));
        car:getPartById("HeadlightRearLeft"):setCondition(ZombRand(10,80));
        car:getPartById("Muffler"):setCondition(ZombRand(10,80));
        car:getPartById("Battery"):setCondition(ZombRand(10,80));
        car:getPartById("GasTank"):setCondition(ZombRand(10,80));
        car:getPartById("Heater"):setCondition(ZombRand(10,80));
        car:getPartById("TireFrontLeft"):setCondition(ZombRand(10,80));
        car:getPartById("TireFrontRight"):setCondition(ZombRand(10,80));
        car:getPartById("TireRearLeft"):setCondition(ZombRand(10,80));
        car:getPartById("TireRearRight"):setCondition(ZombRand(10,80));
        car:getPartById("Windshield"):setCondition(ZombRand(10,80));
        car:getPartById("WindshieldRear"):setCondition(ZombRand(10,80));
        car:getPartById("SuspensionFrontLeft"):setCondition(ZombRand(10,80));
        car:getPartById("SuspensionFrontRight"):setCondition(ZombRand(10,80));
        car:getPartById("SuspensionRearLeft"):setCondition(ZombRand(10,80));
        car:getPartById("SuspensionRearRight"):setCondition(ZombRand(10,80));
        car:getPartById("BrakeFrontLeft"):setCondition(ZombRand(10,80));
        car:getPartById("BrakeFrontRight"):setCondition(ZombRand(10,80));
        car:getPartById("BrakeRearLeft"):setCondition(ZombRand(10,80));
        car:getPartById("BrakeRearRight"):setCondition(ZombRand(10,80));        
        
		car:getPartById("GasTank"):setContainerContentAmount(83);
		car:setColor(0.8, 0.5, 0.02);		

        local familyName = ""
        local sq = getCell():getGridSquare(4247, 7229, 0);
        if sq ~= nil then
            local body = createRandomDeadBody(sq, 10);
            body:setDir(IsoDirections.N);
            if body:isFemale() then
                familyName = "Aunt Jane"
            else
                familyName = "Uncle Rob"
            end
            
            local c = body:getContainer();
            
            local mapItem = InventoryItemFactory.CreateItem("IScnHuntingHome_Map_WP")
            mapItem:setMapID("IScnHuntingHome_Map_WP")
            local stash = StashSystem.getStash("IScnHuntingHome_Map_WP")
            StashSystem.doStashItem(stash, mapItem)
            mapItem:setName("West Point : "..mapItem:getDisplayName())
            mapItem:setCustomName(true)
            c:AddItem(mapItem)

            local mapItem = InventoryItemFactory.CreateItem("IScnHunting_Map_WP")           
            mapItem:setMapID("IScnHunting_Map_WP")
            local stash = StashSystem.getStash("IScnHunting_Map_WP")
            StashSystem.doStashItem(stash, mapItem)
            mapItem:setName("Hunting Cabin")
            mapItem:setCustomName(true)
            c:AddItem(mapItem)
            
            c:AddItem(car:createVehicleKey());
            
            local gun = sq:AddWorldInventoryItem("Base.HuntingRifle", 0.0, 0.0, 0.0)
            gun:setCondition(0, false);
            
        end

        local sq = getCell():getGridSquare(4251, 7227, 0);
        if sq ~= nil then
            local noteBook = sq:AddWorldInventoryItem("Base.Journal", 0.5, 0.5, 0);
            noteBook:setCanBeWrite(true);
        
            noteBook:addPage(1, "Day 0:\n\nDear Diary,\nI'm so excited to go on a hunting trip with "..familyName..". It's going to be a great time.");
            noteBook:addPage(2, "Day 1:\n\nToday was a bit hectic! We drove out to the cabin but as we got there, the truck's radiator blew. Thankfully, "..familyName.." had a radio and my cousin is going to come help us.");
            noteBook:addPage(3, "Day 2:\n\nIt has been a strange day. We heard a lot of crazy stuff on the radio about some sickness spreading around. "..familyName.." tried to radio my cousin, but noone answered.");
            noteBook:addPage(4, "Day 3:\n\nThis is crazy. The radio has been telling everyone to stay indoors and quarantine. Apparently the disease that has been spreading is making everyone act strange.\n\n-")
            noteBook:setName(iscnModData.playerName.."\'s Journal");
        end        

        local c = ISCN.getContainer(4246, 7230, 0);        
        if c ~= nil then            
            c:emptyIt();      
            c:AddItem("Base.BookCarpentry1");
            c:AddItem("Base.BookForaging1");
            c:AddItem("Base.BookFishing1");
            c:AddItem("Base.BookTrapping1");
            c:AddItem("Base.FishingMag1");
            c:AddItem("Base.HuntingMag1");
            c:AddItem("Base.HuntingMag2");
            c:AddItem("Base.HuntingMag3");
            c:AddItem("Base.HerbalistMag"); 
            
            c:setExplored(true);
        end

        local c = ISCN.getContainer(4247, 7226, 0);        
        if c ~= nil then            
            c:emptyIt();      
            c:AddItem("Base.WaterBottleFull");
            c:AddItem("Base.WaterBottleFull");
            c:AddItem("Base.CannedChili");
            c:AddItem("Base.CannedCornedBeef");
            c:AddItem("Base.CannedPotato");
            c:AddItem("Base.CannedPotato");
            c:AddItem("Base.CannedBolognese");            
            
            c:AddItem("Base.Pot");
            c:AddItem("Base.Pot");
            c:AddItem("Base.Pan");
            c:AddItem("Base.KitchenKnife");
            c:AddItem("Base.KitchenKnife");
            c:AddItem("Base.Fork");
            c:AddItem("Base.Spoon");
            c:AddItem("Base.ButterKnife");
            
            c:setExplored(true);
        end
        
        local c = ISCN.getContainer(4249, 7226, 0);        
        if c ~= nil then            
            c:emptyIt(); 
            
            c:AddItem("Base.Hammer");
            c:AddItem("Base.NailsBox");
            c:AddItem("Base.NailsBox");
            c:AddItem("Base.HandAxe");        
            c:AddItem("Base.Screwdriver");
            c:AddItem("Base.Saw");
            c:AddItem("Base.HandTorch");
            c:AddItem("Base.Battery");
            c:AddItem("Base.Battery");
            c:AddItem("Base.Pencil");
            c:AddItem("Base.FishingLine");            

            c:setExplored(true);
        end
            
        local c = ISCN.getContainer(4233, 7213, 0);        
        if c ~= nil then            
            c:emptyIt(); 
            
            c:AddItem("Base.Tarp");
            c:AddItem("Base.Tarp");
            c:AddItem("Base.ToiletPaper");
            c:AddItem("Base.ToiletPaper");
            c:AddItem("Base.Plunger");            
            c:AddItem("Base.Sheet");
            c:AddItem("Base.Sheet");
            c:AddItem("Base.Sheet");
            c:AddItem("Base.Sheet");
            c:AddItem("Base.Twine");
            c:AddItem("Base.Twine");
            c:AddItem("Base.Twine");
            c:AddItem("Base.Twine");
            c:AddItem("Base.Disinfectant");
            
                        
            c:AddItem("Base.HandAxe"); 
            
            c:setExplored(true);
        end
            
        local c = ISCN.getContainer(4250, 7230, 0);        
        if c ~= nil then            
            c:emptyIt(); 
            
            c:AddItem("Base.WoodAxe"); 
            c:AddItem("Base.Log");
            c:AddItem("Base.Log");
            c:AddItem("Base.Log");
            c:AddItem("Base.Log");
            c:AddItem("Base.Log");
            c:AddItem("Base.Log");
            c:AddItem("Base.Log");
            c:AddItem("Base.Log");
            c:AddItem("Base.Log");
            c:AddItem("Base.Log");
            c:AddItem("Base.Log");
            c:AddItem("Base.Log");
            
            c:setExplored(true);
        end            

        local sq = getCell():getGridSquare(4246, 7227, 0);
        if sq ~= nil then                        
            sq:AddWorldInventoryItem("Base.FishingRod", 0.9, 0.9, 0.5)
        end
        
        local c = ISCN.getContainer(4262, 7233, 0);        
        if c ~= nil then            
            c:emptyIt();      
            c:AddItem("Base.Pills");
            
            c:setExplored(true);
        end        

        local clim = getClimateManager()
        
        iscnModData.stormStopTime = 24     
        clim:triggerCustomWeatherStage(WeatherPeriod.STAGE_HEAVY_PRECIP, iscnModData.stormStopTime);

        iscnModData.journalSpawned = false
        iscnModData.scenarioFinished = false;
        
        IScnHunting.setSandBoxVars();
                
        IScnHunting.AddZombies();                
        
        IScnHunting.EnableEvents();
        
        iscnModData.startconditionsset = true;
end

IScnHunting.EnableEvents = function()
    -- This executes once at startup and every ten min
    Events.EveryTenMinutes.Add( IScnHunting.EveryTenMin );
    Events.EveryTenMinutes.Add( IScnHunting.EveryTenMinLoot )
    -- Triggers when the player moves
    Events.OnPlayerMove.Add( ISCN.OnPlayerMove );
end

IScnHunting.EveryTenMinLoot = function()
    local sq = getCell():getGridSquare(11129, 6851, 0);
    if sq ~= nil then
        local iscnModData = ModData.get("IScnData")
        
        if iscnModData.journalSpawned ~= true then
            local noteBook = sq:AddWorldInventoryItem("Base.Journal", 0.5, 0.5, 0);
            noteBook:setCanBeWrite(true);
            
            noteBook:addPage(1, "What is the world coming to? First poor "..iscnModData.playerName.." gets stuck out at the cabin and now, people all over town are getting sick.")
            noteBook:addPage(2, "The family is all heading to Grandpa\'s farm to try and stay away from everyone else. Seems like the safest place.")
            noteBook:addPage(3, "Bobby isn\’t feeling so well. We put him in his own room and are trying our best to keep his fever down. Joe is going to try and get medicine from town.")
            noteBook:addPage(4, "Joe went to town and got antibiotics, but he said the Pharmacist was crazy and bit him. He just grabbed what he could and ran.")
            noteBook:addPage(5, "Bobby fell asleep. He had a high fever, but now he feels cold. Maybe the medicine is working!")
            noteBook:addPage(6, "Bobby woke up but he isn\'t right. He keeps lunging at us. We locked him in his room until we can figure out what to do.")
            noteBook:addPage(7, "God has condemned us. The world has gone mad! Everyone has turned into monsters! Everyone is town is running and screaming and there are people eating each other on the streets!")
            noteBook:addPage(8, "Joe is sick now too. We boarded up the windows and gathered what we could to fight back against the monsters.")
            noteBook:addPage(9, "God please help us.")
            noteBook:setName("Family\'s Note");
            
            iscnModData.journalSpawned = true
            
            Events.EveryTenMinutes.Remove(IScnHunting.EveryTenMinLoot)
        end
    end
end

IScnHunting.EveryTenMin = function()
    -- This executes once at startup and every ten min
    DebugLog.log("IScn::EveryTenMin")

    local pl = getPlayer();
    local iscnModData = ModData.get("IScnData")

    local clim = getClimateManager()
    local thunder = clim:getThunderStorm();
    thunder:triggerThunderEvent(4243, 7230, true, true, true)

    local hoursSurvived = pl:getHoursSurvived()
    if math.floor(hoursSurvived) >= iscnModData.stormStopTime then
        
        Events.EveryTenMinutes.Remove(IScnHunting.EveryTenMin)
        iscnModData.scenarioFinished = true  
    end
    
end

IScnHunting.DifficultyCheck = function()
	local iscnModData = ModData.get("IScnData")
    
    if ModOptions and ModOptions.getInstance then
        iscnModData.easyMode = IScnModOptions.options.easyMode
        iscnModData.normalMode = IScnModOptions.options.normalMode
        iscnModData.hardMode = IScnModOptions.options.hardMode
    else
        DebugLog.log("IScn: ModOptions unavailable, use normal mode")
        iscnModData.normalMode = true;
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
    elseif iscnModData.hardMode then
        iscnModData.normalMode = false;
        iscnModData.difficultymodifier = ZombRand(10,20);
        iscnModData.injurytimemodifier = ZombRand(10,30);
        iscnModData.drunkmodifier = 50;
    else
        iscnModData.difficultymodifier = ZombRand(5,10);
        iscnModData.injurytimemodifier = ZombRand(10,20);
        iscnModData.drunkmodifier = 25;
    end

end

IScnHunting.ApplyInjuries = function() 
    local pl = getPlayer();
    local iscnModData = ModData.get("IScnData")

    local damage = 30 + iscnModData.difficultymodifier;
    local injurytime = 35 + iscnModData.injurytimemodifier;

    local bodydamage = pl:getBodyDamage();    
    local bodypart = nil

    local leg = ZombRand(2)+1;
    if iscnModData.normalMode then
        -- leg injury       
        if leg == 1 then
            bodypart = bodydamage:getBodyPart(BodyPartType.LowerLeg_R)
        else
            bodypart = bodydamage:getBodyPart(BodyPartType.UpperLeg_R)
        end
        bodypart:AddDamage(damage);
        bodypart:setFractureTime(injurytime);
        bodypart:setSplint(true, .8);
        bodypart:setCut(true, true);
        bodypart:setBandaged(true, 5, true, "Base.AlcoholBandage");
        bodypart:SetInfected(false);
    elseif iscnModData.hardMode then            
        if leg == 1 then
            bodypart = bodydamage:getBodyPart(BodyPartType.LowerLeg_L)
        else
            bodypart = bodydamage:getBodyPart(BodyPartType.UpperLeg_L)
        end
        bodypart:AddDamage(damage);
        bodypart:setFractureTime(injurytime);
        bodypart:setSplint(true, .8);
        bodypart:setCut(true, true);
        bodypart:setBandaged(true, 5, true, "Base.AlcoholBandage");
        bodypart:SetInfected(false);
    end
    
    local arm = ZombRand(2)+1;
    if iscnModData.normalMode then 
        -- arm injury       
        if arm == 1 then
            bodypart = bodydamage:getBodyPart(BodyPartType.UpperArm_L)
        else
            bodypart = bodydamage:getBodyPart(BodyPartType.ForeArm_L)
        end
        bodypart:AddDamage(damage);
        bodypart:setFractureTime(injurytime);
        bodypart:setSplint(true, .8);
        bodypart:setCut(true, true);
        bodypart:setBandaged(true, 5, true, "Base.AlcoholBandage");
        bodypart:SetInfected(false);
    end
    
    if iscnModData.hardMode then
        if arm == 1 then
            bodypart = bodydamage:getBodyPart(BodyPartType.UpperArm_R)
        else
            bodypart = bodydamage:getBodyPart(BodyPartType.ForeArm_R)
        end
        bodypart:AddDamage(damage);
        bodypart:setFractureTime(injurytime);
        bodypart:setSplint(true, .8);
        bodypart:setCut(true, true);
        bodypart:setBandaged(true, 5, true, "Base.AlcoholBandage");
        bodypart:SetInfected(false);
    end
    
    bodydamage:setInfected(false);
    bodydamage:setInfectionLevel(0);
    bodydamage:Update();
    
    if bodydamage:IsInfected() == true then
        print("ISCN: BUG infected, please report to ImmersiveScenarios");
    end
       
end

IScnHunting.AddZombies = function()    
        
    local iscnModData = ModData.get("IScnData")
    iscnModData.triggers = {}

    local zombieBody = ISCN.CreateZombieBody(4247, 7232, 0, "Redneck")
    ISCN.CreateZombieEater(zombieBody, 4247, 7232, 0, "Redneck", 4, nil, nil)

    ISCN.CreateOutfitZombies(4244, 7229, 0, 1, "Redneck", 50, true, false, true, true, 1.0); 

end

IScnHunting.setSandBoxVars = function()
    local options= {}
    
    local iscnModData = ModData.get("IScnData")
    local sandbox = getSandboxOptions()
    
    -- StartTime is returned as the index of the list, not the time.
    -- 1:7am 2:9am 3:12pm 4:2pm 5:5pm 6:9pm 7:12am 8:2am 9:5am
    -- hourset = options:getOptionByName("StartTime"):getValue();
    -- if hourset == 1 then return 
    -- elseif hourset == 2 then hourvalue = 9;
    -- elseif hourset == 3 then hourvalue = 12;
    -- elseif hourset == 4 then hourvalue = 14;
    -- elseif hourset == 5 then hourvalue = 17;
    -- elseif hourset == 6 then hourvalue = 21;
    -- elseif hourset == 7 then hourvalue = 0;
    -- elseif hourset == 8 then hourvalue = 2;
    -- else hourvalue = 5 ;
    -- end 

    gt = getGameTime();    
    gt:setDay(sandbox:getOptionByName("StartDay"):getValue()-1); -- The night before
    gt:setStartDay(sandbox:getOptionByName("StartDay"):getValue()-1); -- The night before
    gt:setTimeOfDay(IScnHunting.hourOfDay);
end

IScnHunting.OnInitGlobalModData = function()
    -- This creation marks the scenario as active
    local iscnModData = ModData.create("IScnData")
    
    iscnModData.id = IScnHunting.id
    
    if getActivatedMods():contains("BarricadedStart") then
        -- Compatibility with Immersive Barricaded Start
        getPlayer:getModData().WMAR.HasModBeenRan = true
    end
end

-----------------------------------------------------
-- Default Challenge/LastStand functions below
-----------------------------------------------------

IScnHunting.OnInitWorld = function()
        
    DebugLog.log("IScn:OnInitWorld")    
    
    Events.OnInitGlobalModData.Add(IScnHunting.OnInitGlobalModData);    
    
    --Events.OnCreatePlayer.Add(IScnHunting.OnCreatePlayer)
end

IScnHunting.OnCreatePlayer = function(playerIndex, pl)
    --DebugLog.log("ISCN::TEST")
end

IScnHunting.RemovePlayer = function(p)
end

IScnHunting.AddPlayer = function(p)
end

IScnHunting.Render = function()
end

local xcell = 14
local ycell = 24
local x = 52
local y = 28
local z = 0

-- map.six.ph
if z == 2 then
    x = x + 6;
    y = y + 6;
elseif z == 1 then
    x = x + 3;
    y = y + 3;
end

IScnHunting.id = "IScnHunting";
IScnHunting.image = "media/lua/client/LastStand/IScnHunting.png";
IScnHunting.gameMode = "IScnHunting";
IScnHunting.world = "Muldraugh, KY";
IScnHunting.xcell = xcell;
IScnHunting.ycell = ycell;
IScnHunting.x = x;
IScnHunting.y = y;
IScnHunting.z = z;
IScnHunting.enableSandbox = true;

IScnHunting.spawns = {
        {worldX = xcell, worldY = ycell, posX = x, posY = y, posZ = z}, 
}

IScnHunting.hourOfDay = 21; -- Force Nighttime

Events.OnChallengeQuery.Add(IScnHunting.Add)

Events.OnGameStart.Add(IScnHunting.OnGameStart);