ISCN_server = ISCN_server or {}

---@param _x integer
---@param _y integer
---@param _z integer
---@param _index integer
---@return IsoDoor|IsoWindow|IsoThumpable|nil
ISCN_server.GetBarricadeAble = function(_x, _y, _z, _index)
	local sq = getCell():getGridSquare(_x, _y, _z)
	if sq and _index >= 0 and _index < sq:getObjects():size() then
		local o = sq:getObjects():get(_index)
		if instanceof(o, 'BarricadeAble') then
			return o
		end
	end
	return nil
end

---@param _door IsoDoor|IsoWindow|IsoThumpable
---@param _player IsoPlayer
function ISCN_server.RemoveBarricades(_barricade, _player)
    if _barricade then
        local numPlanks = _barricade:getNumPlanks()
        if numPlanks > 0 then
            for i = 1, numPlanks do
                _barricade:removePlank(nil)
            end
        else
            local plank = InventoryItemFactory.CreateItem('Base.Plank')
            _barricade:addPlank(nil, plank)
            _barricade:removePlank(nil)
        end
        _barricade:sendObjectChange('state')
    end
end

---@param _barricade IsoBarricade
---@param _player IsoPlayer
---@param _count integer
---@param _healthMult float
function ISCN_server.DoBarricade(_barricade, _player, _count, _healthMult)
    if _barricade then
        for i = 1, _count do
            local plank = InventoryItemFactory.CreateItem('Base.Plank')
            local health = plank:getCondition()
            plank:setConditionMax(math.floor(health * _healthMult))
            plank:setCondition(math.floor(health * _healthMult), false)
            _barricade:addPlank(_player, plank)
        end
        if _barricade:getNumPlanks() > 1 then
            _barricade:transmitCompleteItemToClients()
        else
            _barricade:sendObjectChange('state')
        end
    end
end

---@param _ISCN_module string
---@param _ISCN_command string
---@param _ISCN_player IsoPlayer
---@param _ISCN_args table
function ISCN_server.OnBarricadeCommand( _ISCN_module, _ISCN_command, _ISCN_player, _ISCN_args)
    -- DebugLog.log("Player has sent ClientCommand, module: ".._ISCN_module.."  command: ".._ISCN_command);
    if _ISCN_module ~= "ISCNmodule" then
        --DebugLog.log("Module is not ISCN_module");
        return;
    end
    if _ISCN_command == "ISCN_BarricadePlayerSide" then
        -- DebugLog.log("Server has received ISCN_BarricadePlayerSide command.");
        local object = ISCN_server.GetBarricadeAble(_ISCN_args.x, _ISCN_args.y, _ISCN_args.z, _ISCN_args.index)
        if object and _ISCN_args.plankNumber and _ISCN_args.plankNumber > 0 then
            local barricade;
            barricade = IsoBarricade.GetBarricadeForCharacter(object, _ISCN_player)
            if not barricade then
                barricade = IsoBarricade.AddBarricadeToObject(object, _ISCN_player)
            end
            ISCN_server.DoBarricade(barricade, _ISCN_player, _ISCN_args.plankNumber, _ISCN_args.plankHealthMult)
        end
    elseif _ISCN_command == "ISCN_BarricadeOppositePlayerSide" then
        -- DebugLog.log("Server has received ISCN_BarricadeOppositePlayerSide command.");
        local object = ISCN_server.GetBarricadeAble(_ISCN_args.x, _ISCN_args.y, _ISCN_args.z, _ISCN_args.index)
        if object and _ISCN_args.plankNumber and _ISCN_args.plankNumber > 0 then
            
            local barricade = IsoBarricade.GetBarricadeOppositeCharacter(object, _ISCN_player)
            if not barricade then  
                local barTry = IsoBarricade.AddBarricadeToObject(object, true)
                barricade = IsoBarricade.GetBarricadeOppositeCharacter(object, _ISCN_player)
                if not barricade then      
                    local plank = InventoryItemFactory.CreateItem('Base.Plank')
                    barTry:addPlank(nil, plank)
                    barTry:removePlank(nil)                    
                    IsoBarricade.AddBarricadeToObject(object, false)
                    barricade = IsoBarricade.GetBarricadeOppositeCharacter(object, _ISCN_player)
                end
            end
            ISCN_server.DoBarricade(barricade, _ISCN_player, _ISCN_args.plankNumber, _ISCN_args.plankHealthMult)
        end
    elseif _ISCN_command == "ISCN_BarricadeBothSides" then
        -- DebugLog.log("Server has received ISCN_BarricadeBothSides command.");
        local object = ISCN_server.GetBarricadeAble(_ISCN_args.x, _ISCN_args.y, _ISCN_args.z, _ISCN_args.index)
        if object and _ISCN_args.plankNumber and _ISCN_args.plankNumber > 0 then
            local barricade = IsoBarricade.AddBarricadeToObject(object, true)
            ISCN_server.DoBarricade(barricade, _ISCN_player, _ISCN_args.plankNumber, _ISCN_args.plankHealthMult)
            local otherSideBarricade = IsoBarricade.AddBarricadeToObject(object, false)
            ISCN_server.DoBarricade(otherSideBarricade, _ISCN_player, _ISCN_args.plankNumber, _ISCN_args.plankHealthMult)
        end
    elseif _ISCN_command == "ISCN_FixBarricades" then
        local object = ISCN_server.GetBarricadeAble(_ISCN_args.x, _ISCN_args.y, _ISCN_args.z, _ISCN_args.index)
        local barricade = IsoBarricade.GetBarricadeForCharacter(object, _ISCN_player)
        if barricade and barricade:isDestroyed() then
            print("ISCN:Found bugged barricade, Fixing! ".._ISCN_args.x.." ".._ISCN_args.y.." ".._ISCN_args.z);
            ISCN_server.RemoveBarricades(barricade, _ISCN_player)
        end
        barricade = IsoBarricade.GetBarricadeOppositeCharacter(object, _ISCN_player)
        if barricade and barricade:isDestroyed() then
            print("ISCN:Found bugged barricade, Fixing! ".._ISCN_args.x.." ".._ISCN_args.y.." ".._ISCN_args.z);
            ISCN_server.RemoveBarricades(barricade, _ISCN_player)
        end    
    elseif _ISCN_command == "ISCN_RemoveBarricades" then
        local object = ISCN_server.GetBarricadeAble(_ISCN_args.x, _ISCN_args.y, _ISCN_args.z, _ISCN_args.index)
        local barricade = IsoBarricade.GetBarricadeOppositeCharacter(object, _ISCN_player)
        if barricade then
            ISCN_server.RemoveBarricades(barricade, _ISCN_player)
        end        
        barricade = IsoBarricade.GetBarricadeForCharacter(object, _ISCN_player)
        if barricade then
            ISCN_server.RemoveBarricades(barricade, _ISCN_player)
        end
    else
        DebugLog.log("Server has received invalide command in ISCNmodule.");
    end
end

Events.OnClientCommand.Add(ISCN_server.OnBarricadeCommand);

return ISCN_server;