script_author('jeffrY.')
script_name('STools')

require "lib.moonloader"
local fa = require 'icons'
local memory = require "memory"
local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local fa_font = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })

local main_ws = imgui.ImBool(false)
local first_ws = imgui.ImBool(false)
local playersInZone = imgui.ImBool(false)

local sw, sh = getScreenResolution()

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(2500) end

	while true do
    	wait(0)
        imgui.Process = sampIsLocalPlayerSpawned()
        result, id_p = sampGetPlayerIdByCharHandle(PLAYER_PED)
        nickName = sampGetPlayerNickname(id_p)
		playerZS = sampGetPlayerCount(false)
    end
end

function imgui.BeforeDrawFrame()
    if fa_font == nil then
        local font_config = imgui.ImFontConfig() -- to use 'imgui.ImFontConfig.new()' on error
        font_config.MergeMode = true

        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 13.0, font_config, fa_glyph_ranges)
    end
end

function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
	style.ButtonTextAlign = imgui.ImVec2(1, 0.5)

    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00) -- textu
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0)  -- aici se afla culoarea la aia
end

apply_custom_style()

function imgui.OnDrawFrame()
    if main_ws then
        imgui.ShowCursor = false
        imgui.Begin(u8'ss', main_ws, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize)
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1.00, 1.00, 1.00, 0))
		imgui.Button(os.date('%d %b %Y %H:%M', os.time()),imgui.ImVec2(200, 18))
		imgui.PopStyleColor(1)
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1.00, 1.00, 1.00, 0))
        imgui.Button(playerZS..' online '..fa.ICON_FA_USER..u8' '..nickName..'\n',imgui.ImVec2(200, 18))
		imgui.PopStyleColor(1)
        local wndsz = imgui.GetWindowSize()
        local sw, sh = getScreenResolution()
        imgui.SetWindowPos(imgui.ImVec2(sw / 1.1 - wndsz.x / 1.4, sh / 8.05 - wndsz.y - sh * 0.01))
        imgui.End()
    end
end