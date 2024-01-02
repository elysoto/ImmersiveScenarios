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