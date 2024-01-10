
IScnHospital = {}

IScnHospital.Add = function()
    addChallenge(IScnHospital);
end

IScnHospital.OnGameStart = function()
        
    if ModData.exists("IScnData") == false then
        saveName = getWorld():getWorld();
        scenario = string.match(saveName, "(.-)\-")    
        if scenario == "IScnHospital" then
            print("IScn: Error Case - Recover")
            -- Can Remove this in the future
            local iscnModData = ModData.create("IScnData")
            iscnModData.startconditionsset = true
            iscnModData.powerRestored = false
            iscnModData.minCounter = 0
            iscnModData.hoursUntilPower = 12
            iscnModData.elecShutModifier = ZombRand(15,45)
        else
            -- Scenario inactive
            print("IScn:Scenarios Inactive")
            return;
        end
    end
    
    local iscnModData = ModData.get("IScnData")
    if iscnModData.id ~= IScnHospital.id then
        -- Scenario inactive
        print("IScn:"..IScnHospital.id.." Scenario Inactive")
        return;
    end
        
    if iscnModData.elecShutModifier == nil then
        iscnModData.elecShutModifier = ZombRand(15,45)
    end

    --check if it's a new game      
    if iscnModData.startconditionsset ~= true and getPlayer():getHoursSurvived() <=1 then
        print("IScnHospital:OnGameStart - New Game")
        Events.OnGameStart.Add(IScnHospital.OnNewGame);
    elseif iscnModData.startconditionsset and iscnModData.powerRestored ~= true then        
        print("IScnHospital:Loading Scenario Event")
        ImmersiveScenarios.LoadTriggers();
        IScnHospital.EnableEvents();
    else
        print("IScnHospital:Unknown Condition")
    end

end

IScnHospital.OnNewGame = function(player, square)

        print("IScnHospital:New Game Scenario Event")

        IScnHospital.DifficultyCheck();

        local pl = getPlayer();
        local inv = pl:getInventory();
        local iscnModData = ModData.get("IScnData")
        iscnModData.playerName = pl:getDescriptor():getForename()
        
        iscnModData.hourOffset = IScnHospital.hourOfDay - 7

        --Remove all clothes and give player a hospital gown and socks
        pl:clearWornItems();
        pl:getInventory():clear();
        inv:AddItem("Base.KeyRing");
        local clothes = inv:AddItem("Base.HospitalGown");
        pl:setWornItem(clothes:getBodyLocation(), clothes);
        clothes = inv:AddItem("Base.Socks_Ankle");
        pl:setWornItem(clothes:getBodyLocation(), clothes);

        --Set stats 
        pl:getStats():setDrunkenness(50+iscnModData.drunkmodifier); -- 0 to 100
        pl:getStats():setThirst(0.25); -- from 0 to 1
        pl:getStats():setHunger(0.25); -- from 0 to 1
        pl:getStats():setFatigue(0.25); -- from 0 to 1

        IScnHospital.ApplyInjuries();

        DebugLog.log("IScn Difficulty Finished")

        ImmersiveScenarios.addBarricade(12931, 2043, 2, 4, true); -- Spawn Room
        ImmersiveScenarios.unlockDoor(12931, 2043, 2); -- Spawn Room
        
        ImmersiveScenarios.addBarricade(12931, 2017, 2, 2, false, 3.0);        
        ImmersiveScenarios.addBarricade(12930, 2017, 2, 2, false, 3.0);        
        
        ImmersiveScenarios.addBarricade(12944, 2042, 2, 1, true, 3.0);
               
        ImmersiveScenarios.addBarricade(12941, 2036, 1, 2, false, 5.0);        
        ImmersiveScenarios.addBarricade(12941, 2037, 1, 2, false, 5.0);
        ImmersiveScenarios.addBarricade(12927, 2036, 1, 2, true, 5.0);
                        
        ImmersiveScenarios.addBarricade(12946, 2023, 1, 2, true, 5.0);
        ImmersiveScenarios.addBarricade(12946, 2022, 1, 2, true, 5.0);

        ImmersiveScenarios.addBarricade(12941, 2043, 1, 2, false, 5.0);
        ImmersiveScenarios.addBarricade(12941, 2044, 1, 2, false, 5.0);
        
        -- Morgue Inner
        ImmersiveScenarios.addBarricade(12952, 2000, 0, 2, true, 64.0);
        ImmersiveScenarios.addBarricade(12952, 2001, 0, 2, true, 64.0);        
        
        -- Morgue Outer
        ImmersiveScenarios.addBarricade(12949, 2013, 0, 4, false, 16.0);
        ImmersiveScenarios.addBarricade(12950, 2013, 0, 4, false, 16.0);
                
        ImmersiveScenarios.addBarricade(12937, 2089, 0, 4, false, 16.0);
        ImmersiveScenarios.addBarricade(12938, 2089, 0, 3, false, 16.0);
        
        ImmersiveScenarios.addBarricade(12948, 2089, 0, 2, false, 16.0);
        ImmersiveScenarios.addBarricade(12949, 2089, 0, 2, false, 16.0);

        ImmersiveScenarios.addBarricade(12984, 2023, 0, 2, false, 16.0);
        ImmersiveScenarios.addBarricade(12984, 2024, 0, 2, false, 16.0);
        
        ImmersiveScenarios.addBarricade(12984, 2031, 0, 2, false, 16.0);
        ImmersiveScenarios.addBarricade(12984, 2032, 0, 2, false, 16.0);
        
        ImmersiveScenarios.addBarricade(12965, 2017, 0, 2, true, 16.0); 
        ImmersiveScenarios.addBarricade(12966, 2017, 0, 2, true, 16.0);     
        
        -- Trash Door
        ImmersiveScenarios.addBarricade(12942, 2002, 0, 2, true, 16.0); 
        
        -- TEST. Need a way to harden 1st floor windows. Barricades too unrealistic
        --for x=12924, 12928 do
            --ImmersiveScenarios.hardenWindow(x, 2090, 0, 10.0)
            --ImmersiveScenarios.addBarricade(x, 2090, 0, 1, true, 4.0, "SheetMetal");
        --end
        --for x=12932, 12935 do
            --ImmersiveScenarios.addBarricade(x, 2089, 0, 1, false, 2.0, "MetalBar");
        --end
        --for x=12940, 12946 do
            --ImmersiveScenarios.addBarricade(x, 2089, 0, 1, false, 2.0, "MetalBar");
        --end
        --for x=12951, 12954 do
            --ImmersiveScenarios.addBarricade(x, 2089, 0, 1, false, 2.0, "MetalBar");
        --end
        --for x=12958, 12962 do
            --ImmersiveScenarios.addBarricade(x, 2090, 0, 1, false, 2.0, "MetalBar");
        --end

        ImmersiveScenarios.lockDoor(12931, 2035, 2) -- +6
        ImmersiveScenarios.lockDoor(12931, 2038, 2)        
        ImmersiveScenarios.lockDoor(12958, 2037, 2)
        ImmersiveScenarios.lockDoor(12924, 2028, 2)        
        ImmersiveScenarios.lockDoor(12948, 2057, 2)
        
        ImmersiveScenarios.lockDoor(12930, 2048, 1) -- +3
        ImmersiveScenarios.lockDoor(12973, 2023, 1)
        ImmersiveScenarios.lockDoor(12971, 2017, 1)
        ImmersiveScenarios.lockDoor(12957, 2013, 1)
        ImmersiveScenarios.lockDoor(12931, 2050, 1)
        
        ImmersiveScenarios.lockDoor(12955, 2046, 0)
        
        ImmersiveScenarios.lockDoor(12968, 2018, 0)
        
        ImmersiveScenarios.lockDoor(12960, 2026, 0)

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
        end

        local familyName = ""
        local sq = getCell():getGridSquare(12929, 2043, 2);
        if sq ~= nil then
            local body = createRandomDeadBody(sq, 10);
            body:setDir(IsoDirections.N);
            if body:isFemale() then
                familyName = "Aunt Jane"
            else
                familyName = "Uncle Rob"
            end
            
            local c = body:getContainer();
            for i = 0, 3 do
                c:AddItem("Base.Nails");
            end
            local mapItem = c:AddItem("IScnHospital_Map_WP");  
            mapItem:setMapID("IScnHospital_Stash_WP")
            stash = StashSystem.getStash("IScnHospital_Stash_WP")
            StashSystem.doStashItem(stash, mapItem)
            mapItem:setName("West Point : "..mapItem:getDisplayName())
            mapItem:setCustomName(true)
            
            local gun = sq:AddWorldInventoryItem("Base.Revolver", 0.9, 0.9, 0.5)
            gun:setCondition(0, false);
        end

        local sq = getCell():getGridSquare(12928, 2043, 2);
        if sq ~= nil then
            local noteBook = sq:AddWorldInventoryItem("Base.Journal", 0.5, 0.5, 0);
            noteBook:setCanBeWrite(true);
        
            noteBook:addPage(1, "Day 0:\n\nDear Diary,\nI'm so excited to go see my family in West Point. It's a long 8 hour drive through the night, but I should be able to manage. Can\'t wait to see them all, especially the little ones. "..familyName.." is going to have a barbeque to celebrate.");
            noteBook:addPage(2, "Day 1:\n\n"..iscnModData.playerName.." you must have fallen asleep at the wheel and crashed. It was bad and you almost didn\'t make it. You\'ve been in a coma for a week already. The doctors are saying that it is wait and see right now. I feel terrible. I\'ve been staying next to you hoping you will wake up. I\'m sorry for writing in your journal, but hopefully you will appreciate it.\n\n-"..familyName);
            noteBook:addPage(3, "Day 2:\n\nIt has been a strange day. Traffic was unusually light from West Point and there was a crowd of people at the hospital reception. Some of the family couldn\'t come visit you because they caught the flu. I think I\'ll stay the night in your room and keep you company.\n\n-"..familyName);
            noteBook:addPage(4, "Day 3:\n\nThis is crazy. The radio and TV broadcasts have been telling everyone to stay indoors and quarantine. Apparently there is a new highly contagious disease that has been spreading. I\'ll stay overnight again and make sure you are taken care of. This is scary.\n\n-"..familyName)
            noteBook:addPage(5, "Day 4:\n\nToday the air is heavy with an odd, sour smell, like a mix of dampness and decay. It is eerie, to say the least. I keep looking through the window, hoping for some reassurance, but all I see are empty streets.\n\n-"..familyName);
            noteBook:addPage(6, "Day 5:\n\nAnother day in the hospital. The smell seems to have intensified and there is chaos in the hospital with nurses and doctors running through the halls. I can\'t find anyone to talk to. I grabbed whatever food I could from the lunchroom and locked myself in your room. I\'ve been hearing the odd screams coming from the hallways.\n\n-"..familyName)
            noteBook:addPage(7, "Day 6:\n\nThe sick people have become monsters. Maybe it\'s something like rabies. The halls are filled with screams and odd noises. I managed to break apart a chair and boarded up our room so they won\'t get us. My heart races every time I hear a nearby noise. I spoke to our family on the phone and they aren\'t doing well either. There is chaos in town and everyone is panicking. They all left for Grandpa\'s old farm. I jotted down all the details on my map. I wish we were with them. I\'m just waiting for the police or military or someone to save us.\n\n-"..familyName)
            noteBook:addPage(8, "Day 7:\n\nI\'ve got it. Whatever everyone has, I\'ve got it. I have a fever and my eyesight is getting blurry. There are dozens of crazies in the hallway. I won\'t turn into them, I\'ve seen what they do. I\'m sorry. Maybe it\'s better you didn\'t see this. I\'ll see you in the next life.\n\n-"..familyName)
            noteBook:setName(iscnModData.playerName.."\'s Journal");
        end        

        local sq = getCell():getGridSquare(12928, 2043, 2);
        if sq ~= nil then
            addBloodSplat(sq, 10, 1);
        end             
        
        local c = ImmersiveScenarios.getContainer(12926, 2040, 2);        
        if c ~= nil then            
            c:emptyIt(); 
            c:AddItem("Base.Magazine");
            c:AddItem("Base.HandTorch");                    
            c:setExplored(true);
        end
        
        local clim = getClimateManager()
        
        local dur = 48      
        clim:triggerCustomWeatherStage(WeatherPeriod.STAGE_HEAVY_PRECIP, dur);
        
        ImmersiveScenarios.switchLight(12936, 2050, 2, true) -- Spawn Room
        
        ImmersiveScenarios.switchLight(12934, 2030, 2, false)
        ImmersiveScenarios.switchLight(12941, 2016, 2, false)     
        ImmersiveScenarios.switchLight(12940, 2020, 2, false)     
        ImmersiveScenarios.switchLight(12952, 2021, 2, false) 
        ImmersiveScenarios.switchLight(12932, 2016, 2, false)     
        ImmersiveScenarios.switchLight(12927, 2016, 2, false)
        ImmersiveScenarios.switchLight(12929, 2029, 2, false)
        ImmersiveScenarios.switchLight(12930, 2049, 2, false)
        ImmersiveScenarios.switchLight(12930, 2059, 2, false)
        ImmersiveScenarios.switchLight(12930, 2044, 2, false)
        ImmersiveScenarios.switchLight(12934, 2030, 2, false)
        ImmersiveScenarios.switchLight(12923, 2074, 2, false)
        ImmersiveScenarios.switchLight(12935, 2035, 2, false)
        ImmersiveScenarios.switchLight(12933, 2024, 2, false)
        ImmersiveScenarios.switchLight(12944, 2024, 2, false)
        ImmersiveScenarios.switchLight(12947, 2065, 2, false)
        ImmersiveScenarios.switchLight(12950, 2057, 2, false)
            
        iscnModData.doAlarm = false       
        if iscnModData.normalMode or iscnModData.hardMode then            
            iscnModData.doAlarm = true 
        end        
        
        iscnModData.journalSpawned = false
        iscnModData.earlyFlicker = math.floor(iscnModData.hoursUntilPower/2)
        iscnModData.lastFlicker = iscnModData.hoursUntilPower-ZombRand(2,3)
        iscnModData.turnPowerOff = false;
        iscnModData.powerRestored = false;
        iscnModData.finishScenario = false
        
        IScnHospital.setSandBoxVars();
                
        IScnHospital.AddZombies();                
        
        IScnHospital.EnableEvents();
        
        iscnModData.startconditionsset = true;

        pl:playSound("LightBulbAmbiance");

end

IScnHospital.EnableEvents = function()
    -- This executes once at startup and every ten min
    Events.EveryTenMinutes.Add( IScnHospital.EveryTenMin );
    Events.EveryTenMinutes.Add( IScnHospital.EveryTenMinLoot )
    -- Triggers when the player moves
    Events.OnPlayerMove.Add( ImmersiveScenarios.OnPlayerMove );
end

IScnHospital.EveryTenMinLoot = function()
    local sq = getCell():getGridSquare(11129, 6851, 0);
    if sq ~= nil then
        local iscnModData = ModData.get("IScnData")
        
        if iscnModData.journalSpawned ~= true then
            local noteBook = sq:AddWorldInventoryItem("Base.Journal", 0.5, 0.5, 0);
            noteBook:setCanBeWrite(true);
            
            noteBook:addPage(1, "What is the world coming to? First poor "..iscnModData.playerName.." gets into a serious car accident and now, people all over town are getting sick.")
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
            
            Events.EveryTenMinutes.Remove(IScnHospital.EveryTenMinLoot)
        end
    end
end

IScnHospital.EveryTenMin = function()
    -- This executes once at startup and every ten min
    DebugLog.log("IScn::EveryTenMin")

    local pl = getPlayer();
    local iscnModData = ModData.get("IScnData")

    iscnModData.minCounter = iscnModData.minCounter + 10;   

    local clim = getClimateManager()
    local thunder = clim:getThunderStorm();
    thunder:triggerThunderEvent(12929, 2043, true, true, true)

    local hoursSurvived = pl:getHoursSurvived()
    if iscnModData.finishScenario then
    
        local sandbox = getSandboxOptions()
        -- Error Checking
        if sandbox:getOptionByName("ElecShutModifier"):getValue() ~= iscnModData.elecShutModifier then
            -- Error, didn't take try again
            print("IScn: Power On Error, Trying Again")
            sandbox:set("ElecShutModifier", iscnModData.elecShutModifier)
            sandbox:toLua()
            sandbox:updateFromLua()
            sandbox:applySettings()
        else
            -- All Ok
            print("IScn: Finishing Scenario")
            if iscnModData.doAlarm then
                DebugLog.log("IScn::doAlarm")
                -- local sq = getCell():getGridSquare(12931,2043, 0);
                -- if sq ~= nil then
                    -- DebugLog.log("IScn::sq OK")
                    -- --sq:getBuilding():TriggerAlarm()
                    -- hospitalBldgDef = sq:getBuilding():getDef()
                    -- if hospitalBldgDef then
                        -- DebugLog.log("IScn::Enabling Alarm")
                        -- hospitalBldgDef:setAlarmed(true);
                    -- else
                        -- DebugLog.log("IScn::Alarm Error, Hospital not found")
                    -- end
                -- end
                hospitalBldgDef = getWorld():getMetaGrid():getBuildingAt(12931,2043)                
                if hospitalBldgDef then
                    DebugLog.log("IScn::Enabling Alarm")
                    hospitalBldgDef:setAlarmed(true);
                else
                    print("IScn::Alarm Error, Hospital not found")
                end                
            end

            iscnModData.powerRestored = true        
             
            Events.EveryTenMinutes.Remove(IScnHospital.EveryTenMin)
            Events.EveryOneMinute.Remove(IScnHospital.EveryOneMin)
        end        
        
    elseif hoursSurvived > iscnModData.hoursUntilPower then
    
        -- Restore Power
        print("IScn::Restoring Power")
        
        local sandbox = getSandboxOptions()
        sandbox:set("ElecShutModifier", iscnModData.elecShutModifier)
        sandbox:toLua()
        sandbox:updateFromLua()
        sandbox:applySettings()

        pl:playSound("LightBulbAmbiance");

        Events.EveryOneMinute.Remove(IScnHospital.EveryOneMin)
                
        iscnModData.finishScenario = true
        
    elseif math.floor(hoursSurvived) == iscnModData.earlyFlicker or math.floor(hoursSurvived) == iscnModData.lastFlicker then
        
        DebugLog.log("IScn::Flickering Off Power")
        
        -- Flicker it off, let event turn it back on
        iscnModData.flickerOn = ZombRand(3,7)
        Events.EveryOneMinute.Add(IScnHospital.EveryOneMin)
        
        local sandbox = getSandboxOptions()
        sandbox:set("ElecShutModifier", -1)
        sandbox:toLua()
        sandbox:updateFromLua()
        sandbox:applySettings()     
        
        iscnModData.turnPowerOff = true;
        
    elseif iscnModData.turnPowerOff then
    
        DebugLog.log("IScn::Turn Off Power")
    
        local sandbox = getSandboxOptions()
        sandbox:set("ElecShutModifier", -1)
        sandbox:toLua()
        sandbox:updateFromLua()
        sandbox:applySettings()     
        
        iscnModData.turnPowerOff = false;
        
    end
    
end

IScnHospital.EveryOneMin = function()
    
    DebugLog.log("IScn::EveryOneMin")
    
    local iscnModData = ModData.get("IScnData")

    iscnModData.flickerOn = iscnModData.flickerOn - 1
    if iscnModData.flickerOn <= 1 then     
        -- Flicker Power On
        DebugLog.log("IScn::Power Flicker On")
        
        getPlayer():playSound("LightBulbAmbiance");
        
        local sandbox = getSandboxOptions()
        sandbox:set("ElecShutModifier", iscnModData.elecShutModifier)
        sandbox:toLua()
        sandbox:updateFromLua()
        sandbox:applySettings()           

        iscnModData.turnPowerOff = true

        Events.EveryOneMinute.Remove(IScnHospital.EveryOneMin)
    end    
end

IScnHospital.DifficultyCheck = function()
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
        iscnModData.hoursUntilPower = ZombRand(10,14);
    elseif iscnModData.hardMode then
        iscnModData.normalMode = false;
        iscnModData.difficultymodifier = ZombRand(10,20);
        iscnModData.injurytimemodifier = ZombRand(10,30);
        iscnModData.drunkmodifier = 50;
        iscnModData.hoursUntilPower = ZombRand(24,30);
    else
        iscnModData.difficultymodifier = ZombRand(5,10);
        iscnModData.injurytimemodifier = ZombRand(10,20);
        iscnModData.drunkmodifier = 25;
        iscnModData.hoursUntilPower = ZombRand(24,30);
    end

    --FOR DEBUG
    --iscnModData.hoursUntilPower = 8;

end

IScnHospital.ApplyInjuries = function() 
    local pl = getPlayer();
    local iscnModData = ModData.get("IScnData")

    damage = 30 + iscnModData.difficultymodifier;
    injurytime = 35 + iscnModData.injurytimemodifier;

    local leg = ZombRand(2)+1;
    if iscnModData.normalMode then
        -- leg injury       
        if leg == 1 then
            pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):AddDamage(damage);
            pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):setFractureTime(injurytime);
            pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):setSplint(true, .8);
            pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):setBandaged(true, 5, true, "Base.AlcoholBandage");
        else
            pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):AddDamage(damage);
            pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):setFractureTime(injurytime);
            pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):setSplint(true, .8);
            pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):setBandaged(true, 5, true, "Base.AlcoholBandage");
        end
    elseif iscnModData.hardMode then            
        if leg == 1 then
            pl:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):AddDamage(damage);
            pl:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):setFractureTime(injurytime);
            pl:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):setSplint(true, .8);
            pl:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):setBandaged(true, 5, true, "Base.AlcoholBandage");
        else
            pl:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):AddDamage(damage);
            pl:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):setFractureTime(injurytime);
            pl:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):setSplint(true, .8);
            pl:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):setBandaged(true, 5, true, "Base.AlcoholBandage");
        end
    end
    
    local arm = ZombRand(2)+1;
    if iscnModData.normalMode then 
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
        
    local iscnModData = ModData.get("IScnData")
    iscnModData.triggers = {}
              
    -- Spawn Front of Room
    local zombieBody = ImmersiveScenarios.CreateZombieBody(12939, 2043, 2, "Nurse", false, IsoDirections.N)
    local zombieEater = ImmersiveScenarios.CreateZombieEater(zombieBody, 12939, 2043, 2, "Doctor", 4)    
    -- Trigger Scream
    ImmersiveScenarios.CreateSoundTrigger(12930, 2043, 2, "PZ_FemaleBeingEaten_Death", 12939, 2043, 2, 1);

    local zombieBody = ImmersiveScenarios.CreateZombieBody(12947, 2053, 2, "HospitalPatient")
    ImmersiveScenarios.CreateZombieEater(zombieBody, 12947, 2053, 2, "HospitalPatient", 4, nil, nil)
        
    addZombiesInOutfit(12927, 2061, 2, 1, "Nurse", 50); 
    addZombiesInOutfit(12927, 2061, 2, 1, nil, 50); 
    
    addZombiesInOutfit(12947, 2042, 2, 1, "Nurse", 50); 
    addZombiesInOutfit(12947, 2042, 2, 1, nil, 50);
            
    addZombiesInOutfit(12932, 2010, 2, 1, "Doctor", 50);                 
    addZombiesInOutfit(12932, 2010, 2, 3, "Nurse", 50); 
    addZombiesInOutfit(12932, 2010, 2, 1, "HospitalPatient", 50);                 
            
    addZombiesInOutfit(12960, 2009, 2, 1, "Doctor", 50);             
    addZombiesInOutfit(12955, 2009, 2, 1, "HospitalPatient", 50);
    addZombiesInOutfit(12926, 2024, 2, 1, "Nurse", 50);
       
    -- Front of nursery
    local zombieBody = ImmersiveScenarios.CreateZombieBody(12928, 2019, 2, nil)
    ImmersiveScenarios.CreateZombieEater(zombieBody, 12928, 2019, 2, nil)  
       
    -- Third floor waiting area
    addZombiesInOutfit(12954, 2024, 2, 3, nil, 50);
    local zombieBody = ImmersiveScenarios.CreateZombieBody(12945, 2023, 2, nil)
    ImmersiveScenarios.CreateZombieEater(zombieBody, 12945, 2023, 2, nil)    
            
    -- Second floor recovery room     
    addZombiesInOutfit(12933, 2033, 1, 2, "Doctor", 50);
    addZombiesInOutfit(12933, 2033, 1, 3, "Nurse", 50); 
    addZombiesInOutfit(12933, 2033, 1, 6, "HospitalPatient", 50); 
    
    local zombieBody = ImmersiveScenarios.CreateZombieBody(12933, 2032, 1, "Nurse", false)
    ImmersiveScenarios.CreateZombieEater(zombieBody, 12933, 2032, 1, "HospitalPatient")
    
    local zombieBody = ImmersiveScenarios.CreateZombieBody(12934, 2034, 1, "Doctor")
    ImmersiveScenarios.CreateZombieEater(zombieBody, 12934, 2034, 1, "HospitalPatient")

    -- Elevator
    local zombieBody = ImmersiveScenarios.CreateZombieBody(12933, 2077, 1, "Tourist", false, IsoDirections.N)
    ImmersiveScenarios.CreateZombieEater(zombieBody, 12933, 2077, 1, "TinFoilHat")
            
    addZombiesInOutfit(12950, 2060, 1, 2, "Nurse", 50); 
    addZombiesInOutfit(12950, 2060, 1, 2, "HospitalPatient", 50);
    
    addZombiesInOutfit(12952, 2029, 1, 8, "OfficeWorker", 50);
    
    addZombiesInOutfit(12973, 2021, 1, 2, "OfficeWorkerSkirt", 50);
    
    addZombiesInOutfit(12942, 2011, 1, 3, nil, 50);
    
    addZombiesInOutfit(12928, 2026, 1, 2, "Doctor", 50);
    
    -- Empty Wing
    addZombiesInOutfit(12985, 2014, 1, 1, "HospitalPatient", 50, true, true, true, true, 20);
    addZombiesInOutfit(12986, 2015, 1, 1, "HospitalPatient", 100, true, true, true, true, 20);
    addZombiesInOutfit(12984, 2024, 1, 1, "HospitalPatient", 50, true, true, true, true, 20);    
    
    local zombieBody = ImmersiveScenarios.CreateZombieBody(12985, 2024, 1, "Nurse", false)
    local zombieEater = ImmersiveScenarios.CreateZombieEater(zombieBody, 12985, 2024, 1, "Punk")

    local zombieBody = ImmersiveScenarios.CreateZombieBody(12942, 2011, 1, nil)
    ImmersiveScenarios.CreateZombieEater(zombieBody, 12942, 2011, 1, "Punk")
    
    addZombiesInOutfit(12949, 2010, 0, 1, "Doctor", 50);                 
    addZombiesInOutfit(12949, 2010, 0, 2, "Nurse", 50); 
    addZombiesInOutfit(12949, 2010, 0, 2, "HospitalPatient", 50);        
    
    addZombiesInOutfit(12930, 2048, 0, 3, "OfficeWorker", 50);
            
    -- Morgue
    addZombiesInOutfit(12957, 2001, 0, 2, "Doctor", 50); 
    addZombiesInOutfit(12957, 2001, 0, 2, "Nurse", 50); 
    addZombiesInOutfit(12957, 2001, 0, 5, "HospitalPatient", 50); 
    addZombiesInOutfit(12957, 2001, 0, 5, nil, 50); 
    
    -- Cafeteria First floor
    addZombiesInOutfit(12935, 2016, 0, 8, nil, 50); 
    local zombieBody = ImmersiveScenarios.CreateZombieBody(12935, 2016, 0, "Classy", false, IsoDirections.S)
    ImmersiveScenarios.CreateZombieEater(zombieBody, 12935, 2016, 0, "Cook_Generic")

    local zombieBody = ImmersiveScenarios.CreateZombieBody(12926, 2021, 0, nil)
    ImmersiveScenarios.CreateZombieEater(zombieBody, 12926, 2021, 0, "Cook_Generic")
    
    -- Waiting Area
    addZombiesInOutfit(12974, 2015, 0, 4, nil, 50); 
    local zombieBody = ImmersiveScenarios.CreateZombieBody(12974, 2015, 0, "AmbulanceDriver")
    ImmersiveScenarios.CreateZombieEater(zombieBody, 12974, 2015, 0, "AmbulanceDriver")
    
    -- Hallway
    local zombieBody = ImmersiveScenarios.CreateZombieBody(12938, 2046, 0, nil)
    ImmersiveScenarios.CreateZombieEater(zombieBody, 12938, 2046, 0, nil)
        
    -- Toy Store
    local zombieBody = ImmersiveScenarios.CreateZombieBody(12950, 2055, 0, nil)
    ImmersiveScenarios.CreateZombieEater(zombieBody, 12950, 2055, 0, nil)    
    
    addZombiesInOutfit(12958, 2014, 0, 3, nil, 50); 
    
    addZombiesInOutfit(12959, 2008, 0, 2, "MallSecurity", 50); 
    addZombiesInOutfit(12952, 2048, 0, 2, "MallSecurity", 50); 
    
    addZombiesInOutfit(12931, 2066, 0, 1, "PharmacistM", 50); 
    
    addZombiesInOutfit(12946, 2053, 0, 1, "PharmacistM", 50); 
    addZombiesInOutfit(12945, 2049, 0, 1, "PharmacistM", 50); 
    addZombiesInOutfit(12946, 2059, 0, 6, nil, 50); 
    
    addZombiesInOutfit(12949, 2074, 0, 4, nil, 50); 

    addZombiesInOutfit(12966, 2029, 0, 2, "Doctor", 50);
    addZombiesInOutfit(12966, 2029, 0, 2, "Nurse", 50); 
    addZombiesInOutfit(12966, 2029, 0, 4, "HospitalPatient", 50);        
    
    -- Front Area
    local zombieBody = ImmersiveScenarios.CreateZombieBody(12928, 2082, 0, "Fisherman", false, IsoDirections.N)
    ImmersiveScenarios.CreateZombieEater(zombieBody, 12928, 2082, 0, "Young")
    
    local zombieBody = ImmersiveScenarios.CreateZombieBody(12930, 2082, 0, "Young", true, IsoDirections.E)
    ImmersiveScenarios.CreateZombieEater(zombieBody, 12930, 2082, 0, "WaiterStripper")
    
    -- Overflow area
    local zombieBody = ImmersiveScenarios.CreateZombieBody(12964, 2024, 0, "AmbulanceDriver")
    ImmersiveScenarios.CreateZombieEater(zombieBody, 12964, 2024, 0, "Cyclist")
    
    local zombieBody = ImmersiveScenarios.CreateZombieBody(12966, 2028, 0, "AmbulanceDriver")
    ImmersiveScenarios.CreateZombieEater(zombieBody, 12966, 2028, 0, "Waiter_Classy")
    
    -- Trash Area        
    addZombiesInOutfit(12943, 1997, 0, 1, "Nurse", 50, true, false, true, true, 10);
    addZombiesInOutfit(12943, 1998, 0, 1, "Dean", 50, true, false, true, true, 10);
    addZombiesInOutfit(12943, 1999, 0, 1, "Cook_IceCream", 50, true, false, true, true, 10);
    addZombiesInOutfit(12943, 2000, 0, 1, nil, 50, true, false, true, true, 10);
    
    addZombiesInOutfit(12944, 1997, 0, 1, nil, 50, true, false, true, true, 10);
    local zombieBody = ImmersiveScenarios.CreateZombieBody(12944, 1998, 0, "Classy")
    ImmersiveScenarios.CreateZombieEater(zombieBody, 12944, 1998, 0, "Doctor")
    addZombiesInOutfit(12944, 1999, 0, 1, "Young", 50, true, false, true, true, 10);
    addZombiesInOutfit(12944, 2000, 0, 1, "Doctor", 50, true, false, true, true, 10);    
    
    addZombiesInOutfit(12945, 1997, 0, 1, "HospitalPatient", 50, true, false, true, true, 10);
    local zombieBody = ImmersiveScenarios.CreateZombieBody(12945, 1998, 0, nil, false)
    ImmersiveScenarios.CreateZombieEater(zombieBody, 12945, 1998, 0, "Doctor")
    addZombiesInOutfit(12945, 1999, 0, 1, "SportsFan", 50, true, false, true, true, 10);
    addZombiesInOutfit(12945, 2000, 0, 1, "HospitalPatient", 50, true, false, true, true, 10); 
    
    addZombiesInOutfit(12946, 1997, 0, 1, "HospitalPatient", 50, true, false, true, true, 10);
    addZombiesInOutfit(12946, 1998, 0, 1, "Young", 50, true, false, true, true, 10);
    addZombiesInOutfit(12946, 1999, 0, 1, nil, 50, true, false, true, true, 10);
    addZombiesInOutfit(12946, 2000, 0, 1, "Redneck", 50, true, false, true, true, 10); 
         
    -------------------
    --TESTING INFO
    --------------------
    -- Sounds
    --PZ_FemaleBeingEaten_Death
    --fscream1
    --PZ_FemaleZombieEating
    --PZ_MaleZombieEating
    --------------------
    --addZombiesInOutfit(x, y, z, count, outfit, Integer femaleChance, crawler, isFallOnFront, isFakeDead, knockedDown, float health);
    --addZombiesInOutfit(12939, 2043, 2, 1, "Nurse", 100, true, false, true, true, 10); This Works, dead!
    --addZombiesInOutfit(12939, 2043, 2, 1, "Doctor", 100, true, true, true, true, 1); -- This WORKS dead!
    --addZombiesInOutfit(12941, 2043, 2, 1, "Doctor", 0, true, true, false, true, 1); -- This WORKS crawler
    --addZombiesInOutfit(12941, 2043, 2, 1, "Doctor", 0, false, false, true, false, 1); -- This WORKS standing!
    --addZombiesInOutfit(12941, 2043, 2, 1, "Doctor", 0, false, false, false, true, 10); -- This WORKS standing, turns into fakeDead when killed!
    --addZombiesInOutfit(12941, 2043, 2, 1, "Doctor", 0, false, false, false, false, 10); -- This WORKS standing, but won't turn into fakeDead when killed!
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
    
end

IScnHospital.setSandBoxVars = function()
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
    gt:setTimeOfDay(IScnHospital.hourOfDay);
       
    iscnModData.elecShutModifier = sandbox:getOptionByName("ElecShutModifier"):getValue()
    DebugLog.log("IScn:ElecShutModifier: "..iscnModData.elecShutModifier)
    
    -- Turn off electricity temporarily
    sandbox:set("ElecShutModifier", -1)
    sandbox:toLua()
    sandbox:updateFromLua()
    sandbox:applySettings()
    
    DebugLog.log("IScn:ElecShutModifier: "..sandbox:getOptionByName("ElecShutModifier"):getValue())

end

IScnHospital.OnInitGlobalModData = function()
    -- This creation marks the scenario as active
    local iscnModData = ModData.create("IScnData")
    
    iscnModData.id = IScnHospital.id
    
    if getActivatedMods():contains("BarricadedStart") then
        -- Compatibility with Immersive Barricaded Start
        getPlayer:getModData().WMAR.HasModBeenRan = true
    end
end

-----------------------------------------------------
-- Default Challenge/LastStand functions below
-----------------------------------------------------

IScnHospital.OnInitWorld = function()
        
    DebugLog.log("IScn:OnInitWorld")    
    
    Events.OnInitGlobalModData.Add(IScnHospital.OnInitGlobalModData);    
    
    --Events.OnCreatePlayer.Add(IScnHospital.OnCreatePlayer)
end

IScnHospital.OnCreatePlayer = function(playerIndex, pl)
    --DebugLog.log("ISCN::TEST")
    
    --pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):AddDamage(50);
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

IScnHospital.hourOfDay = 21; -- Force Nighttime

Events.OnChallengeQuery.Add(IScnHospital.Add)

Events.OnGameStart.Add(IScnHospital.OnGameStart);