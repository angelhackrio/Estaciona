local aux = {}



aux.adjustTextSize = function(textObject, limit)
    local text = textObject.text
    local extraWidth = textObject.width - limit
    local safeGuard = 1  -- variable to safe guard against infinite loop
    if extraWidth > 1  then
        while extraWidth > 1 and safeGuard < 100 do
            local percentReduction = limit / textObject.width
            local totalChars = text:len()
            local charactersToRemove = math.ceil(totalChars * (1-percentReduction) + 3)
            text = text:sub(1,totalChars-charactersToRemove)
            textObject.text = text
            if textObject.width == 0 and text:len() > 0 then -- checking if new width is 0. This may happen if we removed 1 byte of a 2-byte unicode char (like "í"), so in that case, remove 1 byte more
                text = text:sub(1,text:len() - 1)
            end
            text = text .. "..."
            textObject.text = text
            extraWidth = textObject.width - limit
            safeGuard = safeGuard + 1
        end
    end
end


aux.showLoadingAnimation = function(x,y,size)

    local icon = display.newImage("images/icon_loading.png")
    if size then
        icon:scale(size/icon.contentWidth, size/icon.contentHeight)
    end
    icon.x = x
    icon.y = y
    icon:setFillColor( 195/255, 99/255, 70/255)

    transition.to( icon, {time=1300*10000, rotation=360*10000} )

    return icon

end




local function createPopup(width, height)
        
    local popupGroup = display.newGroup()

    local background = display.newRect(display.contentCenterX, display.contentCenterY, SCREEN_W, SCREEN_H)            
    background:setFillColor(0,0,0, 100/255)     
    popupGroup:insert(background)

    -- add event listener to disable touch in the back screen
    background:addEventListener("touch", function() return true end)
    background:addEventListener("tap", function() return true end)

    local popupBackground = display.newRect(0,0,width,height)
    -- popupBackground:setStrokeColor(0,0,0)
    -- popupBackground.strokeWidth =0
    --popupBackground:setFillColor(201/255,162/255,114/255)
    popupBackground.fill = {type="image", filename="images/background.png", baseDir= system.ResourceDirectory}
    popupBackground.anchorX = 0.5
    popupBackground.anchorY = 0.5
    popupBackground.x = display.contentCenterX
    popupBackground.y = display.contentCenterY
    popupGroup:insert(popupBackground)
    popupGroup["background"] = popupBackground

    -- Creates the big title
    local popupTitle = display.newText({text="Title" , x= 10 , y= popupBackground.contentBounds.yMin + 25, width=0.9* SCREEN_W, height = 0,font= myGlobals.fontLabelBold, fontSize=18, align="center"})

    --popupTitle:setTextColor(1,1,1)
    popupTitle:setTextColor(195/255, 99/255, 70/255)
    --popupTitle:setReferencePoint(display.TopCenterReferencePoint)
    popupTitle.anchorX = 0.5
    popupTitle.anchorY = 0
    popupTitle.x = display.contentCenterX
    popupTitle.y = popupBackground.contentBounds.yMin + 10
    popupGroup:insert(popupTitle)
    popupGroup["title"] = popupTitle

    return popupGroup



end
local popup = nil
aux.showProgressPopup = function(onCancel)
            
    local popupProgress = createPopup(160, 144)
    popupProgress.title.text = "Enviando Foto"


    --local groupPopupContent = display.newGroup()
    local widget = require "widget"

    local poupBackground = popupProgress.background
    local spinner = aux.showLoadingAnimation(poupBackground.x, CENTER_Y, 50)
    popupProgress:insert(spinner)


    local function onBtRemoveRelease()

        --print("cancelar")
        timer.performWithDelay( 30, aux.hideProgressPopup)
        
        if onCancel then
            onCancel()
        end
        return true

    end
    local btRemoveY = poupBackground.y + poupBackground.contentHeight*.5 - 20
    local btRemove = require("custom-widget").newRemoveButton("cancelar",poupBackground.x, btRemoveY, 120, 30, onBtRemoveRelease)
    popupProgress:insert(btRemove)
    --btRemove.alpha = 0

    --groupPopupContent:insert(spinner)

        
    -- local progressView = widget.newProgressView{
    --         left = popupProgress.background.x,
    --         top = popupProgress.background.y,
    --         width = 200,                                
    --         isAnimated = true,
    -- }
    -- progressView.anchorX = 0.5
    -- progressView.anchorY = 0.5
    -- progressView.x = popupProgress.background.x
    -- progressView.y = popupProgress.title.contentBounds.yMax  + 0.5*(popupProgress.background.contentBounds.yMax - popupProgress.title.contentBounds.yMax)

    -- popupProgress:insert( progressView ) 
    -- popupProgress["progessView"] = progressView
    
    popup = popupProgress
    return popupProgress
      
end

aux.hideProgressPopup = function()
    display.remove(popup)
    popup = nil

end



aux.showAlert = function(message, buttons)    
    
    if buttons == nil then
        native.showAlert("ESTACIONA", message , {"Ok"})
    else
        local buttonsLabel = {}
        for i=1, #buttons do
            buttonsLabel[#buttonsLabel+1] = buttons[i].label
        end
        native.showAlert("ESTACIONA", message , buttonsLabel, function(event)
            if ( event.action == "clicked" ) then
                local i = event.index
                if buttons[i].handler then
                    buttons[i].handler()
                end
            end
        end )

    end

end


-- function: validates a string based on its chars  -  v2
-- retuns:  bool, errorCode (int)
--
--   1   text is empty
--   2   text not has minimum size
--   3   text has invalid char
--   4   email is in a invalid format


function aux.validateString(text,txtType,minSize, ignoreCharsCheck)
    ----print("running: checkRestrictions for ", text,  " tyoe = ",txtType )
    local charSetList = {
            password = "abcdefghijklmnopqrswtuvxyz0123456789._-@!#$%()*+?",
            username = "abcdefghijklmnopqrswtuvxyz0123456789._-",
            email    = "abcdefghijklmnopqrswtuvxyz0123456789._-@",
            text     = "abcdefghijklmnopqrswtuvxyz 'áéíóúàèìòùãiõñêîôûäëïöü-.",
            firstName     = "abcdefghijklmnopqrswtuvxyz'áéíóúàèìòùãiõñêîôûäëïöüç",
            name     = "abcdefghijklmnopqrswtuvxyz 'áéíóúàèìòùãiõñêîôûäëïöüç-.123456789",
            phone     = "0123456789+ -()",
            birthday     = "0123456789/",
            currency     = "0123456789.,",
    }

    charSetList.nome = charSetList.firstName
    charSetList.sobrenome = charSetList.name
    charSetList["e-mail"] = charSetList.email
    charSetList.senha = charSetList.password

    if text == nil or text == "" then
        return false, 1
    end

    if minSize then
        if not text or text:len() < minSize then
            return false, 2
        end
    end
    
    if ignoreCharsCheck == true then
        return true
    end
    
    local charset = charSetList[txtType or "username"]
    if charset == nil then
        charset = charSetList["username"]
    end
    
    local lowerText = string.lower(text)
    ----print("testing string ",lowerText)
    for i=1, #lowerText do
        local charNow = lowerText:sub(i,i)
        ----print("lookink for",charNow )
        
        if charset:find(charNow) == nil then
      --      --print("found invalid")
            return false, 3
        end
    end
    
    if txtType == "email" or txtType == "e-mail" then
        local textLen = text:len()
        if not text or textLen < 5 then
            return false, 2
        end

        local position
        position = lowerText:find("@",1)
        if not position then -- no "@" found in the string
            return false, 4
        end
        
        local nextChar = lowerText:sub(position+1, position+1)
        --print("nextChar=", nextChar)
        if nextChar == "." then -- "." right after "@" found
            return false, 4
        end

        position = lowerText:find("@",position+1)
        if position then -- Two "@" found in the string
            return false, 4
        end
                
        position = lowerText:find(".",1, true)
        if not position then -- no "." found in the string
            return false, 4
        end
        
        local firstChar = lowerText:sub(1,1)
        if firstChar == "." or firstChar == "@" then  -- starts with "@" or "." 
            return false, 4
        end
        local lastChar = lowerText:sub(textLen,textLen)
        if lastChar == "." or lastChar == "@" then  -- finishes with "@" or "." 
            return false, 4
        end
    end
    
    return true
end



-- creates a transparent rect above a group, making it easy to debug its boundaries
aux.debugGroup = function(groupOj)
    
    local contentBounds = groupOj.contentBounds

    local width = contentBounds.xMax - contentBounds.xMin
    local height = contentBounds.yMax - contentBounds.yMin

    local xCenter = contentBounds.xMin + width*.5
    local yCenter = contentBounds.yMin + height*.5

    local aa = display.newRect(xCenter,yCenter, width, height)
    aa:setFillColor( 1,0,1,.3 )

end


aux.horizontalLine = function(y)
    y = y or CENTER_Y
    local line = display.newLine(0,y, SCREEN_W, y)
    line:setStrokeColor( 1,0,0 )
    line.strokeWidth = 1

end


aux.sortTableBy = function(tableObj, key, subkey)

    local function compare( a, b )
        if subkey then
            return a[key][subkey] < b[key][subkey]  -- true comes first    
        end
        return a[key] < b[key]  -- true comes first
    end

    table.sort( tableObj, compare )

    return tableObj

end

aux.arrayToDic = function(arrayTable, key, subkey)

    local dic = {}
    for k, item in ipairs(arrayTable) do
        if subkey then
            local index = item[key] and item[key][subkey]
            if index == nil then 
                --print("error arrayToDic - item[", key, "]=nil")
            else
                dic[index] = dic[index] or {}
                local currSize = #dic[index]
                dic[tostring(item[key][subkey])][currSize+1] = item    
            end

        else
            local index = item[key]
            dic[index] = dic[index] or {}
            local currSize = #dic[index]
            dic[tostring(item[key])][currSize+1] = item
        end
        
    end

    return dic

end


------------------------------------
-- DATETIME FUNCTIONS

-- retuns the UTC timestamp
aux.getEpocUTC = function()    

    local currTimeUTC = os.date("!%Y-%m-%dT%XZ") -- 2016-01-25T19:14:01Z
    local pattern = "(%d+)%-(%d+)%-(%d+)T(%d+)%:(%d+)%:(%d+)"
    local year, month, day, hour, min, sec = currTimeUTC:match( pattern )
    local dateTable = {year=year, month=month, day=day, hour=hour, min=min, sec=sec}
    local currEpocUTC = os.time(dateTable)

    return currEpocUTC

end

aux.getDateUTC = function(fromDateTimeUTCString)    
    print("fromDateTimeUTCString=", fromDateTimeUTCString)
    local currTimeUTC = fromDateTimeUTCString or os.date("!%Y-%m-%dT%XZ") -- 2016-01-25T19:14:01Z
    local pattern = "(%d+)%-(%d+)%-(%d+)T(%d+)%:(%d+)%:(%d+)"
    local year, month, day, hour, min, sec = currTimeUTC:match( pattern )
    local dateTable = {year=year, month=month, day=day, hour=hour, min=min, sec=sec}

    return dateTable

end

-- returns the number of hours between the date and now
aux.getMinutesDiffFromToday = function(date)
    
    local todayInSec = os.time(aux.getDateUTC())
    local dateInSec = os.time(date)
    pt(date,"=date")
    pt(aux.getDateUTC(),"=todayInSec")

    local diffInMinutes = (todayInSec - dateInSec) / (60*60)
    return diffInMinutes 

end

-- receives a dateString (ISO-8601) and retuns the date as table format. Also returns the UTC timestamp
aux.parseDateTime = function( dateString )

   local pattern = "(%d+)%-(%d+)%-(%d+)%a(%d+)%:(%d+)%:([%d%.]+)([Z%p])(%d?%d?)%:?(%d?%d?)"   
   local year, month, day, hour, minute, seconds, tzoffset, offsethour, offsetmin = dateString:match(pattern)
   local dateTime = { year=year, month=month, day=day, hour=hour, min=minute, sec=seconds }
   local timestamp = os.time(dateTime)
   dateTime = {year=tonumber(year), month=tonumber(month), day=tonumber(day), hour=tonumber(hour), min=tonumber(minute), sec=tonumber(seconds), tzoffset = tzoffset, offsethour = offsethour, offsetmin = offsetmin}
   
   local offset = 0
   local timestampUTC = timestamp
   if ( tzoffset ) then
      if ( tzoffset == "+" or tzoffset == "-" ) then  -- We have a timezone
         offset = offsethour * 60 + offsetmin
         if ( tzoffset == "+" ) then
            offset = offset * -1
         end
         timestampUTC = timestampUTC + offset * 60
      end
   end
   return dateTime, timestampUTC

end

-- converts a local datetime table to UTC datetime table and ISO format
aux.convertDatetimeFromCurrentTimezoneToUTC = function(localDate)
    
    local localTimestamp = os.time(localDate)

    local difTimezoneInSecs = aux.getTimezoneDifToUTC() 

    local timestampUTC = localTimestamp - difTimezoneInSecs

    local datetimeUTC = os.date("*t", timestampUTC)

    local datetimeStringUTC = string.format("%d-%.2d-%.2dT%.2d:%.2d:%.2d+00:00", datetimeUTC.year,datetimeUTC.month,datetimeUTC.day, datetimeUTC.hour, datetimeUTC.min, datetimeUTC.sec)

    return datetimeUTC, datetimeStringUTC

end



aux.convertDatetimeStringToUTC = function( dateString ) -- dateTime following  ISO-8601 time format (e.g: "2016-03-01T02:05:56-0300" = gmt-3, "2016-03-01T05:05:56Z" = utc)
    
   local _, timestampUTC = aux.parseDateTime(dateString)

   local datetimeUTC = os.date("*t", timestampUTC)

   return datestringUTC, timestampUTC 

end


-- receives a UTC Datestring (ISO-8601 format) and returns a date table + timestamp at current local timezone
aux.convertDatestringFromUTCtoCurrentTimezone = function(datestringUTC)
    -- print( os.date("!%Y-%m-%dT%XZ") ) -- utc
    -- print( os.date("%Y-%m-%dT%X%z") ) -- local
    --local currTimestamp = os.time()    
    --local currTimestampUTC = aux.getEpocUTC()
    --local difTimezone = currTimestamp - currTimestampUTC

    local difTimezone = aux.getTimezoneDifToUTC()
    --print("difTimezone=", difTimezone, difTimezone/(60*60))

    local _, dateTimestamp = aux.parseDateTime(datestringUTC)

    local convertedDateTimestamp = dateTimestamp + difTimezone
    dateTime = os.date("*t", convertedDateTimestamp)
   return dateTime, convertedDateTimestamp
   
end




function url_decode (s)
    local z = "%%(%x%x)"
    return s:gsub('+', ' '):gsub(z, function (hex) return string.char (tonumber (hex, 16)) end)
end 

aux.parseURL = function(url)
    local res = {}
    url = url:match '?(.*)$'
    for name, value in url:gmatch '([^&=]+)=([^&=]+)' do
        value = url_decode (value)
        local key = name:match '%[([^&=]*)%]$'
        if key then
            name, key = url_decode (name:match '^[^[]+'), url_decode (key)
            if type (res [name]) ~= 'table' then
                res [name] = {}
            end
            if key == '' then
                key = #res [name] + 1
            else
                key = tonumber (key) or key
            end
            res [name] [key] = value
        else
            name = url_decode (name)
            res [name] = value
        end
    end
    return res
end
-- example:
-- url = fbconnect://success?to[0]=213322147507203&to[1]=223321147507202&request=524210977333164&complex+name=hello%20cruel+world&to[string+key]=123.  Retunr
-- returns:
-- {
--   ["complex name"]="hello cruel world",
--   request="524210977333164",
--   to={ [0]="213322147507203", [1]="223321147507202", ["string key"]="123" } 
-- }



return aux

