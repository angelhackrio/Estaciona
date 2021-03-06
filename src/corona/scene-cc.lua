local composer = require( "composer" )

local scene = composer.newScene()

local inputs = {}
local rbw = require "rb-widget"

function scene:create( event )

    local sceneGroup = self.view  

    local background = display.newRect(sceneGroup, CENTER_X, CENTER_Y, SCREEN_W, SCREEN_H)
    background.fill = {1,1,1}


    local topbar = require("module-topbar").new(sceneGroup)
    
    local showForm = function(parkingData)

        local dataFields = {
            { label = "Nome no Cartão", },
            { label = "Número do Cartão" },
            { label = "Validade"},
            { label = "Código de Segurança" },            

        }

        local createInputRow = function(dataField)

            local group = display.newGroup()

            local background = display.newRect(group, CENTER_X, 30, SCREEN_W, 60)
            background.fill = {1,0,1,0}


            local label = display.newText{parent=group, text= dataField.label .. ":" , x=10, y=background.y, fontSize=16, font=(dataField.font or native.systemFont)}
            label.anchorX = 0
            label:setTextColor(0,0,0)

            if dataField.value == nil then
                local maxChar = nil
                if (dataField.label == "Validade") then
                    maxChar = 4
                elseif (dataField.label == "Código de Segurança") then
                    maxChar = 4
                elseif (dataField.label == "Número do Cartão") then
                    maxChar = 16
                end
                local inputW = SCREEN_W - (label.x + label.contentWidth + 20)
                inputs[dataField.label] = rbw.newTextField{
                    width = inputW,
                    height = background.contentHeight*0.8,
                    left = label.x + label.contentWidth + 10,
                    y = background.y,
                    inputType = (dataField.label == "Nome no Cartão" and  "default") or "number"
                    maxChars = maxChar,

                }
                group:insert(inputs[dataField.label])

            else
                local labelW = SCREEN_W - (label.x + label.contentWidth + 10)
                local value = dataField.value
                if  dataField.label == "Preço" or dataField.label == "TOTAL" then
                    value = string.format("R$ %d", dataField.value)
                end
                local label = display.newText{parent=group, text= value .. (dataField.valueSuffix or "" ), x=label.x + label.contentWidth + 10, y=background.y, fontSize=16, font=(dataField.font or native.systemFont)}
                label.anchorX = 0
                label:setTextColor(0,0,0)

                group.labelValue = label
                if dataField.label == "TOTAL" then
                    sceneGroup.labelTotalValue = label
                end
                group:insert(label)
            end

            if  dataField.label == "Quantidade" then
                local btLess = rbw.newButton{
                    y=background.y,
                    width=32, --14*_G.GROW_WITH_SCREEN_W,
                    height=background.contentHeight*0.8,
                    right=SCREEN_W,
                    -- imageFile="images/icon-plus.png",
                    -- imageWidth=iconMenuH, --7*_G.GROW_WITH_SCREEN_W,
                    -- imageHeight=iconMenuH, --7*_G.GROW_WITH_SCREEN_W,                       
                    -- imageColor = {1,1,1},
                    -- imageOverColor = {1,1,1,.5},
                    -- imagePadding = {left = 10},
                    label = "-",
                    labelColor = {1,1,1},
                    labelFontSize=18,
                    labelAlign="center",
                    backgroundColor = {37/255,146/255,56/255},
                    
                    onRelease = function()
                        if tonumber(group.labelValue.text) > 1 then
                            group.labelValue.text = group.labelValue.text - 1
                            local value = parkingData.zoneHours * parkingData.zonePrice * group.labelValue.text
                            sceneGroup.labelTotalValue.text = string.format("R$ %d", value)
                        end

                    end
                }
                group:insert(btLess)

                local btMore = rbw.newButton{
                    y=background.y,
                    width=32, --14*_G.GROW_WITH_SCREEN_W,
                    height=background.contentHeight*0.8,
                    right= btLess.x - btLess.contentWidth*.5 - 4,
                    -- imageFile="images/icon-plus.png",
                    -- imageWidth=iconMenuH, --7*_G.GROW_WITH_SCREEN_W,
                    -- imageHeight=iconMenuH, --7*_G.GROW_WITH_SCREEN_W,                       
                    -- imageColor = {1,1,1},
                    -- imageOverColor = {1,1,1,.5},
                    -- imagePadding = {left = 10},
                    label = "+",
                    labelColor = {1,1,1},
                    labelFontSize=18,
                    labelAlign="center",
                    backgroundColor = {37/255,146/255,56/255},
                    
                    onRelease = function()                        
                            group.labelValue.text = group.labelValue.text + 1
                            print("parkingData.zoneHours=", parkingData.zoneHours)
                            print("parkingData.zonePrice=", parkingData.zonePrice)
                            print("group.labelValue.text=", group.labelValue.text)
                            local value = parkingData.zoneHours * parkingData.zonePrice * group.labelValue.text
                            sceneGroup.labelTotalValue.text = string.format("R$ %d", value)
                    end
                }
                group:insert(btMore)

            end

            local line = display.newLine( group, 0, background.contentHeight, SCREEN_W, background.contentHeight)
            line:setStrokeColor({.3,.3,.3,.3})
            line.strokeWidth=1
            

            return group

        end
        local groupInputs = display.newGroup( )
        sceneGroup:insert(groupInputs)
        groupInputs.y = 50
        for k,v in ipairs(dataFields) do
            local field = createInputRow(v)
            field.x = CENTER_X - field.contentWidth*.5
            field.y = groupInputs.numChildren == 0 and 0 or groupInputs.contentHeight        
            
            groupInputs:insert(field)  
        end

        

        local rbw = require "rb-widget"
        local imageH = 87*.3
        local btPay = rbw.newButton{
            right = SCREEN_W,
            bottom = SCREEN_H,
            width = SCREEN_W,
            height = 50,
            backgroundColor = {37/255,146/255,56/255},
            label = "ADICIONAR",
            labelFontSize=18,
            labelAlign="center",


            onRelease = function()

                local cc = {}
                cc.number = inputs['Número do Cartão']:getText()
                cc.name = inputs['Nome no Cartão']:getText()
                cc.expire = inputs['Validade']:getText()
                cc.cvc = inputs['Código de Segurança']:getText()
                _G.USER.cc = cc
               
                if cc.name == "" then return AUX.showAlert("Entre o nome no cartão") end
                if cc.number == "" then return AUX.showAlert("Entre o número do cartão") end
                if cc.expire == "" then return AUX.showAlert("Entre a data de validade") end
                if cc.cvc == "" then return AUX.showAlert("Entre o código de segurança") end

                composer.removeScene("scene-new")
                composer.gotoScene( "scene-new", { effect="slideRight", time=400})

            end

        }
        sceneGroup:insert(btPay)


    end

    showForm({zoneHours=4, zonePrice=2})
end


function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        
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