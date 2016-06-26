local composer = require( "composer" )

local scene = composer.newScene()


local map = nil
local groupList = nil

local refreshParkings = nil

function scene:create( event )

    local sceneGroup = self.view 

    local background = display.newRect(sceneGroup, CENTER_X, CENTER_Y, SCREEN_W, SCREEN_H)
    background.fill = {1,1,1}

    local topbar = require("module-topbar").new(sceneGroup)
    sceneGroup.topbar = topBar

    ------------------------
    -- LIST

    groupList = display.newGroup( )

    
    local getTimeRemaining = function(dateStartUTC, hourZone)
        --print("dateStartUTC=", dateStartUTC)
        dateStartUTC = AUX.getDateUTC(dateStartUTC) --"2016-06-26T09:14:01"
        --pt(dateStartUTC, "dateStartUTC=")
        local datetimeNow = AUX.getDateUTC()      
        --pt(datetimeNow, "datetimeNow=")
        --print("hourZone=", hourZone)
        local datetimeEndInSec =  os.time(dateStartUTC) + hourZone*60*60     
        local datetimeNowInSec =  os.time(datetimeNow)
        local timeElapsedInSec = datetimeNowInSec - os.time(dateStartUTC)
        local timeRemainingInSec = datetimeEndInSec - datetimeNowInSec
        --print("timeElapsedInSec=", timeElapsedInSec)
        --print("timeRemainingInSec=", timeRemainingInSec)
        --local difInMinutes = math.floor( (- os.time(datetimeNow))/60
        local difInMinutes = timeRemainingInSec / 60
        local difHours = math.floor(difInMinutes/60)
        local difMinutes = difInMinutes - difHours*60
        --print("difHours=", difHours, "difMinutes=", difMinutes)
        return {hours=difHours, minutes=difMinutes}
    end


    local createRow = function(obj)
        
        local group = display.newGroup( )

        local backgroundH = 80
        local background = display.newRect( group, CENTER_X, backgroundH*.5, SCREEN_W, 80 )
        background.fill = {1,1,1}

        local car = display.newImage(group, "images/icon_car2.png")
        local scaleF = backgroundH*.6 / car.contentHeight
        car:scale(scaleF, scaleF)
        car.x = SCREEN_W*.12   
        car.y = background.y




        local label = display.newText{parent=group, text= ":" , x=SCREEN_W*.34, y=background.y, fontSize=36, font=native.systemFont}
        label:setTextColor(0,0,0)

        local updateTimeRemaining = function()

            local remainingTime = getTimeRemaining(obj.DateTimeStart, obj.hourZone)
            if label then
                if remainingTime.hours < 0 then remainingTime.hours = 0 end
                if remainingTime.minutes < 0 then remainingTime.minutes = 0 end
                label.text =  string.format("%1d", remainingTime.hours) .. ":" .. string.format("%02d", remainingTime.minutes)
            else
                timer.cancel( timerID )
            end

        end
        updateTimeRemaining()
        local timerID = timer.performWithDelay( 500, function()
                updateTimeRemaining()
        end)

        local labelStreet = display.newText{parent=group, text=obj.streetName, x=SCREEN_W*.5, y=backgroundH*.3, fontSize=14, font=native.systemFont, width=SCREEN_W*.39}
        labelStreet:setTextColor(0.3,0.3,0.3)
        labelStreet.anchorX = 0
        labelStreet.anchorY = 0

        local rbw = require "rb-widget"
        local imageH = 87*.3
        local btExtend = rbw.newButton{
            right = SCREEN_W,
            y = background.y,
            width = backgroundH*.5,
            height = backgroundH,
            backgroundColor = {1,0,1,0},
            imageFile="images/bt_extend.png",
            imageColor = {1,1,1},
            imageOverColor={1,1,1,.5},
            imageWidth = imageH,
            imageHeight = imageH,
            imagePadding={left=imageH*.25},
            onRelease = function()

                timer.performWithDelay( 3000, showMap)
                AUX.showAlert("Confirma a extensão de seu estacionamento?", {
                    {label="Sim", handler=function()

                        native.setActivityIndicator( true )
                        SERVER.extendParking(obj.id, function()
                            native.setActivityIndicator( false )
                                refreshParkings()
                            end,
                            function()
                            
                            native.setActivityIndicator( false )
                            
                            end)


                        end},
                    {label="Não", }
                    })
            end
        }
        group:insert(btExtend)

        -- Sometime later (following activation of device location hardware)
        local options = 
        { 
            --title = "Displayed Title", 
            --subtitle = "Subtitle text", 
            --listener = markerListener,
            -- This will look in the resources directory for the image file
            imageFile =  "pin.png",
            -- Alternatively, this looks in the specified directory for the image file
            -- imageFile = { filename="someImage.png", baseDir=system.TemporaryDirectory }
        }
        local result, errorMessage = map:addMarker( obj.lat, obj.long, options )
        if ( result ) then
                    print( "Marker added" )
                else
                    print( errorMessage )
        end

        return group
    end


    ------------------------
    -- MAP

    local function createMap()
        local mapH = SCREEN_H - topbar.getBottom() - groupList.contentHeight

        map = native.newMapView( CENTER_X, topbar.getBottom(), SCREEN_W , mapH ) -- make it square
        map._height = mapH
        map.anchorY = 0

        sceneGroup:insert(map)

        map.mapType = "standard" -- other mapType options are "satellite" or "hybrid"
    end
    createMap()
    local showMap = function()
        --transition.to(map,{height=map._height, time=2000, transition=easing.outInExpo})
        transition.to(map,{height=map._height, time=2000})
    end

    local hideMap = function()
        transition.to(map,{height=0, time=2000, transition=easing.inOutExpo})
        
    end

    local updateMapHeight = function()
        local mapH = SCREEN_H - topbar.getBottom() - groupList.contentHeight
        map.height = mapH
        --transition.to(map,{height=mapH, time=2000, transition=easing.inOutExpo})        
    end

    local onMyLocationHandler = function()
        local attempts = 0
        local function locationHandler( event )

            local currentLocation = map:getUserLocation()

            if ( currentLocation.errorCode or ( currentLocation.latitude == 0 and currentLocation.longitude == 0 ) ) then
                --locationText.text = currentLocation.errorMessage

                attempts = attempts + 1

                if ( attempts > 10 ) then
                    native.showAlert( "No GPS Signal", "Can't sync with GPS.", { "Okay" } )
                else
                    timer.performWithDelay( 1000, locationHandler )
                end
            else
               -- locationText.text = "Current location: " .. currentLocation.latitude .. "," .. currentLocation.longitude
                map:setCenter( currentLocation.latitude, currentLocation.longitude )
                _G.USER.lat, _G.USER.long = currentLocation.latitude, currentLocation.longitude
                print("_G.USER.lat, _G.USER.long=", _G.USER.lat, _G.USER.long)
                --myMap:addMarker( currentLocation.latitude, currentLocation.longitude )
            end
        end

        locationHandler()
    end
    topbar.onMyLocationHandler = onMyLocationHandler
    sceneGroup.onMyLocationHandler = onMyLocationHandler


    refreshParkings = function()
        display.remove(groupList)
        groupList = nil

        local onSuccess = function(data)

            groupList = display.newGroup( )
            sceneGroup:insert(groupList)

            pt(data,"data=")
            for k, v in ipairs(data) do                
                local r = createRow(v)
                r.x = CENTER_X - r.contentWidth*.5
                r.y = groupList.numChildren == 0 and 0 or groupList.contentHeight
                groupList:insert(r)                
            end
            
            groupList.y = SCREEN_H - groupList.contentHeight

            updateMapHeight()
        end

        local onFail = function()
        end

        SERVER.getParkings(onSuccess, onFail)

    end

    refreshParkings()

end


function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

        sceneGroup.onMyLocationHandler()
        
    elseif ( phase == "did" ) then

        _G.BACK.addBack()

    end
end



function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
        
    end
end



function scene:destroy( event )

    local sceneGroup = self.view

end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene