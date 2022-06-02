fx_version "cerulean"
game "gta5"

lua54 "yes"

export "forceBonus"
export "hasUserJobType"
export "hasUserJob"
-- From Data
export "getJobs"
export "getJob"
export "checkJobs"
export "getJobVar"
export "getJobGradeVar"

server_export "updateDuty"
server_export "hasUserJobType"
server_export "hasUserJobTypeGrade"
server_export "hasUserJobEqualGrade"
server_export "hasUserJob"
server_export "isUserBoss"
server_export "getHighestJobRank"
server_export "getHighestJobTypeRank"
server_export "getUserActiveJob"
-- From Data
server_export "updateJobVar"
server_export "getJobs"
server_export "getJob"
server_export "getJobVar"
server_export "getJobGradeVar"
server_export "getJobsTypes"

client_scripts {
	"config.lua",
	"client/main.lua"
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"config.lua",
	"server/main.lua"
}
