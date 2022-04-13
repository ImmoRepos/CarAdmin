ESX = nil

Citizen.CreateThread(function()

	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

    WarMenu.CreateMenu('caradmin', 'Admin', 'Administration')
    -- 1st Level Submenus
    WarMenu.CreateSubMenu('playerlist', 'caradmin', 'Playerlist')
    WarMenu.CreateSubMenu('cargeneral', 'caradmin', 'General Vehicle')
    WarMenu.CreateSubMenu('carmod', 'caradmin', 'Vehicle Mod Menu')
    WarMenu.CreateSubMenu('carextras', 'caradmin', 'Vehicle Extras')
    -- 2nd Level Submenus
    WarMenu.CreateSubMenu('carcolors', 'carmod', 'Vehicle Colors')
    WarMenu.CreateSubMenu('cartuning', 'carmod', 'Vehicle Tuning')
    WarMenu.CreateSubMenu('carlivery', 'carmod', 'Vehicle Livery')
    WarMenu.CreateSubMenu('carneon', 'carmod', 'Vehicle Neon Kit')
    -- 3rd Level Submenus
    WarMenu.CreateSubMenu('carcolorprimary', 'carcolors', 'Primary Color')
    WarMenu.CreateSubMenu('carcolorsecondary', 'carneon', 'Secondary Color')
end)


local playerList = {}
-- Menu Controloptions
local _godModeActive = false
local _liveryIndex = 1
local _underglowIndex = 1
local _enableFrontNeon = false
local _enableRearNeon = false
local _enableLeftNeon = false
local _enableRightNeon = false
local _turbo = false

local _classicIndex = 1
local _matteIndex = 1
local _metalIndex = 1
local _utilIndex = 1
local _wornIndex = 1

Citizen.CreateThread(function ()
    while true do
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if vehicle and _godModeActive then
            SetEntityInvincible(vehicle, _godModeActive)
            SetVehicleCanBeVisiblyDamaged(vehicle, not _godModeActive)
            SetVehicleCanDeformWheels(vehicle, not _godModeActive)
            SetVehicleFixed(vehicle)
            SetVehicleDeformationFixed(vehicle)
        end
        Citizen.Wait(1)
    end
end)

RegisterNetEvent('esx:playerLoaded', function()
    TriggerServerEvent(('%s:checkKey'):format(GetCurrentResourceName()))
end)

RegisterNetEvent(('%s:registerKey'):format(GetCurrentResourceName()), function()
    RegisterKeyMapping('caradmin', 'Administration Menu(old vMenu)', 'keyboard', 'F10')
end)
RegisterNetEvent(('%s:openMenu'):format(GetCurrentResourceName()), function(permissionTable)
    if WarMenu.IsAnyMenuOpened() then
        return
    end

    playerList = {}
    ESX.TriggerServerCallback(('%s:getPlayers'):format(GetCurrentResourceName()), function(players) 
        for key, value in pairs(players) do
            table.insert(playerList, {id = value, player = GetPlayerFromServerId(value)})
        end
    end)


    WarMenu.OpenMenu("caradmin")
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    _turbo = GetVehicleMod(vehicle, 18) ~= -1

    while true do
        if WarMenu.Begin('caradmin') then
            WarMenu.MenuButton('Playerlist', 'playerlist')
            WarMenu.MenuButton('General', 'cargeneral')
            if IsAllowed(permissionTable, 'carmod') then
                WarMenu.MenuButton('Mod Menu', 'carmod')
            end
            if IsAllowed(permissionTable, 'carextras') then
                WarMenu.MenuButton('Vehicle Extras', 'carextras')
            end

            WarMenu.End()
        elseif WarMenu.Begin('playerlist') then
            PlayerList()
            WarMenu.End()
        elseif WarMenu.Begin('cargeneral') then
            if IsAllowed(permissionTable, 'cargodmode') then
                if WarMenu.CheckBox('Car Godmode', _godModeActive) then
                    _godModeActive = not _godModeActive
                end
            end

            if IsAllowed(permissionTable, 'fixcar') then
                if WarMenu.Button('Repair Vehicle') then
                    if vehicle ~= 0 then
                        SetVehicleFixed(vehicle)
                        SetVehicleDeformationFixed(vehicle)
                    end
                end
            end
            if IsAllowed(permissionTable, 'cleancar') then
                if WarMenu.Button('Clean Vehicle') then
                    if vehicle ~= 0 then
                        SetVehicleDirtLevel(vehicle, 0.0)
                        WashDecalsFromVehicle(vehicle, 0.0)
                    end
                end
            end
            if IsAllowed(permissionTable, 'deletecar') then
                if WarMenu.Button('Delete Vehicle') then
                    if vehicle ~= 0 then
                        DeleteVehicle(vehicle)
                    end
                end
            end

            WarMenu.End()
        elseif WarMenu.Begin('carmod') then
            if IsAllowed(permissionTable, 'carcolors') then
                WarMenu.MenuButton('Vehicle Colors', 'carcolors')
            end
            if IsAllowed(permissionTable, 'cartuning') then
                WarMenu.MenuButton('Vehicle Tuning', 'cartuning')
            end
            if IsAllowed(permissionTable, 'carlivery') then
                WarMenu.MenuButton('Vehicle Livery', 'carlivery')
            end
            if IsAllowed(permissionTable, 'carneon') then
                WarMenu.MenuButton('Vehicle Neon Kit', 'carneon')
            end
            WarMenu.End()
        elseif WarMenu.Begin('carextras') then
            ExtrasMenu(vehicle)
            WarMenu.End()
        --2nd Level Submenus
        elseif WarMenu.Begin('carcolors') then
            if IsAllowed(permissionTable, 'carcolorprimary') then
                WarMenu.MenuButton('Primary Color', 'carcolorprimary')
            end
            if IsAllowed(permissionTable, 'carcolorsecondary') then
                WarMenu.MenuButton('Secondary color', 'carcolorsecondary')
            end
            WarMenu.End()
        elseif WarMenu.Begin('carlivery') then
            LiveryMenu(vehicle)
            WarMenu.End()
        elseif WarMenu.Begin('carneon') then
            NeonMenu(vehicle)
            WarMenu.End()
        elseif WarMenu.Begin('cartuning') then
            TuningMenu(vehicle)
            WarMenu.End()
        --3rd Level Submenus
        elseif WarMenu.Begin('carcolorprimary') then
            ColorMenu(vehicle, true)
            WarMenu.End()
        elseif WarMenu.Begin('carcolorsecondary') then
            ColorMenu(vehicle, false)
            WarMenu.End()
        else
            return
        end

        Citizen.Wait(0)
    end
end)

function PlayerList()
    for key, value in pairs(playerList) do
        WarMenu.Button(GetPlayerName(value.player)..(' ID: %s'):format(value.id),'')
    end
end

local mods = {
    brakes = {},
    _brakeIndex = 1,
    trans = {},
    _transIndex = 1,
    engine = {},
    _engineIndex = 1,
    sus = {},
    _susIndex = 1,
}

function TuningMenu(veh)
    for i = 1, GetNumVehicleMods(veh, 12)+1, 1 do
        table.insert(mods.brakes, ('Level %s/%s'):format(i, GetNumVehicleMods(veh, 12)))
    end
    local _, brakeIndex = WarMenu.ComboBox('Brakes', mods.brakes, mods._brakeIndex)
    if mods._brakeIndex ~= brakeIndex then
        mods._brakeIndex = brakeIndex
        SetVehicleMod(veh, 12, mods._brakeIndex-1)
    end

    for i = 1, GetNumVehicleMods(veh, 13)+1, 1 do
        table.insert(mods.trans, ('Level %s/%s'):format(i, GetNumVehicleMods(veh, 13)))
    end
    local _, transIndex = WarMenu.ComboBox('Transmission', mods.trans, mods._transIndex)
    if mods._transIndex ~= transIndex then
        mods._transIndex = transIndex
        SetVehicleMod(veh, 13, mods._transIndex-1)
    end
    
    for i = 1, GetNumVehicleMods(veh, 11)+1, 1 do
        table.insert(mods.engine, ('Level %s/%s'):format(i, GetNumVehicleMods(veh, 11)))
    end
    local _, engineIndex = WarMenu.ComboBox('Engine', mods.engine, mods._engineIndex)
    if mods._engineIndex ~= engineIndex then
        mods._engineIndex = engineIndex
        SetVehicleMod(veh, 11, mods._engineIndex-1)
    end
    
    for i = 1, GetNumVehicleMods(veh, 15)+1, 1 do
        table.insert(mods.sus, ('Level %s/%s'):format(i, GetNumVehicleMods(veh, 15)))
    end
    local _, susIndex = WarMenu.ComboBox('Suspension', mods.sus, mods._susIndex)
    if mods._susIndex ~= susIndex then
        mods._susIndex = susIndex
        SetVehicleMod(veh, 15, mods._susIndex-1)
    end

    if WarMenu.CheckBox('Turbo', _turbo) then
        _turbo = not _turbo
        SetVehicleMod(veh, 18, _turbo)
    end
end

function ExtrasMenu(vehicle)
    if vehicle == 0 then
        WarMenu.OpenMenu('carmod')
    else
        local extras = {}
        for i = 0, 14, 1 do
            if DoesExtraExist(vehicle, i) then
                table.insert(extras, {id = i, state = IsVehicleExtraTurnedOn(vehicle, i)})
            end
        end
        for k, v in pairs(extras) do
            if WarMenu.CheckBox('Extra #'..v.id, extras[k].state) then
                extras[k].state = not extras[k].state
                SetVehicleExtra(vehicle, v.id, not extras[k].state)
            end
        end
    end
end

function ColorMenu(vehicle, isPrimary)
    if vehicle == 0 then
        WarMenu.OpenMenu('carmod')
    else
        local primaryColor, secondaryColor = GetVehicleColours()

        -- Classics
        local classics = {}
        local i = 1
        for index, value in pairs(Colors.Classic) do
            table.insert(classics, ('%s (%s/%s)'):format(GetLabelText(value.name), i, #Colors.Classic))
            i = i + 1
        end
        local _, classicIndex = WarMenu.ComboBox('Classic', classics, _classicIndex)
        if _classicIndex ~= classicIndex then
            _classicIndex = classicIndex
            if isPrimary then
                primaryColor = GetColorFromIndex(_classicIndex, Colors.Classic)
            else
                secondaryColor = GetColorFromIndex(_classicIndex, Colors.Classic)
            end
            SetVehicleColours(vehicle, primaryColor, secondaryColor)
        end
        -- Matte
        local matte = {}
        i = 1
        for index, value in pairs(Colors.Matte) do
            table.insert(matte, ('%s (%s/%s)'):format(GetLabelText(value.name), i, #Colors.Matte))
            i = i + 1
        end
        local _, matteIndex = WarMenu.ComboBox('Matte', matte, _matteIndex)
        if _matteIndex ~= matteIndex then
            _matteIndex = matteIndex
            if isPrimary then
                primaryColor = GetColorFromIndex(_matteIndex, Colors.Matte)
            else
                secondaryColor = GetColorFromIndex(_matteIndex, Colors.Matte)
            end
            SetVehicleColours(vehicle, primaryColor, secondaryColor)
        end
        -- Metal
        local metal = {}
        i = 1
        for index, value in pairs(Colors.Metal) do
            table.insert(metal, ('%s (%s/%s)'):format(GetLabelText(value.name), i, #Colors.Metal))
            i = i + 1
        end
        local _, metalIndex = WarMenu.ComboBox('Metal', metal, _metalIndex)
        if _metalIndex ~= metalIndex then
            _metalIndex = metalIndex
            if isPrimary then
                primaryColor = GetColorFromIndex(_metalIndex, Colors.Metal)
            else
                secondaryColor = GetColorFromIndex(_metalIndex, Colors.Metal)
            end
            SetVehicleColours(vehicle, primaryColor, secondaryColor)
        end
        -- Util
        local util = {}
        i = 1
        for index, value in pairs(Colors.Util) do
            table.insert(util, ('%s (%s/%s)'):format(GetLabelText(value.name), i, #Colors.Util))
            i = i + 1
        end
        local _, utilIndex = WarMenu.ComboBox('Util', util, _utilIndex)
        if _utilIndex ~= utilIndex then
            _utilIndex = utilIndex
            if isPrimary then
                primaryColor = GetColorFromIndex(_utilIndex, Colors.Util)
            else
                secondaryColor = GetColorFromIndex(_utilIndex, Colors.Util)
            end
            SetVehicleColours(vehicle, primaryColor, secondaryColor)
        end
        -- Worn
        local worn = {}
        i = 1
        for index, value in pairs(Colors.Worn) do
            table.insert(worn, ('%s (%s/%s)'):format(GetLabelText(value.name), i, #Colors.Worn))
            i = i + 1
        end
        local _, wornIndex = WarMenu.ComboBox('Worn', worn, _wornIndex)
        if _wornIndex ~= wornIndex then
            _wornIndex = wornIndex
            if isPrimary then
                primaryColor = GetColorFromIndex(_wornIndex, Colors.Worn)
            else
                secondaryColor = GetColorFromIndex(_wornIndex, Colors.Worn)
            end
            SetVehicleColours(vehicle, primaryColor, secondaryColor)
        end
    end
end

function GetColorFromIndex(index, table)
    return table[index].id
end


function NeonMenu(vehicle)
    if vehicle == 0 then
        WarMenu.OpenMenu('carmod')
    else
        -- Underglow Color
        local underglowList = {}
        for i = 0, 13, 1 do
            underglowList[i] = GetLabelText(('CMOD_NEONCOL_%s'):format(tostring(i)))
        end
        local _, underglowIndex = WarMenu.ComboBox('Neon Color', underglowList, _underglowIndex)
        if _underglowIndex ~= underglowIndex then
            _underglowIndex = underglowIndex
            SetVehicleNeonLightsColour(vehicle, Colors.Underglow[_underglowIndex][1], Colors.Underglow[_underglowIndex][2], Colors.Underglow[_underglowIndex][3])
        end
        -- Neon Lights
        if WarMenu.CheckBox('Enable Front Light', _enableFrontNeon) then
            _enableFrontNeon = not _enableFrontNeon
            SetVehicleNeonLightEnabled(vehicle, 2, _enableFrontNeon)
        end
        if WarMenu.CheckBox('Enable Rear Light', _enableRearNeon) then
            _enableRearNeon = not _enableRearNeon
            SetVehicleNeonLightEnabled(vehicle, 3, _enableRearNeon)
        end
        if WarMenu.CheckBox('Enable Left Light', _enableLeftNeon) then
            _enableLeftNeon = not _enableLeftNeon
            SetVehicleNeonLightEnabled(vehicle, 0, _enableLeftNeon)
        end
        if WarMenu.CheckBox('Enable Right Light', _enableRightNeon) then
            _enableRightNeon = not _enableRightNeon
            SetVehicleNeonLightEnabled(vehicle, 1, _enableRightNeon)
        end
    end
end

function LiveryMenu(vehicle)
    if vehicle == 0 then
        WarMenu.OpenMenu('carmod')
    else
        SetVehicleModKit(vehicle, 0)
        local liveryCount = GetVehicleLiveryCount(vehicle)
        if liveryCount > 0 then
            local liveries = {}
            for i = 1, liveryCount, 1 do
                liveries[i] = ('Livery #%s'):format(tostring(i))
            end
            local _, liveryIndex = WarMenu.ComboBox('Set Livery', liveries, _liveryIndex)
            if _liveryIndex ~= liveryIndex then
                _liveryIndex = liveryIndex
                SetVehicleLivery(vehicle, _liveryIndex-1)
            end
        else
            WarMenu.OpenMenu('carmod')
        end
    end
end

function IsAllowed(table, item)
    if table[item] ~= nil then
        return true
    end
    return true
end