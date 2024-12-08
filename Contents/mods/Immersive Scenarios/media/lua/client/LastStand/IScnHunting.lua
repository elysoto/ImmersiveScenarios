
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
        
        --Remove all clothes and give player a hospital gown and socks
        pl:clearWornItems();
        pl:getInventory():clear();
        local clothes = nil
        inv:AddItem("Base.KeyRing");
        clothes = inv:AddItem("Base.Belt2");
        pl:setWornItem(clothes:getBodyLocation(), clothes);
        clothes = inv:AddItem("Base.Vest_Hunting_Orange");
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

        --pl:setKnockedDown(true);

        IScnHunting.ApplyInjuries();

        DebugLog.log("IScn Difficulty Finished")

        ISCN.openDoor(4247, 7231, 0); -- Cabin
        ISCN.unlockDoor(4246, 7229, 0); -- Cabin Inside
        ISCN.unlockDoor(4250, 7228, 0); -- Cabin Inside
        ISCN.unlockDoor(4232, 7215, 0); -- Outhouse

        local sq = getCell():getGridSquare(4242, 7226, 0);
        if sq ~= nil then
            local sheet = InventoryItemFactory.CreateItem("Base.Sheet")
            local item = sq:AddWorldInventoryItem(sheet, 0.1, 0.1, 0.15)            
            item:setWorldZRotation(90)
        end
        local sq = getCell():getGridSquare(4242, 7228, 0);
        if sq ~= nil then
            local sheet = InventoryItemFactory.CreateItem("Base.Sheet")
            local item = sq:AddWorldInventoryItem(sheet, 0.1, 0.1, 0.15)
            item:setWorldZRotation(90)
        end
        local sq = getCell():getGridSquare(4242, 7230, 0);
        if sq ~= nil then
            local sheet = InventoryItemFactory.CreateItem("Base.Sheet")
            local item = sq:AddWorldInventoryItem(sheet, 0.1, 0.1, 0.15)
            item:setWorldZRotation(90)
        end

        local sq = getCell():getGridSquare(4250, 7226, 0);
        if sq ~= nil then
            local sheet = InventoryItemFactory.CreateItem("Base.Sheet")
            local item = sq:AddWorldInventoryItem(sheet, 0.1, 0.1, 0.15)
            item:setWorldZRotation(0)
        end              

        local car = addVehicleDebug("Base.PickUpTruck", IsoDirections.W, nil, getCell():getGridSquare(4260, 7234, 0));
		car:getPartById("Engine"):setCondition(1);
		car:getPartById("DoorFrontLeft"):setCondition(ZombRand(50,80));
		car:getPartById("DoorFrontRight"):setCondition(ZombRand(50,80));
        car:getPartById("EngineDoor"):setCondition(ZombRand(30,50));
        car:getPartById("HeadlightLeft"):setCondition(ZombRand(40,80));
        car:getPartById("HeadlightRight"):setCondition(0);
        car:getPartById("HeadlightRearRight"):setCondition(ZombRand(40,80));
        car:getPartById("HeadlightRearLeft"):setCondition(ZombRand(40,80));
        car:getPartById("Muffler"):setCondition(ZombRand(10,80));
        local part = car:getPartById("Battery")
        part:setCondition(ZombRand(20,25));
        local bat = part:getInventoryItem()
        bat:setDelta(0.19)
        car:getPartById("GasTank"):setCondition(ZombRand(30,80));
        car:getPartById("Heater"):setCondition(ZombRand(30,80));
        car:getPartById("TireFrontLeft"):setCondition(ZombRand(10,80));
        local part = car:getPartById("TireFrontRight")
        part:setCondition(ZombRand(5,10));
        part:setContainerContentAmount(0)
        car:getPartById("TireRearLeft"):setCondition(ZombRand(10,80));
        local part = car:getPartById("TireRearRight");
        part:setCondition(0);
        part:setContainerContentAmount(0)
        car:getPartById("Windshield"):setCondition(ZombRand(70,80));
        car:getPartById("WindshieldRear"):setCondition(ZombRand(70,80));
        car:getPartById("WindowFrontLeft"):setCondition(ZombRand(70,80));
        car:getPartById("WindowFrontRight"):setCondition(ZombRand(70,80));
        car:getPartById("GloveBox"):setCondition(ZombRand(40,80));
        car:getPartById("Radio"):setCondition(ZombRand(40,80));
        car:getPartById("SeatFrontLeft"):setCondition(ZombRand(40,80));
        car:getPartById("SeatFrontRight"):setCondition(ZombRand(40,80));        
        car:getPartById("SuspensionFrontLeft"):setCondition(ZombRand(10,80));
        car:getPartById("SuspensionFrontRight"):setCondition(ZombRand(10,80));
        car:getPartById("SuspensionRearLeft"):setCondition(ZombRand(10,80));
        car:getPartById("SuspensionRearRight"):setCondition(ZombRand(10,80));
        car:getPartById("BrakeFrontLeft"):setCondition(ZombRand(10,80));
        car:getPartById("BrakeFrontRight"):setCondition(ZombRand(10,80));
        car:getPartById("BrakeRearLeft"):setCondition(ZombRand(10,80));
        car:getPartById("BrakeRearRight"):setCondition(ZombRand(10,80));        
        
		car:getPartById("GasTank"):setContainerContentAmount(36);
		car:setColor(0.66, 0.92, 0.02);		

        local c = car:getPartById("GloveBox"):getItemContainer()
        if c ~= nil then
            c:emptyIt();
            c:AddItem("Base.Pills");
            c:AddItem("Base.Pills");            
            c:AddItem("Base.WaterBottleFull");
            c:AddItem("Base.Crisps");
            c:AddItem("Base.BeefJerky");
            c:AddItem("Base.BeefJerky");
            c:AddItem("Base.Battery");
            c:AddItem("Base.Lighter");
            c:AddItem("Base.Matches");
            c:AddItem("Base.Cigarettes");            

            c:setExplored(true);
        end
        
        local toolbox = InventoryItemFactory.CreateItem("Base.Toolbox")
        local c = toolbox:getItemContainer()
        if c ~= nil then
            c:emptyIt();
            c:AddItem("Base.Wrench");
            c:AddItem("Base.DuctTape");
            c:AddItem("Base.DuctTape");
            c:AddItem("Base.Hammer");
            c:AddItem("Base.NailsBox");
            c:AddItem("Base.Screwdriver");
            c:AddItem("Base.FirstAidKit");            
            
            c:setExplored(true);
        end
        
        local c = car:getPartById("TruckBedOpen"):getItemContainer()        
        if c ~= nil then
            c:emptyIt();
            c:AddItem("Base.FishingLine");
            c:AddItem("Base.FishingLine");
            c:AddItem("Base.FishingRod");
            c:AddItem("Base.LugWrench");
            c:AddItem("Base.Jack");
            c:AddItem("Base.TirePump");
            c:AddItem("Base.PetrolCan");
            c:AddItem("Base.308Box");
            c:AddItem("Base.308Box");
            c:AddItem("Base.x2Scope");          
            local tire = c:AddItem("Base.OldTire2");
            tire:setCondition(20)
            
            c:AddItem(toolbox);

            c:setExplored(true);
        end

        local familyName = ""
        local zombie = createZombie(4249, 7230, 0, nil, 0, IsoDirections.N);
        if zombie then
            zombie:dressInNamedOutfit("Redneck")
            zombie:DoZombieInventory();        
            for i=0, 20 do
                -- void addBlood(BloodBodyPartType part, boolean scratched, boolean bitten, boolean allLayers)
                zombie:addBlood(nil, false, true, true);
                zombie:addHole(nil, true);
                zombie:addDirt(nil, nil, true) -- Not Working?
            end        
            zombie:DoCorpseInventory()
            local inv = zombie:getInventory()
            
            local clothes = inv:AddItem("Base.Vest_Hunting_Orange");
            zombie:setWornItem(clothes:getBodyLocation(), clothes);            
            
            local body = IsoDeadBody.new(zombie, false);
                    
            body:setX(4249);
            body:setY(7230);
            body:setZ(0);        
            
            local reanimateHourOffset = 2
            body:reanimateLater()
            body:setReanimateTime(GameTime:getInstance():getWorldAgeHours()+reanimateHourOffset)

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
            
            local gun = c:AddItem("Base.HuntingRifle")
            gun:setCondition(1, false);
            c:AddItem("Base.308Clip")
            c:AddItem("Base.308Bullets")
            c:AddItem("Base.308Bullets")
        end

        local sq = getCell():getGridSquare(4262, 7285, 0);
        if sq ~= nil then
            local gun = sq:AddWorldInventoryItem("Base.HuntingRifle", 0.5, 0.5, 0);
            gun:setCondition(7, false);
            sq:AddWorldInventoryItem("Base.308Bullets", 0.1, 0.5, 0)
            sq:AddWorldInventoryItem("Base.308Bullets", 0.3, 0.1, 0)
            sq:AddWorldInventoryItem("Base.308Bullets", 0.2, 0.4, 0)
            sq:AddWorldInventoryItem("Base.308Bullets", 0.5, 0.2, 0)
            sq:AddWorldInventoryItem("Base.308Bullets", 0.7, 0.7, 0)
            sq:AddWorldInventoryItem("Base.308Clip", 0.7, 0.7, 0)            
            sq:AddWorldInventoryItem("Base.Bag_NormalHikingBag", 0.01, 0.01, 0)
        end
        
        local sq = getCell():getGridSquare(4252, 7229, 0);
        if sq ~= nil then
            local itemGen = InventoryItemFactory.CreateItem("Base.Generator")
            local gen = IsoGenerator.new(itemGen, getCell(), sq)
            gen:setConnected(true)
            gen:setFuel(63.0)
            --gen:setActivated(true)
        end

        local sq = getCell():getGridSquare(4247, 7228, 0);
        if sq ~= nil then
            local obj = IsoLightSwitch.new( getCell(), sq, getSprite("lighting_indoor_01_8"), sq:getRoomID() );
            obj:addLightSourceFromSprite();
            sq:AddTileObject(obj)
            --sq:AddWorldInventoryItem("Base.Mov_Lamp1", 0.5, 0.5, 0);
        end

        local sq = getCell():getGridSquare(4251, 7227, 0);
        if sq ~= nil then
            local noteBook = sq:AddWorldInventoryItem("Base.Journal", 0.5, 0.5, 0);
            noteBook:setCanBeWrite(true);
        
            noteBook:addPage(1, "Dear Diary,\nI'm so excited to go on a hunting trip with "..familyName..". It's going to be a great time just the two of us.");
            noteBook:addPage(2, "Today was a bit hectic! We drove out to the cabin but as we got there, we hit a rock, blew a tire, and hit a tree. The truck's radiator is leaking all over. At least we have a spare tire. Thankfully, the cabin has a Ham radio and my cousin is going to come help us.");
            noteBook:addPage(3, "It has been a strange day. We heard a lot of crazy stuff on the radio about some sickness spreading around. "..familyName.." tried to reach my cousin on the Ham, but no one answered. Maybe they are already on their way? We are going to go fishing at the pond and just catch up.");
            noteBook:addPage(4, "This morning we are going to make the best of it and go out on a hunt while we wait. "..familyName.." hopes to pick out a buck or a rabbit for dinner. Either way, should be better than eating more canned food.\n\n")
            noteBook:addPage(5, "Oww, the pain... We ran across other hunters yesterday, they were just standing in the middle of the forest. We watched them for a long while and just saw them walk around slowly in circles for hours! Eventually "..familyName.." decided we should go check on them, but when we got close, we noticed that one was shot multiple times in the chest and the other was bloody all over! Suddenly they noticed us and started to lunge at us. We ran as fast we could back towards the cabin when I fell down a small ravine and got hurt really bad. " ..familyName.. " managed to drag me back to the cabin. I think my leg is broken. I'm going to try and sleep, but it\'s hard with all this pain.\n\n")
            noteBook:addPage(6, "Ugg. Just woke up and I feel worse than yesterday. I wonder where "..familyName.." went? It has been oddly quiet. I keep calling out but nothing. I really don't want to get out of bed, it hurts so bad, but I better find out what is going on.\n\n")
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
            c:AddItem("Base.ElectronicsMag4");
            
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
            c:AddItem("Base.Pan");
            c:AddItem("Base.RoastingPan");            
            c:AddItem("Base.KitchenKnife");
            c:AddItem("Base.KitchenKnife");
            c:AddItem("Base.Bowl");
            c:AddItem("Base.Fork");
            c:AddItem("Base.Spoon");
            c:AddItem("Base.ButterKnife");
            c:AddItem("Base.TinOpener");        
            
            c:setExplored(true);
        end
        
        local c = ISCN.getContainer(4248, 7226, 0);        
        if c ~= nil then            
            c:emptyIt();         
        
            c:AddItem("Base.Pot");
            
            c:setExplored(true);
        end
        
        local c = ISCN.getContainer(4249, 7226, 0);        
        if c ~= nil then            
            c:emptyIt(); 
            
            c:AddItem("Base.Hammer");
            c:AddItem("Base.NailsBox");
            c:AddItem("Base.NailsBox");
            c:AddItem("Base.HandAxe");
            c:AddItem("Base.farming.HandShovel");
            c:AddItem("Base.HandFork");
            c:AddItem("Base.Screwdriver");
            c:AddItem("Base.Saw");
            c:AddItem("Base.HandTorch");
            c:AddItem("Base.Battery");
            c:AddItem("Base.Battery");
            c:AddItem("Base.Pencil");
            c:AddItem("Base.Lighter");
            c:AddItem("Base.Matches");
            c:AddItem("Base.Matches");
            c:AddItem("Base.Scissors");
            c:AddItem("Base.Charcoal");
            c:AddItem("Base.Garbagebag");
            c:AddItem("Base.Garbagebag");
            c:AddItem("Base.Candle");
            c:AddItem("Base.Candle");
            c:AddItem("Base.MugWhite");
            c:AddItem("Base.Vinegar");
            c:AddItem("Base.BakingSoda");

            c:AddItem("Base.farming.PotatoBagSeed");
            c:AddItem("Base.farming.TomatoBagSeed");
            c:AddItem("Base.farming.StrewberrieBagSeed");

            c:setExplored(true);
        end

        local sq = getCell():getGridSquare(4232, 7238, 0)
        local object = IsoBarbecue.new(getCell(), sq, getSprite("appliances_cooking_01_35"))
        sq:AddTileObject(object)

        local sq = getCell():getGridSquare(4246, 7226, 0)
        objs = sq:getObjects()
        for i = 0, objs:size()-1 do
            local o = objs:get(i);
            if o:getSprite():getName() == "furniture_seating_indoor_02_4" then 
                o:removeFromSquare()
            end
        end        
        local object = IsoTelevision.new(getCell(), sq, getSprite("appliances_television_01_8"))
        sq:AddTileObject(object)

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
            c:AddItem("Base.Rope");
            c:AddItem("Base.Disinfectant");
            c:AddItem("Base.Garbagebag");
            c:AddItem("Base.Garbagebag");
            c:AddItem("Base.Needle");
            c:AddItem("Base.Thread");
            c:AddItem("Base.Scissors");
            
                        
            c:AddItem("Base.HandAxe"); 
            
            c:setExplored(true);
        end
            
        local c = ISCN.getContainer(4250, 7230, 0);        
        if c ~= nil then            
            c:emptyIt(); 
            
            c:AddItem("Base.WoodAxe"); 
            c:AddItem("Base.Shovel");
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

        local clim = getClimateManager()
        
        iscnModData.stormStopTime = 24     
        clim:triggerCustomWeatherStage(WeatherPeriod.STAGE_HEAVY_PRECIP, iscnModData.stormStopTime);

        iscnModData.journalSpawned = false
        iscnModData.scenarioFinished = false;
        
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
            
            noteBook:addPage(1, "What is the world coming to? First poor "..iscnModData.playerName.." gets stuck out at the cabin, and now people all over town are getting sick.")
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
    if math.floor(hoursSurvived) >= math.floor(iscnModData.stormStopTime-1) then
        
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
        --bodypart:setSplint(true, .8);
        bodypart:setCut(true, true);
        bodypart:setBandaged(true, 5, true, "Base.RippedSheets");
        bodypart:SetInfected(false);
    elseif iscnModData.hardMode then            
        if leg == 1 then
            bodypart = bodydamage:getBodyPart(BodyPartType.LowerLeg_L)
        else
            bodypart = bodydamage:getBodyPart(BodyPartType.UpperLeg_L)
        end
        bodypart:AddDamage(damage);
        bodypart:setFractureTime(injurytime);
        --bodypart:setSplint(true, .8);
        bodypart:setCut(true, true);
        bodypart:setBandaged(true, 5, true, "Base.RippedSheets");
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
        --bodypart:setSplint(true, .8);
        bodypart:setCut(true, true);
        bodypart:setBandaged(true, 5, true, "Base.RippedSheets");
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
        --bodypart:setSplint(true, .8);
        bodypart:setCut(true, true);
        bodypart:setBandaged(true, 5, true, "Base.RippedSheets");
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

    -- Truck
    local zombieBody = ISCN.CreateZombieBody(4256, 7235, 0, "Redneck")
    ISCN.CreateZombieEater(zombieBody, 4256, 7235, 0, "Redneck", 4, nil, nil)

    -- Outside Cabin
    ISCN.CreateOutfitZombies(4248, 7234, 0, 1, "Redneck", 50, true, false, true, true, 1.0); 

    -- Outhouse
    local zombieBody = ISCN.CreateZombieBody(4232, 7216, 0, "Redneck")
    ISCN.CreateZombieEater(zombieBody, 4232, 7216, 0, "Redneck", 4, nil, nil)

    -- Pond
    local zombieBody = ISCN.CreateZombieBody(4254, 7256, 0, "Redneck")
    ISCN.CreateZombieEater(zombieBody, 4254, 7256, 0, "Redneck", 4, nil, nil)

    -- Picnic Tables
    local zombieBody = ISCN.CreateZombieBody(4229, 7236, 0, "Redneck")
    ISCN.CreateZombieEater(zombieBody, 4229, 7236, 0, "Redneck", 4, nil, nil)

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

Events.OnChallengeQuery.Add(IScnHunting.Add)

Events.OnGameStart.Add(IScnHunting.OnGameStart);