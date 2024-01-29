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

---@param _barricade IsoDoor|IsoWindow|IsoThumpable
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
        DebugLog.log("Module is not ISCN_module");
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
            IsoBarricade.AddBarricadeToObject(object, true)
            IsoBarricade.AddBarricadeToObject(object, false)
            local barricade = IsoBarricade.GetBarricadeOppositeCharacter(object, _ISCN_player)
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
    else
        DebugLog.log("Server has received invalide command in ISCNmodule.");
    end
end

Events.OnClientCommand.Add(ISCN_server.OnBarricadeCommand);

return ISCN_server;