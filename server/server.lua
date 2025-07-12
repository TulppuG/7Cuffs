lib.callback.register("7Cuffs:Server:canInteract", function(source, targetId)
    if not GetPlayerName(targetId) then
        return false
    end

    if #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(GetPlayerPed(targetId))) > 10 then -- Coords check
        return false
    end

    local state = Player(targetId).state.hasCuffs 

    if state then
        if exports.ox_inventory:GetItemCount(source, C.items.key) < 1 then
            return false
        end
        exports.ox_inventory:AddItem(source, C.items.cuffs, 1)
    else
        if not exports.ox_inventory:RemoveItem(source, C.items.cuffs, 1) then
            return false
        end
    end

    Player(targetId).state.hasCuffs = not state

    return true, state
end)
