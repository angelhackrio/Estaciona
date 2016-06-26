local topbar = {}

local newTopMain = function(parent, options)
	
	local isNewScreen = options and options.isNewScreen

	local group = display.newGroup( )

	local rbw = require "rb-widget"

	local backgroundH = (114/1024)*SCREEN_W
	local background = display.newRect( group, CENTER_X, _G.TOP_Y_AFTER_STATUS_BAR + backgroundH*.5, SCREEN_W, backgroundH )
	background.fill = colorGray
	--background.fill = {type="image", filename="images/bkg-top.png"}
	background:addEventListener("tap", function() return true end)
	background:addEventListener("touch", function() return true end)

	local btMyLocationH = backgroundH*.4
	local btMyLocation = rbw.newButton{
	    y=background.y,
	    width=32, --14*_G.GROW_WITH_SCREEN_W,
	    height=backgroundH,
	    left=0,
	    imageFile="images/icon_mylocation.png",
	    imageWidth=139/133 * btMyLocationH,
	    imageHeight=btMyLocationH,
	    imageColor = {1,1,1},
	    imageOverColor = {1,1,1,.5},
	    imagePadding = {left = 10},
	    
	    onRelease = function()	    	
	    	group.onMyLocationHandler()

	    end
	}
	group:insert(btMyLocation)
	if isNewScreen then
		btMyLocation.isVisible = false
	end
	

	local logo = display.newImage(group, "images/logo_top.png")
	local scaleF = 0.8*backgroundH/logo.contentHeight
	logo:scale(scaleF, scaleF)
	logo.x, logo.y = background.x, background.y

	
	local iconMenuH = backgroundH*0.4
	local menu
	local btNew = rbw.newButton{
	    y=background.y,
	    width=32, --14*_G.GROW_WITH_SCREEN_W,
	    height=backgroundH,
	    right=SCREEN_W,
	    imageFile="images/icon-plus.png",
	    imageWidth=iconMenuH, --7*_G.GROW_WITH_SCREEN_W,
	    imageHeight=iconMenuH, --7*_G.GROW_WITH_SCREEN_W,                       
	    imageColor = {1,1,1},
	    imageOverColor = {1,1,1,.5},
	    imagePadding = {left = 10},
	    
	    onRelease = function()
	   	print("new!!")
	    	require("composer").gotoScene( "scene-new", {time=400, effect="slideUp"} )

	    end
	}
	group:insert(btNew)


	local btClose = rbw.newButton{
	    y=background.y,
	    width=32, --14*_G.GROW_WITH_SCREEN_W,
	    height=backgroundH,
	    right=SCREEN_W,
	    -- imageFile="images/icon-plus.png",
	    -- imageWidth=iconMenuH, --7*_G.GROW_WITH_SCREEN_W,
	    -- imageHeight=iconMenuH, --7*_G.GROW_WITH_SCREEN_W,                       
	    -- imageColor = {1,1,1},
	    -- imageOverColor = {1,1,1,.5},
	    -- imagePadding = {left = 10},
	    label = "X",
	    labelColor = {0,0,0},
	    labelFontSize=18,
	    labelAlign="center",
	    
	    onRelease = function()
	   	
	    	--require("composer").hideOverlay()
	    	_G.BACK.goBack()

	    end
	}
	group:insert(btClose)


	if isNewScreen then
		btNew.isVisible = false
		btClose.isVisible = true
	else
		btNew.isVisible = true
		btClose.isVisible = false
	end


	group.getBottom = function()
		return group.contentBounds.yMax
	end
	if parent then
		parent:insert(group)
	end



	return group

end


topbar.new = function(parent, options)

	local sceneName = require("composer").getSceneName("current")

	if sceneName == "scene-main" then
		return newTopMain(parent,options)
	else
		return newTopMain(parent,{isNewScreen=true})
	end

end


return topbar