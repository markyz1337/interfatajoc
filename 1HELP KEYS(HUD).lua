script_name('ChangeLogos')
script_author('Dean')
--~ =========================================================[LIBS]=========================================================
local res                   = pcall(require, 'lib.moonloader')                      assert(res, 'Lib MOONLOADER not found!')
local res                   = pcall(require, 'lib.sampfuncs')                       assert(res, 'Lib SAMPFUNCS not found')
local res, hook             = pcall(require, 'lib.samp.events')                     assert(res, 'Lib SAMP EVENTS not found')
--~ =========================================================[VARS]=========================================================
local logoTextures = {"1", "2", "3", "4", "5", "6"}
local textureList = nil 

local ips = {
    nephrite = "193.203.39.36",     -- 1
}
local currentServer = nil
local connected = false
local changePos = false
local changeSize = false

local tdIDs = {2113, 2082, 2083, 29, 28, 2069, 2070} -- add 47, 48 ,49 etc

local settings = {
    pos = {},
    intLogo = 1,
    size = {}
}

for i = 1, 6 do 
    settings.pos[i] = {x = 590*2.1, y = 20*1.5}
    settings.size[i] = {x = 77, y = 42}
end
local jsonFile = getGameDirectory().."\\moonloader\\resource\\HELP KEYS(HUD).json"
if not doesFileExist(jsonFile) then
    local f = io.open(jsonFile, "w")
    f:write(encodeJson(settings))
    f:close()
end
--~ =========================================================[MAIN]=========================================================
function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then error(script_name..' needs SA:MP and SAMPFUNCS!') end
    while not isSampAvailable() do wait(100) end
    while sampGetCurrentServerName() == 'SA-MP' do wait(0) end
    while not sampIsLocalPlayerSpawned() do wait(0) end
    ----------------------------------------------------------------
    if not sampGetCurrentServerName():find("nephrite") then
        thisScript():unload()
        return
    end
    ----------------------------------------------------------------
    local server, _ = sampGetCurrentServerAddress()
    for k, v in pairs(ips) do
        if v == server then 
            currentServer = k
            break
        end
    end
    if not currentServer then print("Error Server...") return end
    ----------------------------------------------------------------
    loadJson()
    ----------------------------------------------------------------
    sampRegisterChatCommand('logohelpkeyspos', function()
        changePos = true
        chatmsg("Click the right mouse button to save the position")
    end)
    sampRegisterChatCommand('logohelpkeys', function(param)
        local int = tonumber(param)
        if int then
            if int >= 1 and int <= 6 then
                settings.intLogo = int
                saveJson() 
            else
                chatmsg("Use: /logohelpkeys [1-6]")
                return
            end
        else
            chatmsg("Use: /logohelpkeys [1-6]")
            return
        end
    end)
    sampRegisterChatCommand('logohelpkeyssize', function()
        changeSize = true
        lockPlayerControl(true)
        chatmsg("The logo size editing mode has been enabled.")
        chatmsg("Use the arrow keys on your keyboard to resize.")
        chatmsg("Click the right mouse button to apply the changes")
    end)
    sampRegisterChatCommand('logohelpkeysreset', function() 
        settings = {
            pos = {},
            intLogo = 1,
            size = {}
        }
        for i = 1, 6 do 
            settings.pos[i] = {x = 590*2.1, y = 20*1.5}
            settings.size[i] = {x = 77, y = 42}
        end
        chatmsg("Settings have been reset.")
        saveJson()
    end)
    ----------------------------------------------------------------
    if not loadLogoTextures(currentServer) then print("Error load textures") return end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    while true do
        wait(0)
        for k, v in ipairs(tdIDs) do
            if sampTextdrawIsExists(v) then
                sampTextdrawDelete(v)
            end 
        end
        if changePos then
            settings.pos[settings.intLogo].x, settings.pos[settings.intLogo].y = getCursorPos()
            sampToggleCursor(true) 
            if isKeyJustPressed(0x02) then
                changePos = false
                sampToggleCursor(false)
                chatmsg("Settings have been saved!")   
                saveJson()
            end
        end

        if changeSize then
            if isKeyDown(0x26) then settings.size[settings.intLogo].y = settings.size[settings.intLogo].y + 1 end
            if isKeyDown(0x28) then settings.size[settings.intLogo].y = settings.size[settings.intLogo].y - 1 end
            if isKeyDown(0x25) then settings.size[settings.intLogo].x = settings.size[settings.intLogo].x - 1 end
			if isKeyDown(0x27) then settings.size[settings.intLogo].x = settings.size[settings.intLogo].x + 1 end

            if isKeyJustPressed(0x02) then
                changeSize = false
                lockPlayerControl(false)
                chatmsg("Settings have been saved.")
                saveJson()
            end
        end
        drawTexture(textureList[settings.intLogo], settings.pos[settings.intLogo].x/2.1, settings.pos[settings.intLogo].y/1.5, settings.size[settings.intLogo].x, settings.size[settings.intLogo].y)
    end
end
--~ =========================================================[FUNC]=========================================================
function chatmsg(text)
    sampAddChatMessage(string.format("[ChangeLogos]: {FFFFFF}%s", text), 0xA77BCA)
end

--* Texture funcs
function loadLogoTextures(file) 
    if textureList == nil then
        textureList = loadTextures(file, logoTextures)
        if textureList == nil then print("Error load txd for", currentServer) return false end
    end
    return true
end
function loadTextures(txd, names)
    if not loadTextureDictionary(txd) then
        return nil
    end

    local textures = {}
    for _, name in ipairs(names) do
        local id = loadSprite(name)
        table.insert(textures, id)
    end
    return textures
end
function drawTexture(id, x, y, sizex, sizey)
	if not sampTextdrawIsExists(135, 136) then
    setSpritesDrawBeforeFade(true)
    drawSprite(id, x, y, sizex, sizey, 255, 255, 255, 255)
end
end

--* Save&Load funcs
function saveJson()
    local f = io.open(jsonFile, "w")
    f:write(encodeJson(settings))
    f:close()
end
function loadJson()
    local f = io.open(jsonFile)
    settings = decodeJson(f:read("*a"))
    f:close()
end

--* Events
function hook.onSendClientJoin(version, mod, nickname, challengeResponse, joinAuthKey, clientVer, challengeResponse2)
    if connected then
        thisScript():reload()
    else
        connected = true
    end
end