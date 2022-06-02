Peds = {}
PedNames = {}

Citizen.CreateThread(
    function()
        while not exports.data:isUserLoaded() do
            Wait(100)
        end

        loadPeds()
    end
)

function loadPeds()
    Peds = {}
    PedNames = {}

    local kvpHandle = StartFindKvp("mp_ped_")
    if kvpHandle ~= -1 then
        local key
        while true do
            key = FindKvp(kvpHandle)
            if key then
                local data = json.decode(GetResourceKvpString(key))
                local name = key:sub(8)

                table.insert(Peds, data)
                table.insert(PedNames, name)
            else
                break
            end
            Citizen.Wait(0)
        end

        EndFindKvp(kvpHandle)
    end
end

function getvMenuPeds()
    return Peds
end

function getvMenuPedNames()
    return PedNames
end

function hasvMenuPeds()
    return #Peds > 0
end

function setvMenuPed(ped)
    local tattoos = {}
    if ped ~= 0 and ped ~= nil and Peds[ped] ~= nil then
        local prefix = Peds[ped]
        local appData = prefix.PedAppearance
        local data = prefix.PedHeadBlendData

        if IsModelInCdimage(prefix.ModelHash) then
            if not HasModelLoaded(prefix.ModelHash) then
                RequestModel(prefix.ModelHash)
                while not HasModelLoaded(prefix.ModelHash) do
                    Wait(100)
                end
            end

            maxHealth = GetEntityMaxHealth(PlayerPedId())
            maxArmour = GetPlayerMaxArmour(PlayerId())
            health = GetEntityHealth(PlayerPedId())
            armour = GetPedArmour(PlayerPedId())

            SetPlayerModel(PlayerId(), prefix.ModelHash)
            SetPlayerMaxArmour(PlayerId(), maxArmour)
            SetEntityMaxHealth(PlayerPedId(), maxHealth)
            SetEntityHealth(PlayerPedId(), health)
            SetPedArmour(PlayerPedId(), armour)

            ClearPedDecorations(PlayerPedId())
            ClearPedFacialDecorations(PlayerPedId())
            SetPedDefaultComponentVariation(PlayerPedId())
            SetPedHairColor(PlayerPedId(), 0, 0)
            SetPedEyeColor(PlayerPedId(), 0)
            ClearAllPedProps(PlayerPedId())

            SetPedHeadBlendData(PlayerPedId(), data.FirstFaceShape, data.SecondFaceShape, data.ThirdFaceShape, data.FirstSkinTone, data.SecondSkinTone, data.ThirdSkinTone, data.ParentFaceShapePercent, data.ParentSkinTonePercent, 0, data.IsParentInheritance)
            SetPedComponentVariation(PlayerPedId(), 2, appData.hairStyle, 0, 0)
            SetPedHairColor(PlayerPedId(), appData.hairColor, appData.hairHighlightColor)

            if appData.HairOverlay ~= nil and appData.HairOverlay.value ~= nil then
                SetPedFacialDecoration(PlayerPedId(), GetHashKey(appData.HairOverlay.Key), GetHashKey(appData.HairOverlay.Value))
            end

            -- blemishes
            SetPedHeadOverlay(PlayerPedId(), 0, appData.blemishesStyle, appData.blemishesOpacity)
            -- bread
            SetPedHeadOverlay(PlayerPedId(), 1, appData.beardStyle, appData.beardOpacity)
            SetPedHeadOverlayColor(PlayerPedId(), 1, 1, appData.beardColor, appData.beardColor)
            -- eyebrows
            SetPedHeadOverlay(PlayerPedId(), 2, appData.eyebrowsStyle, appData.eyebrowsOpacity)
            SetPedHeadOverlayColor(PlayerPedId(), 2, 1, appData.eyebrowsColor, appData.eyebrowsColor)
            -- ageing
            SetPedHeadOverlay(PlayerPedId(), 3, appData.ageingStyle, appData.ageingOpacity)
            -- makeup
            SetPedHeadOverlay(PlayerPedId(), 4, appData.makeupStyle, appData.makeupOpacity)
            SetPedHeadOverlayColor(PlayerPedId(), 4, 2, appData.makeupColor, appData.makeupColor)
            -- blush
            SetPedHeadOverlay(PlayerPedId(), 5, appData.blushStyle, appData.blushOpacity)
            SetPedHeadOverlayColor(PlayerPedId(), 5, 2, appData.blushColor, appData.blushColor)
            --complexion
            SetPedHeadOverlay(PlayerPedId(), 6, appData.complexionStyle, appData.complexionOpacity)
            -- sundamage
            SetPedHeadOverlay(PlayerPedId(), 7, appData.sunDamageStyle, appData.sunDamageOpacity)
            -- lipstick
            SetPedHeadOverlay(PlayerPedId(), 8, appData.lipstickStyle, appData.lipstickOpacity)
            SetPedHeadOverlayColor(PlayerPedId(), 8, 2, appData.lipstickColor, appData.lipstickColor)
            -- moles and freckles
            SetPedHeadOverlay(PlayerPedId(), 9, appData.molesFrecklesStyle, appData.molesFrecklesOpacity)
            --chest hair
            SetPedHeadOverlay(PlayerPedId(), 10, appData.chestHairStyle, appData.chestHairOpacity)
            SetPedHeadOverlayColor(PlayerPedId(), 10, 1, appData.chestHairColor, appData.chestHairColor)
            --body blemishes
            SetPedHeadOverlay(PlayerPedId(), 11, appData.bodyBlemishesStyle, appData.bodyBlemishesOpacity)
            --eyecolor
            SetPedEyeColor(PlayerPedId(), appData.eyeColor)

            for i = 1, 19 do
                SetPedFaceFeature(PlayerPedId(), i, 0)
            end

            if (prefix.FaceShapeFeatures.features ~= nil) then
                for key, v in each(prefix.FaceShapeFeatures.features) do
                    SetPedFaceFeature(PlayerPedId(), tonumber(key), v)
                end
            end

            if (prefix.DrawableVariations.clothes ~= nil) then
                for key, cd in each(prefix.DrawableVariations.clothes) do
                    SetPedComponentVariation(PlayerPedId(), tonumber(key), cd.Key, cd.Value, 0)
                end
            end

            if (prefix.PropVariations.props ~= nil) then
                for key, cd in each(prefix.PropVariations.props) do
                    if (cd.Key > -1) then
                        SetPedPropIndex(PlayerPedId(), tonumber(key), cd.Key, cd.Value > -1 or 0, true)
                    end
                end
            end

            if (prefix.PedTatttoos ~= nil) then
                if (prefix.PedTatttoos.HeadTattoos ~= nil) then
                    for _, tattoo in each(prefix.PedTatttoos.HeadTattoos) do
                        table.insert(tattoos, { collection = string.lower(tattoo.Key), name = tattoo.Value, id = string.lower(tattoo.Key) .. "-" .. tattoo.Value })
                    end
                end
                if (prefix.PedTatttoos.TorsoTattoos ~= nil) then
                    for _, tattoo in each(prefix.PedTatttoos.TorsoTattoos) do
                        table.insert(tattoos, { collection = string.lower(tattoo.Key), name = tattoo.Value, id = string.lower(tattoo.Key) .. "-" .. tattoo.Value })
                    end
                end
                if (prefix.PedTatttoos.LeftArmTattoos ~= nil) then
                    for _, tattoo in each(prefix.PedTatttoos.LeftArmTattoos) do
                        table.insert(tattoos, { collection = string.lower(tattoo.Key), name = tattoo.Value, id = string.lower(tattoo.Key) .. "-" .. tattoo.Value })
                    end
                end
                if (prefix.PedTatttoos.RightArmTattoos ~= nil) then
                    for _, tattoo in each(prefix.PedTatttoos.RightArmTattoos) do
                        table.insert(tattoos, { collection = string.lower(tattoo.Key), name = tattoo.Value, id = string.lower(tattoo.Key) .. "-" .. tattoo.Value })
                    end
                end
                if (prefix.PedTatttoos.LeftLegTattoos ~= nil) then
                    for _, tattoo in each(prefix.PedTatttoos.LeftLegTattoos) do
                        table.insert(tattoos, { collection = string.lower(tattoo.Key), name = tattoo.Value, id = string.lower(tattoo.Key) .. "-" .. tattoo.Value })
                    end
                end
                if (prefix.PedTatttoos.RightLegTattoos ~= nil) then
                    for _, tattoo in each(prefix.PedTatttoos.RightLegTattoos) do
                        table.insert(tattoos, { collection = string.lower(tattoo.Key), name = tattoo.Value, id = string.lower(tattoo.Key) .. "-" .. tattoo.Value })
                    end
                end
                if (prefix.PedTatttoos.BadgeTattoos ~= nil) then
                    for _, tattoo in each(prefix.PedTatttoos.BadgeTattoos) do
                        table.insert(tattoos, { collection = string.lower(tattoo.Key), name = tattoo.Value, id = string.lower(tattoo.Key) .. "-" .. tattoo.Value })
                    end
                end
            end
            SetFacialIdleAnimOverride(PlayerPedId(), prefix.FacialExpression or 0, nil)
        end
    end

    return tattoos
end