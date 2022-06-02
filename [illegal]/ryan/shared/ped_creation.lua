function applyPedConfig(ryanPed)
    FreezeEntityPosition(ryanPed, true)
    SetPedComponentVariation(ryanPed, 2, Config.Ryan.Hair.style, Config.Ryan.Hair.texture, 0)
    SetPedHairColor(ryanPed, Config.Ryan.Hair.color, Config.Ryan.Hair.highlight)

    for _, componentData in each(Config.Ryan.Components) do
        SetPedComponentVariation(ryanPed, componentData.componentId, componentData.drawable, componentData.texture, 0)
    end

    for _, propData in each(Config.Ryan.Props) do
        SetPedPropIndex(ryanPed, propData.propId, propData.drawable, propData.texture, false)
    end

    for index, faceFeature in each(Config.FaceFeatures) do
        SetPedFaceFeature(ryanPed, index - 1, Config.Ryan.FaceFeatures[faceFeature])
    end

    SetPedHeadBlendData(
        ryanPed,
        Config.Ryan.HeadBlend.shapeFirst,
        Config.Ryan.HeadBlend.shapeSecond,
        0,
        Config.Ryan.HeadBlend.skinFirst,
        Config.Ryan.HeadBlend.skinSecond,
        0,
        Config.Ryan.HeadBlend.shapeMix,
        Config.Ryan.HeadBlend.skinMix,
        0,
        false
    )

    SetPedEyeColor(ryanPed, Config.Ryan.EyeColor)

    for index, headOverlay in each(Config.HeadOverlays) do
        local headOverlayData = Config.Ryan.HeadOverlays[headOverlay]
        local colorType = 1

        if headOverlay == "blush" or lipstick == "blush" or makeUp == "blush" then
            colorType = 2
        end

        SetPedHeadOverlay(ryanPed, index - 1, headOverlayData.style, headOverlayData.opacity)
        SetPedHeadOverlayColor(ryanPed, index - 1, colorType, headOverlayData.color, headOverlayData.color)
    end

    SetPedResetFlag(ryanPed, 249, 1)
    SetPedConfigFlag(ryanPed, 185, true)
    SetPedConfigFlag(ryanPed, 108, true)
    SetPedConfigFlag(ryanPed, 208, true)

    if not IsDuplicityVersion() then
        SetEntityCanBeDamaged(ryanPed, false)
        SetPedCanBeTargetted(ryanPed, false)
        SetPedCanBeDraggedOut(ryanPed, false)
        SetPedCanBeTargettedByPlayer(ryanPed, PlayerId(), false)
        SetBlockingOfNonTemporaryEvents(ryanPed, true)
        SetPedCanRagdollFromPlayerImpact(ryanPed, false)
    end
end