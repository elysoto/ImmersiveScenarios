require "ISMapDefinitions"

local MINZ = 0
local MAXZ = 24

local WATER_TEXTURE = false

local LVx = 11700
local LVy = 900
local LVw = 300 * 4
local LVh = 300 * 4
local LVdx = 300 * 3
local LVdy = 300 * 3
local LVbadgeHgt = 150
local function lvGridX1(col)
	return LVx + LVdx * col
end
local function lvGridY1(row)
	return LVy + LVdy * row - LVbadgeHgt
end
local function lvGridX2(col)
	return lvGridX1(col) + LVw - 1
end
local function lvGridY2(row)
	return lvGridY1(row) + LVh - 1 + LVbadgeHgt
end

local function replaceWaterStyle(mapUI)
	if not WATER_TEXTURE then return end
	local mapAPI = mapUI.javaObject:getAPIv1()
	local styleAPI = mapAPI:getStyleAPI()
	local layer = styleAPI:getLayerByName("water")
	if not layer then return end
	layer:setMinZoom(MINZ)
	layer:setFilter("water", "river")
	layer:removeAllFill()
	layer:removeAllTexture()
	layer:addFill(MINZ, 59, 141, 149, 255)
	layer:addFill(MAXZ, 59, 141, 149, 255)
end

local function overlayPNG(mapUI, x, y, scale, layerName, tex, alpha)
	local texture = getTexture(tex)
	if not texture then return end
	local mapAPI = mapUI.javaObject:getAPIv1()
	local styleAPI = mapAPI:getStyleAPI()
	local layer = styleAPI:newTextureLayer(layerName)
	layer:setMinZoom(MINZ)
	layer:addFill(MINZ, 255, 255, 255, (alpha or 1.0) * 255)
	layer:addTexture(MINZ, tex)
	layer:setBoundsInSquares(x, y, x + texture:getWidth() * scale, y + texture:getHeight() * scale)
end

LootMaps.Init.IScnHospital_Stash_WP = function(mapUI)
	local mapAPI = mapUI.javaObject:getAPIv1()
	MapUtils.initDirectoryMapData(mapUI, 'media/maps/Muldraugh, KY')
	MapUtils.initDefaultStyleV1(mapUI)
	replaceWaterStyle(mapUI)
	mapAPI:setBoundsInSquares(10820, 6500, 12389, 7469)
	overlayPNG(mapUI, 10868, 7314, 0.666, "badge", "media/textures/worldMap/WestPointBadge.png")
	overlayPNG(mapUI, 10956, 7006, 0.666, "legend", "media/textures/worldMap/Legend.png")
	MapUtils.overlayPaper(mapUI)
--	overlayPNG(mapUI, 36*300, 21*300+190, 0.666, "lootMapPNG", "media/ui/LootableMaps/westpointmap.png", 0.5)
end