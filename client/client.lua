local isCuffed = false

local DisablePlayerFiring = DisablePlayerFiring
local DisableControlAction = DisableControlAction

---comment
local function cuffs()
    local dict = 'mp_arresting'

    while isCuffed do
        if not IsEntityPlayingAnim(cache.ped, dict, 'idle', 3) then
            lib.requestAnimDict(dict)
            TaskPlayAnim(cache.ped, dict, 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
        end

        DisablePlayerFiring(cache.playerId, true)
        DisableControlAction(0, 140, true)
        Wait(0)
    end

    ClearPedTasks(cache.ped)
    RemoveAnimDict(dict)
end

---comment
---@param ped any
---@return boolean
local function canInteract(ped)
    return GetVehiclePedIsIn(ped, false) == 0 --and not IsPedDeadOrDying(ped)
end

---comment
---@param ped any
local function cuffPlayer(ped)

    if not canInteract(ped) then -- Check for the export
        return
    end

    local playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))

    local canUse, state = lib.callback.await("7Cuffs:Server:canInteract", false, playerId)

    if not canUse then
        return
    end

   LocalPlayer.state.invBusy = true

    FreezeEntityPosition(cache.ped, true)
    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
    AttachEntityToEntity(cache.ped, ped, 11816, -0.07, -0.58, 0.0, 0.0, 0.0, 0.0, false, false , false, true, 2, true)

    local dict = state and 'mp_arresting' or 'mp_arrest_paired'
    lib.requestAnimDict(dict)

    if state then
        TaskPlayAnim(cache.ped, dict, 'a_uncuff', 8.0, -8, 5500, 0, 0, false, false, false)
        Wait(5000)
    else
        TaskPlayAnim(cache.ped, dict, 'cop_p2_back_right', 8.0, -8.0, 3750, 2, 0.0, false, false, false)
        Wait(4000)
    end

    DetachEntity(cache.ped, true, false)
    FreezeEntityPosition(cache.ped, false)
    RemoveAnimDict(dict)

   LocalPlayer.state.invBusy = false
end


AddStateBagChangeHandler('hasCuffs', ("player:%d"):format(cache.serverId), function(bagName, key, state)

    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
    FreezeEntityPosition(cache.ped, true)

    local dict = state and 'mp_arrest_paired' or 'mp_arresting'
    lib.requestAnimDict(dict)

    if state then
        TaskPlayAnim(cache.ped, dict, 'crook_p2_back_right', 8.0, -8, 5000, 2, 0, false, false, false)
        Wait(5000)
    else
        TaskPlayAnim(cache.ped, dict, 'arrested_spin_l_0', 8.0, -8, 4000, 0, 0, false, false, false)
        Wait(4000)
    end

    SetEnableHandcuffs(cache.ped, state)
    LocalPlayer.state.invBusy = state
    RemoveAnimDict(dict)
    FreezeEntityPosition(cache.ped, false)
    isCuffed = state
    
    if isCuffed then
        cuffs()
    end

    ClearPedTasks(cache.ped)
end)

exports.ox_target:addGlobalPlayer({
    {
        name = '7Cuffs:cuff',
        icon = 'fas fa-handcuffs',
        label = 'Handcuff Player',
        distance = 1.5,
        items = C.items.cuffs,
        canInteract = function(entity)
            return canInteract(entity) and not IsPedCuffed(entity) and not LocalPlayer.state.invBusy
        end,
        onSelect = function(data)
            cuffPlayer(data.entity)
        end
    },
    {
        name = '7Cuffs:uncuff',
        icon = 'fas fa-handcuffs',
        label = 'Remove Handcuffs',
        distance = 1.5,
        items = C.items.key,
        canInteract = function(entity)
            return canInteract(entity) and IsPedCuffed(entity) and not LocalPlayer.state.invBusy
        end,
        onSelect = function(data)
            cuffPlayer(data.entity)
        end
    },
})

exports("cuffPlayer", cuffPlayer)
