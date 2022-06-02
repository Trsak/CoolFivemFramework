function getNearestPostal(coords)
    local nearestPostal

    for _, postal in each(Config.Postals) do
        local distance = #(coords - vec3(postal.Coords.xy, coords.z))
        if not nearestPostal or distance < nearestPostal.Distance then
            nearestPostal = {
                data = postal,
                Distance = distance
            }
        end
    end

    return nearestPostal.data
end
