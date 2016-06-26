local launchArgs = ...
local launchURL
if launchArgs and launchArgs.url then
    launchURL = launchArgs.url
end
print( "launchURL=", launchURL ) -- output: coronasdkapp://mycustomstring



pt = function(table, label)
    label = label or ""
    print(" = = begin debug table = = =")
    print(label .. "" .. require("json").encode(table))
    print(" = = end debug table = = =")
end



-- loads app background
-- local background = display.newImageRect("images/background.png", display.contentWidth, display.contentHeight)
-- background.x = background.contentWidth*0.5
-- background.y = background.contentHeight*0.5
-- _G.BACKGROUND = background

--display.setStatusBar( display.HiddenStatusBar )
display.setStatusBar( display.DarkStatusBar )

colorGray = {237/255,240/255,245/255}

-- creates the statusBar background
local statusBarH = display.topStatusBarContentHeight + 2
_G.statusBarBackground = display.newRect(display.contentWidth*0.5,statusBarH*0.5,display.contentWidth,statusBarH)
_G.TOP_Y_AFTER_STATUS_BAR = _G.statusBarBackground.contentHeight
_G.statusBarBackground.fill = colorGray
_G.statusBarBackground._fill = _G.statusBarBackground.fill


-- _G.statusBarBackground.isVisible = false

_G.AUX = require("rb-aux")

-- _G.DM = require("lib-dataManager")

-- _G.USER = require("class-user")
-- require "rb-string"
-- require "transition_color"  -- used to add the function .fromtocolor to transition API (used on custom on-off switch)
_G.BACK = require "rb-back"
_G.DEVICE = require("rb-device")

_G.CENTER_X = display.contentCenterX
_G.CENTER_Y = display.contentCenterY
_G.SCREEN_W = display.contentWidth
_G.SCREEN_H = display.contentHeight


_G.GROW_WITH_SCREEN_W = (SCREEN_W / 320) 
_G.GROW_WITH_SCREEN_H = (SCREEN_H / 568) 


_G.SERVER = require "server"

_G.USER = {id="renato", lat="-22.9503808", long="-43.1781679"}

local composer = require "composer"


composer.gotoScene("scene-main")
--composer.gotoScene("scene-new")
