RegisterNetEvent("job_default:addLicense")
AddEventHandler(
    "job_default:addLicense",
    function(target, licenseId)
        local _source = source
        local hasAccess = false

        for job, data in pairs(Config.Jobs) do
            if data.Places and data.Places.Licenses then
                if exports.base_jobs:hasUserJob(_source, job, data.Places.Licenses.Grade) then
                    hasAccess = true
                    break
                end
            end
        end

        if hasAccess then
            local charId = exports.data:getCharVar(target, "id")
            exports.license:addLicenseToChar(
                {
                    char = exports.data:getCharVar(target, "id"),
                    test = licenseId,
                    source = target,
                    license = {
                        status = "done",
                        blocked = 0
                    }
                }
            )
        end
    end
)
