local sampev = require("samp.events")

-- Variabel Utama
local isFastWalkEnabled = false
local fastWalkMultiplier = 5.9 -- Kecepatan default

-- Daftar Animasi
local anim_list = {
	"WALK_PLAYER", "GUNCROUCHFWD", "GUNCROUCHBWD", "GUNMOVE_BWD", "GUNMOVE_FWD", 
	"GUNMOVE_L", "GUNMOVE_R", "RUN_GANG1", "JOG_FEMALEA", "JOG_MALEA", "RUN_CIVI", 
	"RUN_CSAW", "RUN_FAT", "RUN_FATOLD", "RUN_OLD", "RUN_ROCKET", "RUN_WUZI", 
	"SPRINT_WUZI", "WALK_ARMED", "WALK_CIVI", "WALK_CSAW", "WALK_DRUNK", "WALK_FAT", 
	"WALK_FATOLD", "WALK_GANG1", "WALK_GANG2", "WALK_OLD", "WALK_SHUFFLE", 
	"WALK_START", "WALK_START_ARMED", "WALK_START_CSAW", "WALK_START_ROCKET", 
	"WALK_WUZI", "WOMAN_WALKBUSY", "WOMAN_WALKFATOLD", "WOMAN_WALKNORM", 
	"WOMAN_WALKOLD", "WOMAN_RUNFATOLD", "WOMAN_WALKPRO", "WOMAN_WALKSEXY", 
	"WOMAN_WALKSHOP", "RUN_1ARMED", "RUN_ARMED", "RUN_PLAYER", "WALK_ROCKET", 
	"CLIMB_IDLE", "MUSCLESPRINT", "CLIMB_PULL", "CLIMB_STAND", "CLIMB_STAND_FINISH", 
	"SWIM_BREAST", "SWIM_CRAWL", "SWIM_DIVE_UNDER", "SWIM_GLIDE", "MUSCLERUN", 
	"WOMAN_RUN", "WOMAN_RUNBUSY", "WOMAN_RUNPANIC", "WOMAN_RUNSEXY", "SPRINT_CIVI", 
	"SPRINT_PANIC", "SWAT_RUN", "FATSPRINT", "JUMP_LAUNCH", "JUMP_GLIDE", "JUMP_LAND"
}

function main()
    while not isSampAvailable() do 
        wait(100) 
    end
    
    sampAddChatMessage("{61B1F9}[FastWalk]{FFFFFF} Loaded! Ketik /fw untuk aktif/nonaktif.", -1)
    
    -- Registrasi Command /fw
    sampRegisterChatCommand("fw", function(param)
        if param ~= "" and tonumber(param) then
            fastWalkMultiplier = tonumber(param)
            sampAddChatMessage("{61B1F9}[FastWalk]{FFFFFF} Kecepatan diatur ke: " .. fastWalkMultiplier, -1)
        else
            isFastWalkEnabled = not isFastWalkEnabled
            if isFastWalkEnabled then
                sampAddChatMessage("{61B1F9}[FastWalk]{FFFFFF} Status: {00FF00}AKTIF", -1)
            else
                sampAddChatMessage("{61B1F9}[FastWalk]{FFFFFF} Status: {FF0000}NONAKTIF", -1)
                
                -- PERBAIKAN: Gunakan false, bukan 0
                if PLAYER_HANDLE then setPlayerNeverGetsTired(PLAYER_HANDLE, false) end
                
                if PLAYER_PED then
                    for _, animName in pairs(anim_list) do
                        setCharAnimSpeed(PLAYER_PED, animName, 1.0)
                    end
                end
            end
        end
    end)

    -- Loop Utama Pergerakan
    while true do
        wait(0)
        if isFastWalkEnabled then
            if PLAYER_HANDLE and PLAYER_PED then
                -- PERBAIKAN: Gunakan true, bukan 1
                setPlayerNeverGetsTired(PLAYER_HANDLE, true)
                
                for _, animName in pairs(anim_list) do
                    setCharAnimSpeed(PLAYER_PED, animName, fastWalkMultiplier)
                end
            end
        end
    end
end

-- Logika Spoofing Vektor (Bypass Anti-Cheat Server)
function sampev.onSendPlayerSync(data)
    if isFastWalkEnabled then
        data.moveSpeed = {0.129999, 0.129999, -0.0}
    end
end
