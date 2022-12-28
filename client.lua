ESX = nil
local blipsSelect = {}
local iBlips = {}
local listBlips = {}
local iBlipsText = {
    label = "~r~ Indéfini",
    coord = "~r~ Indéfini",
    type = "~r~ Indéfini",
    color = "~r~ Indéfini"
}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(10)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

local function iBlipsBuilderKeyboard(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    blockinput = true
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Wait(0)
    end 
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end

Citizen.CreateThread(function()
    ESX.TriggerServerCallback('iBlipsBuilder:getAllBlips', function(result)
        for i = 1, #result, 1 do
            local blip = AddBlipForCoord(json.decode(result[i].coord).x, json.decode(result[i].coord).y, json.decode(result[i].coord).z)
            SetBlipSprite(blip, tonumber(result[i].type))
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, tonumber(result[i].color))
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(tostring(result[i].label))
            EndTextCommandSetBlipName(blip)
        end
    end)
end)

local function mainBlipsBuilder()
    local mainMenu = RageUI.CreateMenu("BlipsBuilder", "iDev")
    local builderMenu = RageUI.CreateSubMenu(mainMenu, "Création", "iDev")
    local gestionMenu = RageUI.CreateSubMenu(mainMenu, "Gestion", "iDev")
    local blipsMenu = RageUI.CreateSubMenu(gestionMenu, "Gestion", "iDev")
    mainMenu:SetRectangleBanner(11,11,11,1)
    builderMenu:SetRectangleBanner(11,11,11,1)
    gestionMenu:SetRectangleBanner(11,11,11,1)
    blipsMenu:SetRectangleBanner(11,11,11,1)
    RageUI.Visible(mainMenu, not RageUI.Visible(mainMenu))
    while mainMenu do
        Citizen.Wait(0)
        RageUI.IsVisible(mainMenu, true, true, true, function()
            RageUI.ButtonWithStyle("→→ Menu Création", nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
            end, builderMenu)

            RageUI.ButtonWithStyle("→→ Menu Gestion", nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
            end, gestionMenu)
    
        end, function()
        end)

        RageUI.IsVisible(builderMenu, true, true, true, function()
            RageUI.ButtonWithStyle('Label', nil, {RightLabel = iBlipsText.label}, true, function(Hovered, Active, Selected)
                if Selected then
                    local iLabel = iBlipsBuilderKeyboard("Nom", "", 15)
                    if iLabel == nil then
                        ESX.ShowNotification("[~y~Attention~s~] Aucun ~r~Label ~s~renseigné")
                    else
                        iBlips.label = iLabel
                        iBlipsText.label = iLabel
                    end
                end
            end)
            RageUI.ButtonWithStyle('Coordonnées', nil, {RightLabel = iBlipsText.coord}, true, function(Hovered, Active, Selected)
                if Selected then
                    iBlips.coord = GetEntityCoords(GetPlayerPed(-1))
                    iBlipsText.coord = "~g~Défini"
                end
            end)
            RageUI.ButtonWithStyle('Type', nil, {RightLabel = iBlipsText.type}, true, function(Hovered, Active, Selected)
                if Selected then
                    local iType = iBlipsBuilderKeyboard("Type", "", 3)
                    if tonumber(iType) then
                        iBlips.type = iType
                        iBlipsText.type = iType
                    else
                        ESX.ShowNotification("[~y~Attention~s~] Le ~r~Type~s~ doit-être un nombre")
                    end
                end
            end)
            RageUI.ButtonWithStyle('Couleur', nil, {RightLabel = iBlipsText.color}, true, function(Hovered, Active, Selected)
                if Selected then
                    local iColor = iBlipsBuilderKeyboard("Couleur", "", 3)
                    if tonumber(iColor) then
                        iBlips.color = iColor
                        iBlipsText.color = iColor
                    else
                        ESX.ShowNotification("[~y~Attention~s~] La ~r~Couleur~s~ doit-être un nombre")
                    end
                end
            end)

            RageUI.Separator('↓ ~b~Action~s~ ↓')

            RageUI.ButtonWithStyle('~g~Valider', nil, { RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    if iBlips.label == nil or iBlips.coord == nil or iBlips.type == nil or iBlips.color == nil then
                        ESX.ShowNotification('Veuillez renseigné tout les champs')
                    else
                        TriggerServerEvent("iBlipsBuilder:addBlips", iBlips)
                        iBlips = {}
                        iBlipsText = {
                            label = "~r~ Indéfini",
                            coord = "~r~ Indéfini",
                            type = "~r~ Indéfini",
                            color = "~r~ Indéfini"
                        }
                        RageUI.CloseAll()
                    end
                end
            end)
            RageUI.ButtonWithStyle('~r~Annuler', nil, { RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    RageUI.CloseAll()
                end
            end)
        
        end, function()
        end)

        RageUI.IsVisible(gestionMenu, true, true, true, function()
            RageUI.Separator('↓ ~y~Liste des Blips ~s~↓')
            ESX.TriggerServerCallback('iBlipsBuilder:getAllBlips', function(result)
                listBlips = result
            end)
            for i = 1, #listBlips, 1 do
                RageUI.ButtonWithStyle(listBlips[i].label, nil, {RightLabel = "→→"}, true, function(Hovered, active, Selected)
                    if Selected then
                        blipsSelect.id = listBlips[i].id
                        blipsSelect.label = listBlips[i].label
                        blipsSelect.coord = json.decode(listBlips[i].coord)
                        blipsSelect.type = listBlips[i].type
                        blipsSelect.color = listBlips[i].color
                    end
                end, blipsMenu)
            end
        
        end, function()
        end)

        RageUI.IsVisible(blipsMenu, true, true, true, function()
            RageUI.Separator("~y~ID : "..blipsSelect.id)
            RageUI.Separator("~g~Nom : "..blipsSelect.label)
            RageUI.ButtonWithStyle("Modifier le Label", nil, {RightLabel = blipsSelect.label}, true, function(Hovered, Active, Selected)
                if Selected then
                    local newLabel = iBlipsBuilderKeyboard("Nom", "", 15)
                    if newLabel == nil then
                        ESX.ShowNotification("[~y~Attention~s~] Aucun ~r~Label ~s~renseigné")
                    else
                        blipsSelect.label = newLabel
                    end
                end
            end)

            RageUI.ButtonWithStyle('Coordonnées', nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    blipsSelect.coord = GetEntityCoords(GetPlayerPed(-1))
                    ESX.ShowNotification('Coordonnées modifier')
                end
            end)

            RageUI.ButtonWithStyle('Type', nil, {RightLabel = blipsSelect.type}, true, function(Hovered, Active, Selected)
                if Selected then
                    local newType = iBlipsBuilderKeyboard("Type", "", 3)
                    if tonumber(newType) then
                        blipsSelect.type = newType
                    else
                        ESX.ShowNotification("[~y~Attention~s~] Le ~r~Type~s~ doit-être un nombre")
                    end
                end
            end)

            RageUI.ButtonWithStyle('Couleur', nil, {RightLabel = blipsSelect.color}, true, function(Hovered, Active, Selected)
                if Selected then
                    local newColor = iBlipsBuilderKeyboard("Couleur", "", 3)
                    if tonumber(newColor) then
                        blipsSelect.color = newColor
                    else
                        ESX.ShowNotification("[~y~Attention~s~] La ~r~Couleur~s~ doit-être un nombre")
                    end
                end
            end)

            RageUI.Separator('↓ ~y~Action ~s~↓')
            
            RageUI.ButtonWithStyle('~g~Valider', nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerServerEvent('iBlipsBuilder:updateBlips', blipsSelect)
                    RageUI.CloseAll()
                end
            end)

            RageUI.Line()

            RageUI.ButtonWithStyle('~r~Supprimer le blips', nil, { RightLabel = "" }, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerServerEvent('iBlipsBuilder:removeBlips', blipsSelect.id)
                    RageUI.CloseAll()
                end
            end)
        end, function()
        end)


        if not RageUI.Visible(mainMenu) and not RageUI.Visible(builderMenu) and not RageUI.Visible(gestionMenu) and not RageUI.Visible(blipsMenu) then
            mainMenu = RMenu:DeleteType("mainMenu", true)
        end
    end
end


RegisterCommand("blipsbuilder", function()
    ESX.TriggerServerCallback('iBlipsBuilder:getPlayerGroup', function(result) 
        if result == "superadmin" then
            mainBlipsBuilder()
        else
            ESX.ShowNotification("Vous n'avez pas la permissions d'éxécuter cette commande")
        end
    end)
end)
    