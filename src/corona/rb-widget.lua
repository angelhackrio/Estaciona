local cw = {}

-- this should be the ultimate button function - v17 (fixed tap propagation, setEnabled, getLabel, setLabel,added cornerRadius, updated view.x position; fixed tableview getting focus)
cw.newButton = function(options)

    -- receiving options

    local id = options.id

    -- button position    
    local top = options.top
    local y = options.y
    local bottom = options.bottom
    local left = options.left
    local x = options.x
    local right = options.right


    -- button background
    local width = options.width or 0
    local height = options.height or 0
    local backgroundColor = options.backgroundColor or {1,1,1,0}
    local backgroundOverColor = options.backgroundOverColor
    local backgroundStrokeWidth = options.backgroundStrokeWidth or 0
    local backgroundStrokeColor = options.backgroundStrokeColor or {0,0,0,0}
    local backgroundStrokeOverColor = options.backgroundStrokeOverColor or {0,0,0,0}
    local cornerRadius = options.cornerRadius

    local backgroundDisabledColor = options.backgroundDisabledColor or {.3,.3,.3}


    -- button label
    local labelString = options.label
    local labelFont = options.labelFont or native.systemFont
    local labelFontSize = options.labelFontSize or 12
    local labelColor = options.labelColor or { 1,1,1 }
    local labelOverColor = options.labelOverColor or { 1,1,1 }
    local labelPadding = options.labelPadding or {left=0, top=0, bottom=0, right=0}
    local labelTruncate = options.labelTruncate or false    
    local labelAlign = options.labelAlign or "left"
    local labelWrap = options.labelWrap or (labelAlign ~= "left") or false
    local labelLineSpacing = options.labelLineSpacing
    local labelVerticalPosition = options.labelVerticalPosition or options.labelVerticalPos or "center"  -- "bottom", "center", "top"
    
    local labelDisabledColor = options.labelDisabledColor or options.labelColor

    -- button image
    local imageFile = options.imageFile
    local imageOverFile = options.imageOverFile
    local imageColor = options.imageColor 
    local imageOverColor = options.imageOverColor
    local imageWidth = options.imageWidth
    local imageHeight = options.imageHeight
    local imagePadding = options.imagePadding or {left=0, top=0, bottom=0, right=0}
    local imagePosition = options.imagePosition or options.imagePos or "left"  -- "left", "right", "center", "top", "bottom"
    local imageScaleX = options.imageScaleX or 1
    local imageScaleY = options.imageScaleY or 1
    local imageRotation = options.imageRotation or 0

    local imageDisabledColor = options.imageDisabledColor or options.imageColor 

    -- listener
    local onRelease = options.onRelease
    local onEvent = options.onEvent
    local onTap = options.onTap

    -- extra
    local keepPressed = options.keepPressed -- this disables the over effect and leaves the button pressed
    local scrollViewObj = options.scrollViewParent or options.scrollViewObj -- used to give focus to scrollView


    -- making sure table values have all values filled out
    labelPadding.left = labelPadding.left or 0
    labelPadding.right = labelPadding.right or 0
    labelPadding.top = labelPadding.top or 0
    labelPadding.bottom = labelPadding.bottom or 0

    imagePadding.left = imagePadding.left or 0
    imagePadding.right = imagePadding.right or 0
    imagePadding.top = imagePadding.top or 0
    imagePadding.bottom = imagePadding.bottom or 0




    local button = display.newGroup()   -- button group
    button.anchorChildren = true
    button.isEnabled = true

    button.id = id



    local image = nil
    local imageOver = nil
    local label = nil


    local view = display.newGroup()     -- group that hold the label and image

    -- sets the appropriatecolor accordingly to the button status
    local function setStatus(isPressed)

        if isPressed == button.isPressed then return end

        local newBackgroundColor = backgroundColor
        local newBackgroundStrokeColor = backgroundStrokeColor
        local newLabelColor = labelColor
        local newImageColor = imageColor


        if isPressed then
            newBackgroundColor = backgroundOverColor
            newBackgroundStrokeColor = backgroundStrokeOverColor
            newLabelColor = labelOverColor
            newImageColor = imageOverColor            
        end

        if newBackgroundColor then
            button.background:setFillColor( unpack(newBackgroundColor) )
        end
        if newLabelColor and button.label then
            button.label:setTextColor( unpack(newLabelColor) )
        end
        if newImageColor and button.image then
            button.image:setFillColor( unpack(newImageColor) )
        end        
        if backgroundStrokeOverColor then
            button.background:setStrokeColor( unpack(newBackgroundStrokeColor) )
        end
        if button.imageOver then
            button.image.isVisible = not isPressed
            button.imageOver.isVisible = isPressed
        end
        

        button.isPressed = isPressed
    end



    -- creating the objects

    -- loads the image
    local scaleFactor = 1
    if imageFile then
        if imageWidth and imageHeight then
            image = display.newImageRect(view, imageFile, imageWidth, imageHeight)

        elseif imageWidth ~= nil and imageHeight == nil then
            image = display.newImage(view, imageFile)
            scaleFactor = imageWidth / image.contentWidth

        elseif imageWidth == nil and imageHeight ~= nil then
            image = display.newImage(view, imageFile)
            scaleFactor = imageHeight / image.contentHeight

        end
        
        imageScaleX = imageScaleX * scaleFactor
        imageScaleY = imageScaleY * scaleFactor
            
        image:scale(imageScaleX, imageScaleY)
        image.rotation = imageRotation
        if imageColor then
            image:setFillColor( unpack(imageColor) )
        end        
        button.image = image
    end
    if imageOverFile then
        imageOver = display.newImageRect(view, imageOverFile, imageWidth, imageHeight)
        imageOver:scale(imageScaleX, imageScaleY)
        image.rotation = imageRotation
        if imageOverColor then
            imageOver:setFillColor( unpack(imageOverColor) )
        end        
        button.imageOver = imageOver
        imageOver.isVisible = false

    end
    

    -- creates the label
    if labelString then
        local labelMaxWidth = nil
        if width then
            labelMaxWidth = width - labelPadding.left - labelPadding.right
            
            if imageWidth then
                if imagePosition == "left" or imagePosition == "right" then
                    labelMaxWidth = labelMaxWidth - image.width - imagePadding.left
                end
            end        

        end
        local labelWidth = nil 
        if labelWrap and not labelTruncate then
            labelWidth = labelMaxWidth
        end
        if labelLineSpacing then
            label = display.newText2{parent=view, text=labelString, font=labelFont, fontSize=labelFontSize, width=labelWidth, align=labelAlign, color=labelColor}
            label.anchorChildren = true
            label.anchorX = .5
            label.anchorY = .5
        else
            label = display.newText{parent=view, text=labelString, font=labelFont, fontSize=labelFontSize, width=labelWidth, align=labelAlign}
            label:setTextColor( unpack(labelColor) )
        end                
        button.label = label
        
        if labelTruncate then
            if _G.AUX == nil or _G.AUX.adjustTextSize == nil then
                error("Function newButton: Please load aux library with adjustTextSize") 
            end
            if labelLineSpacing then
                --print("Function newButton: labelTruncate cannot be used when labelLineSpacing is set load aux library with adjustTextSize")
            else
                _G.AUX.adjustTextSize(label, labelMaxWidth)
            end
            
        end    
    end

    -- positionate the objects
    local buttonW = nil
    local buttonH = nil

    if label == nil then
        -- button has only an image

        buttonW = imagePadding.left + image.contentWidth + imagePadding.right       
        buttonH = math.max(height, image.contentHeight)

        image.x = image.contentWidth*.5 + imagePadding.left - imagePadding.right
        image.y = buttonH*.5 + (imagePadding.top or 0 ) - (imagePadding.bottom or 0)

    elseif image == nil then
        -- button has only text

        label.x = labelPadding.left + label.contentWidth*.5            
        buttonW = labelPadding.left + label.contentWidth + labelPadding.right
        
        buttonH = math.max(height, label.contentHeight)

        label.y = labelPadding.top - labelPadding.bottom
        if labelVerticalPosition == "center" then
            label.y = label.y + buttonH*.5

        elseif labelVerticalPosition == "top" then
            label.y = label.y + label.contentHeight*.5

        elseif labelVerticalPosition == "bottom" then            
            label.y = label.y + buttonH - label.contentHeight*.5
        end



    else
        -- button has image and text

        if imagePosition == "left"  then
            image.x = image.contentWidth*.5 + imagePadding.left - imagePadding.right
            label.x = image.x + image.contentWidth*.5 + imagePadding.right + labelPadding.left + label.contentWidth*.5            
            buttonW = imagePadding.left + image.contentWidth + imagePadding.right + labelPadding.left + label.contentWidth + labelPadding.right
            
            buttonH = math.max(height, image.contentHeight, label.contentHeight)

            image.y = buttonH*.5 + (imagePadding.top or 0 ) - (imagePadding.bottom or 0)
            label.y = buttonH*.5 + labelPadding.top - labelPadding.bottom


        elseif imagePosition == "right" then                    
            label.x = label.contentWidth*.5 + labelPadding.left 
            image.x = label.x + label.contentWidth*.5 + labelPadding.right + imagePadding.left + image.contentWidth*.5 - imagePadding.right
            buttonW = imagePadding.left + image.contentWidth + imagePadding.right + labelPadding.left + label.contentWidth + labelPadding.right
            
            buttonH = math.max(height, image.contentHeight, label.contentHeight)

            image.y = buttonH*.5 + imagePadding.top - imagePadding.bottom
            label.y = buttonH*.5 + labelPadding.top - labelPadding.bottom

        elseif imagePosition == "top" then

            buttonW = math.max(width, image.contentWidth, label.contentWidth)

            image.x = buttonW*.5 + imagePadding.left - imagePadding.right
            label.x = buttonW*.5 + labelPadding.left - labelPadding.right

            image.y = image.contentHeight*.5 + imagePadding.top - imagePadding.bottom
            label.y = image.y + image.contentHeight*.5 + imagePadding.top - imagePadding.bottom + labelPadding.top + label.contentHeight*.5 - labelPadding.bottom

            buttonH = image.contentHeight + imagePadding.top - imagePadding.bottom + labelPadding.top + label.contentHeight - labelPadding.bottom
            buttonH = math.max(height, buttonH)

        elseif imagePosition == "bottom" then

            buttonW = math.max(width, image.contentWidth, label.contentWidth)

            image.x = buttonW*.5 + imagePadding.left - imagePadding.right
            label.x = buttonW*.5 + labelPadding.left - labelPadding.right
            
            label.y = label.contentHeight*.5 + labelPadding.top - labelPadding.bottom
            image.y = label.y + label.contentHeight*.5 + labelPadding.top - labelPadding.bottom + imagePadding.top + image.contentHeight*.5 - imagePadding.bottom
            

            buttonH = image.contentHeight + imagePadding.top - imagePadding.bottom + labelPadding.top + label.contentHeight - labelPadding.bottom

        end
    end

    if imageOver then
        imageOver.x, imageOver.y = image.x, image.y
    end


    -- creates the button background
    buttonW = math.max(buttonW, width)
    local background
    if cornerRadius then
        background = display.newRoundedRect(button, buttonW*.5, buttonH*.5, buttonW, buttonH, cornerRadius)        
    else
        background = display.newRect(button, buttonW*.5, buttonH*.5, buttonW, buttonH)
    end
    --local background = display.newRect(button, buttonW*.5, buttonH*.5, buttonW, buttonH)
    background:setFillColor( unpack(backgroundColor) )
    background.isHitTestable = true
    button.background = background
    background.strokeWidth = backgroundStrokeWidth
    background:setStrokeColor( unpack(backgroundStrokeColor) )

    -- adds the view (which has the image and label) to the button group
    button:insert(view)
    view.x = 0 --background.contentWidth*.5 - view.contentWidth*.5
    --view.y = view.contentHeight*.5
    -- the view group, when have label + text, it has the contentWidth == button. But the view.contentWidth may be not equal to to button.width because the group does nto count empty space in the begging
    -- the view group when using only label, or only text, it usually have the label/text width.



    -- positioning the button
    button.x = x or (left and (left + button.contentWidth*.5)) or (right and (right - button.contentWidth*.5))
    button.y = y or (top and (top + button.contentHeight*.5)) or (bottom and (bottom - button.contentHeight*.5))


    -- check if an event (x,y) is within the bounds of an object
    local function isWithinBounds( object, event )
        local bounds = object.contentBounds
        local x, y = event.x, event.y
        local isWithinBounds = true
            
        if "table" == type( bounds ) then
            if "number" == type( x ) and "number" == type( y ) then
                isWithinBounds = bounds.xMin <= x and bounds.xMax >= x and bounds.yMin <= y and bounds.yMax >= y
            end
        end
        
        return isWithinBounds
    end

    -- touch listener of the button
    local function touchListener(event)
        if button.isEnabled == false then return end

        local phase = event.phase

        if phase == "began" then
            setStatus( true )

            -- Set focus on the button
            button._isFocus = true
            display.getCurrentStage():setFocus( button, event.id )

        elseif button._isFocus then

            if phase == "moved"  then
                
                    local dy = math.abs( event.y - event.yStart )

                     if dy > 12 then
                        --print("scrollViewObj=", scrollViewObj)
                        if scrollViewObj then
                            
                            local sv = scrollViewObj
                            if type(scrollViewObj) == "function" then
                                sv = scrollViewObj()
                            end
                            if keepPressed ~= true then
                                setStatus( false )
                            end
                            --print( sv.id)
                            if sv.id == "widget_tableView" then
                                display.getCurrentStage():setFocus(nil)
                                event.target = sv._view
                                event.phase = "began"
                                sv._view.touch(sv._view, event)
                            else
                                sv:takeFocus( event )
                            end
                                                        
                            return
                        end
                         
                    end

                if isWithinBounds( button.background, event ) then
                    setStatus( true )
                else
                    --if keepPressed ~= true then
                        setStatus( false )
                    --end
                end


            elseif phase == "ended" or phase == "cancelled" then
                
                if keepPressed ~= true then
                    setStatus( false )
                end
                
                if isWithinBounds( button.background, event ) then
                    if onRelease then
                        onRelease(event)
                    end
                end

                -- Remove focus from the button
                button._isFocus = false
                display.getCurrentStage():setFocus( nil )

            end

        end

        if onEvent then
            onEvent(event)
        end

        return true -- don't allowing touch event to propagate

    end

    local function tapListener(event)
        if button.isEnabled == false then return end

        if onTap then
            onTap(event)
        end

        return true -- don't allowing tap event to propagate
    end

    if onRelease then
        button:addEventListener( "touch", touchListener )
    end
    if onTap then
        button:addEventListener( "tap", tapListener )
    end
    
    button.setStatus = setStatus

    function button:getLabel()
        return button.label.text
        
    end
    function button:setLabel(text)
        button.label.text = text
        
    end

    function button:setEnabled(isEnabled)
    
        if isEnabled == button.isEnabled then return end

        local newBackgroundColor = backgroundDisabledColor
        local newLabelColor = labelDisabledColor
        local newImageColor = imageDisabledColor


        if isEnabled then
            newBackgroundColor = backgroundColor
            newLabelColor = labelColor
            newImageColor = imageColor            
        end

        if newBackgroundColor then
            button.background:setFillColor( unpack(newBackgroundColor) )
        end
        if newLabelColor and button.label then
            button.label:setTextColor( unpack(newLabelColor) )
        end
        if newImageColor and button.image then
            button.image:setFillColor( unpack(newImageColor) )
        end        
                
        button.isEnabled = isEnabled
        
    end
    --------------------------------------------------------------
    -- The function and variable below are just to make this widget compatible with takeFocus function of the other Corona widgets - like scrollview
    --------------------------------------------------------------
    function button:_loseFocus()
        setStatus( false )
        
    end
    button._widgetType = "buttonRB"



    return button

end




-- textfield with a line below it. -- v7 (added left/right label; added autocapitalizationType;  added nextInput, isSecure e align; added brazilian phone validation)
cw.newTextField = function(options)

    -- receiving params
    local x = options.x
    local left = options.left
    local y = options.y
    local top = options.top
    local w = options.w or options.width or 170
    local h = options.h or options.height or 30

    local listener = options.listener
    local placeholder = options.placeholder
    local placeholderColor = options.placeholderColor or {1,1,1}
    local text = options.text    
    local textColor = options.textColor or {195/255, 99/255, 70/255}
    local font = options.font or (myGlobals and myGlobals.fontTextLabel) or native.systemFont
    local fontSize = options.fontSize or 20
    local returnKey = options.returnKey or "done"
    local inputType = options.inputType or "default"

    local forceUpperCase = options.forceUpperCase
    local autocapitalizationType = options.autocapitalizationType  -- "all", "sentences", "words"
    local maxChars = options.maxChars
    local invalidChars = options.invalidChars   -- string ex:  "abc". If it is a non-alphanumeric, escape using %  (eg.: "abc%^%[%%")  invalid chars here are a,b,c,^,[ and%

    local autocorrectionType  = options.autocorrectionType or options.autoCorrectionType or "UITextAutocorrectionTypeDefault"  -- values are:  "UITextAutocorrectionTypeDefault or "UITextAutocorrectionTypeYes", "UITextAutocorrectionTypeNo"
    local hasBottomLine = options.hasBottomLine or (options.hasBottomLine == nil)

    local parent = options.parent
    local id = options.id
    local index = options.index

    local formatType = options.formatType
    local align = options.align or "left"
    local isSecure = options.isSecure or false
    local nextInput = options.nextInput


    local leftLabel = options.leftLabel
    local rightLabel = options.rightLabel

    if _G.DEVICE.isAndroid then 
        h = h + 4
        if fontSize and _G.DEVICE.isAndroid then
            fontSize = fontSize - 2
        end

    end


    autocapitalizationType = (forceUpperCase and "all") or autocapitalizationType

    local autocapitalizationTypeOptions = {["all"] = 1, ["sentences"]=2, ["words"]=3}
    autocapitalizationType = autocapitalizationTypeOptions[autocapitalizationType]

        
    -- creating pattern for invalid chars
    local pattern = "["
    if invalidChars then
        for i=1,#invalidChars do
            local chr = invalidChars:sub(i,i)
            if chr:match("%W") then  -- if not alphanumeric
                pattern = pattern .. "%" .. chr
            else
                pattern = pattern .. chr
            end

        end
    end
    pattern = pattern.."]"

    -- format functions
    local format={}
    format["zipcode"] = function(text, removeFormat)

        if text == nil or #text == 0 then
            return ""
        end

        --text = text:gsub("-","")
        text = text:gsub("[^0-9]","") -- removing everything that is not number
        if removeFormat then
            return text
        end

        local firstPart = text:sub(1,5)
        local secondPart = text:sub(6,8)

        if secondPart ~= "" then
            return firstPart .. "-" .. secondPart
        end

        return firstPart
    end
    format["phone-br"] = function(text, removeFormat)

        if text == nil or #text == 0 then
            return ""
        end

        text = text:gsub("[^0-9]","") -- removing everything that is not number
        if removeFormat then
            return text
        end

        local firstPart = text:sub(1,2) -- ddd
        local secondPart = text:sub(3,6) -- first digits 
        local thirdPart = text:sub(7,10) -- last digits
        if #text >= 11 then
            secondPart = text:sub(3,7)
            thirdPart = text:sub(8,11)
        end

        if secondPart ~= "" and thirdpart ~= "" then
            return "(" .. firstPart .. ")" .. secondPart .. "-" .. thirdPart
        elseif secondPart ~= "" then
            return "(" .. firstPart .. ")" .. secondPart
        end

        return "(" .. firstPart .. ")" 
    end
    format["currency-br"] = function(text, removeFormat)

        if text == nil or #text == 0 then
            return ""
        end

        text = text:gsub("[^0-9%,.]","") -- removes the R$
        text = text:gsub("[%,]","%.")   -- replaces the "," with "."
        text = tonumber(text)
        if removeFormat then        
            return text -- return the currency as a number in decimal US format
        end

        text = string.format("R$ %.2f", text)
        text = text:gsub("[%.]","%,")   -- replaces the "." with ","
        return text

    end

    local group = display.newGroup()


    local lbLeft = nil
    local lbLeftW = 0
    local lbRight = nil
    local lbRightW = 0

    -- labels
    if leftLabel then
        lbLeft = display.newText{x=0, y=0, text=leftLabel,font=font, fontSize=fontSize}
        lbLeft.anchorX = 0
        lbLeftW = lbLeft.contentWidth

    end
    if rightLabel then
        lbRight = display.newText{x=0, y=0, text=rightLabel,font=font, fontSize=fontSize}
        lbRight.anchorX = 0
        lbRightW = lbRight.contentWidth

    end

    local input
    local lastChar = nil
    local function textListener( event )
        ----print( "on textListener - ", event.phase )

        local target = event.target
        --pt(event,target.text)
          ----print( target.text )
        if ( event.phase == "began" ) then
            -- user begins editing defaultField            
            target:setTextColor( unpack(textColor) )
            if placeholderColor and target.text == placeholder then
                target.text = ""                
            end

        elseif ( event.phase == "ended" or event.phase == "submitted" ) then
            -- do something with defaultField text
            ----print( "finished", event.target.text )
            if placeholderColor and target.text == "" then
                target.text = placeholder
                target:setTextColor( unpack(placeholderColor) )
            end

            if ( event.phase == "submitted" ) then  
                
                if type(nextInput) == "function" then
                    nextInput, aaa = nextInput()
                    
                end
                nextInput = (nextInput and nextInput.input) or nextInput
                
                native.setKeyboardFocus(nextInput)

            end
            
        elseif ( event.phase == "editing" ) then
            if _G.DEVICE.isAndroid then 
                if autocapitalizationType == 2 and event.startPosition == 1  then
                    local currText = event.target.text
                    input.text = string.upper(currText:sub(1,1)) .. (currText:sub(2) or "")
                end
                return 

            end -- android is showing too much lag here
            

            ----print("event.startPosition=", event.startPosition)
            ----print("autocapitalizationType=", autocapitalizationType)            

            if maxChars then
                event.target.text = string.sub(event.text,0,maxChars)
            end
           ----print("event.newCharacters=",event.newCharacters)
           ----print("invalidChars:find(event.newCharacters)=",invalidChars:find(event.newCharacters))
            --if invalidChars and invalidChars:find("[%" .. event.newCharacters .. "]") then
            if invalidChars and event.newCharacters:find(pattern) then
                input.text = string.sub(event.text,1,#event.text - 1)
            end

            if autocapitalizationType == 1 then
                input.text = string.upper(event.target.text)
                
            elseif event.startPosition == 1 and autocapitalizationType == 2 then
                input.text = string.upper(event.target.text)

            elseif autocapitalizationType == 3 and lastChar == " " then
                input.text = string.sub(event.text,1,#event.text - 1) .. string.upper( event.newCharacters )
            end

            if forceUpperCase then
                input.text = string.upper(event.target.text)
                
            end

            if event.target.text then
                if format[formatType] then
                    
                    local isDeleting = (event.newCharacters == "")
                    
                    local formattedText = format[formatType](event.target.text)             
                    local charBefore = string.sub(formattedText, event.startPosition, event.startPosition )
                    local charAfter
                    if event.startPosition+1 <= #formattedText then
                        charAfter = string.sub(formattedText, event.startPosition+1,event.startPosition+1)
                    end
                    event.target.text = formattedText
                    if _G.DEVICE.isAndroid and (isDeleting == false) and (charBefore ~= event.newCharacters and charAfter == event.newCharacters) then                        
                        event.target:setSelection( event.startPosition+1, event.startPosition+1 )
                        ----print("moved cursor")
                    end
                    
                end
    
            end  
            lastChar = event.newCharacters
            
        end

        if listener then listener(event) end 
    end
    local inputW = w - lbLeftW - lbRightW
    --input = native.newTextField( inputW*.5 + lbLeftW, h*.5, inputW, h )
    input = native.newTextField( inputW*.5 + lbLeftW, -2000, inputW, h ) -- starting the textfield out of screen to avoid the textfield blinking at 0,0 position on Android devices.  
    --input = native.newTextField( -2000, -2000, inputW, h )  -- comment a: if we change the x position, we need to reposition it below (as already commented below)
    input.isSecure = isSecure
    input.hasBackground = false    
    input.font = native.newFont( font, fontSize )    
    if placeholderColor == nil then
        input.placeholder = placeholder
        input:setTextColor( unpack(textColor) )
    else
        input.text = placeholder
        input:setTextColor( unpack(placeholderColor) )
    end   
    input:addEventListener( "userInput", textListener )
    input:setReturnKey( returnKey )
    input.inputType = inputType
    input.align = align
    input.autocorrectionType = autocorrectionType
 
    input.id = id
    input.index = index
    
    group:insert(input)
    group.input = input


    if lbLeft then
        group:insert(lbLeft)
        lbLeft.x = 0
        --input.x = lbLeft.x + lbLeft.contentWidth + inputW*.5  -- comment (a) above
        lbLeft.y = input.y

    end

    if lbRight then
        group:insert(lbRight)
        lbRight.x = input.x + inputW*.5
        lbRight.y = input.y

    end

    if hasBottomLine then
        -- adding the line below the textfield
        local lineY = input.y + input.contentHeight*.5
        local lineLeft = input.x - input.contentWidth*.5
        local line = display.newLine(lineLeft, lineY , lineLeft + input.contentWidth, lineY)
        line.strokeWidth = 1
        line:setStrokeColor( 0,0,0,.3 )
        group:insert(line)

    end

    


    if parent then
        parent:insert(group)
    end



    group.anchorChildren = true  -- this automatically reposition the textfield inside the group
    group.x = x or (left + w*.5)
    group.y = y or (top + h*.5)


    -- public functions

    function group:setText(text)
        text = text or ""
        if format[formatType] then
            text = format[formatType](text)
        end
        if placeholderColor and text == "" then
            input.text = placeholder  
            input:setTextColor( unpack(placeholderColor) )

        else
            input.text = text
            input:setTextColor( unpack(textColor) )

        end
        
    end

    function group:getText()
        local text = input.text
        if format[formatType] then
            text = format[formatType](text, true)
        end
        if placeholderColor and text == placeholder then
            text = ""
        end
        return text

    end

    function group:setPlaceholder(text)
        if placeholderColor == nil then
            input.placeholder = text
        elseif input.text == placeholder then
            input.text = text
        end
        placeholder = text
        --print("updated placeholder to ", text)

    end

    function group:getPlaceholder()
        return input.placeholder

    end

    function group:setVisibility(isVisible)                       
        group.isVisible = isVisible
        input.isVisible = isVisible

    end

    function group:setAlpha(finalAlpha, duration, onComplete)                
        transition.to(group, {alpha=finalAlpha, time = duration})
        transition.to(input, {alpha=finalAlpha, time = duration, onComplete=onComplete})

    end

    function group:remove()
        display.remove(input); input = nil
        display.remove( group ); group = nil

    end

    group.getFocus = function()
        native.setKeyboardFocus(input)

    end





    return group            

end






return cw
