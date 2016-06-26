local server = {}

--local serverURL = "http://192.168.1.38:3218/"
local serverURL = "https://parkandgo.azurewebsites.net/"
local composer = require "composer"
local function hasInternet(onSuccess, onFail)
    ----print("testing connection")
    --if true then return onFail() end
    
        local function testResult( event )
            if ( event.isError ) then
                onFail({noInternet=true})
            else
                onSuccess()
            end
        end
        
        --uncomment below to simulate no internet connection        
        --onFail(); return

        network.request("https://www.google.com","GET",testResult)
        
end

local serverData = {
       -- {id=1, streetName="Avenida Nestor Moreira 257", DateTimeStart="2016-06-26T14:00:01Z", hourZone=4, lat="-22.9497485",long="-43.1791603"}, 
        --{id=2,  streetName="Avenida Pasteur 456", DateTimeStart="2016-06-26T09:14:01Z"hours=1 },
    }





local handleGlobalError = function(event, onFail, silentRequest)
    print( "checking for possible errors... isError:", event.isError, " ", event.status, " ", event.phase, " ", event.response, " ", event.url )

    if event.phase ~= "ended" then return end

    local statusCode = event.status
    local isError = event.isError
    local data = (event.response and require("json").decode(event.response)) or {}

    --TEMP: FORCE ERROR TEST HERE
    --statusCode=-1; isError=true;     

    if isError ~= true and statusCode >= 200 and statusCode < 300 then 
        --print("vai retornar false"); 
        return false 
    end  -- no error, let's continue outside of this function

    
    local errorMsg

    native.setActivityIndicator( false )  -- disabling activity indicator
    
    print("statusCode=", statusCode)
    if statusCode == -1 then -- possible timeout

        hasInternet(function(data)
                data = data or {}
                data.errorMsg = "Erro na comunicação. Por favor tente mais tarde"
                
                if onFail then
                    onFail(data)
                end
                if silentRequest ~= true then
                    AUX.showAlert(data.errorMsg)
                end
            end,
            function(data)
                data = data or {}
                data.errorMsg = "Sem conexão com internet"
                if onFail then
                    onFail(data)
                end
                -- if silentRequest ~= true then
                --     AUX.showAlert(errorMsg)
                -- end
            end
            )
        
        return 

    elseif statusCode == 401 then
        errorMsg = data.Message or "Login ou senha inválidos"

        if composer.getSceneName( "current" ) ~= "scene-login" then
            _G.USER.logout()
            return true            
        end
        

    elseif statusCode == 403 then
        -- tokekn invalido?


     -- elseif statusCode > 500 and statusCode < 600 then -- server error
     --    errorMsg = data.Message

    else
        errorMsg = data.Message or "Um erro ocorreu ao processar o pedido. Tente mais tarde"

    end

    _G.ANALYTICS.logEvent{
        flurry={"server request error", {statusCode=statusCode, url=event.url, response=event.response}},
        googleAnalytics={"error", "server request error", statusCode},
    }

    if onFail then
        onFail(errorMsg)
    end

    return true

end


 -- converts a table from to a string format
local paramToString = function(paramsTable)
    local str = ""
    local i = 1
    
    for paramName,paramValue in pairs(paramsTable) do 
        ----print(paramName .. ": " .. paramValue)
        if i == 1 then
            str = paramName .. "=" .. paramValue
        else
            str = str .. "&" .. paramName .. "=" .. paramValue
        end
        i=i+1
    end
    
    return str
end 

-- function that gets a JSON from a server
--local function doRequest(endpoint, params)
local function doRequest(endpoint, parameters, onSuccess, onFail, method, onProgress, silentRequest )

    local method = method or "POST"
    
    local url = serverURL .. ( (endpoint ~= "Token" and "api/") or "") .. endpoint

    parameters = parameters or {}

   
    local function networkListener( event )

        local result, data, errorMessage = false, nil, nil

        -- uncomment below to simulate no internet connection        
        --event.isError=true; event.status = -1

        if handleGlobalError(event, onFail, silentRequest) then return  end

        --for key,value in pairs(event.responseHeaders) do --print(key,": ",value) end


        if ( event.phase == "began" ) then
            if ( event.bytesEstimated <= 0 ) then
                --print( "Download starting, size unknown" )
            else
                --print( "Download starting, estimated size: " .. event.bytesEstimated )
            end

        elseif ( event.phase == "progress" ) then
            if ( event.bytesEstimated <= 0 ) then
                --print( "Download progress: " .. event.bytesTransferred )
            else
                --print( "Download progress: " .. event.bytesTransferred .. " of estimated: " .. event.bytesEstimated )
            end
            if onProgress then
                local percentComplete = nil
                if event.bytesTransferred and event.bytesEstimated and event.bytesEstimated > 0 then
                    percentComplete = event.bytesTransferred / event.bytesEstimated
                end
                onProgress(percentComplete)
            end

        elseif ( event.phase == "ended" ) then

            --print("Network ok. Now let's decode the JSON")
            local response = event.response  --:gsub("&#8211;", "-")  -- manually replacing a HTML code for its chair
            
            print("response=", response)

            local data = require("json").decode(response)

            if data == nil or type(data) ~= "table" then
                print("Data is not a valid JSON")

            --     -- Handler that gets notified when the alert closes
            --     local function onComplete( event )
            --        if event.action == "clicked" then
            --             local i = event.index
            --             if i == 1 then
            --                 -- Retrying....
            --                 doRequest(endpoint, params, onCompleteDownload)
            --                 return
            --             elseif i == 2 then
            --                 return native.requestExit()
            --             end
            --         end
            --     end
            --     if silentRequest ~= true then
            --         local alert = native.showAlert( "Oopps", "Um problema ocorreu ao se comunicar com o servidor." , { "Tente novamente", "Tentarei mais tarde" }, onComplete )
            --     end
                if onFail then
                    onFail()
                end
                return
            
            end
            ----print("data.success=", data.success)
            ----print("data.success=", data[1].success)
            ----print("result=", result)
            if onSuccess then
                onSuccess(data)
            end
            
        end
        
    end
    

    local headers = {}
    local params = {}
    params.timeout = parameters.timeout or 30

    headers["Accept"] = "application/json"

    local getToken = function() return _G.USER and _G.USER.getToken() end
    local token = getToken()
    if token then
        headers["Authorization"] = "Bearer " .. token
    end
    
    if method == "MULTIPART" then     
            method = "POST" 
            
            
            headers["Content-Type"] = "multipart/form-data; boundary=" .. parameters.boundary
            headers["Content-Length"] = #parameters.body 

            params.body = parameters.body 
            params.bodyType = "binary"
            params.progress = "upload"

    else
        if endpoint == "Token" then
            headers["Content-Type"] = "application/x-www-form-urlencoded"
            params.body = paramToString(parameters)
            --print("body=")
            --pt(params.body)
        else
            headers["Content-Type"] = "application/json; charset=utf-8"
            params.body = require("json").encode(parameters)
            --print("params.body=", params.body)
        
        end

    end
    
    params.headers = headers
    
    if onProgress then
        params.progress = "upload"
    end
    
    --print("request to url=", url)
    return network.request( url, method, networkListener, params)

end


server.getParkings = function (onSuccess,onFail)


    
    timer.performWithDelay( 1000, onSuccess(serverData) )


    -- local params = {}

    -- params["login"] = email
    -- params["password"] = password

    --doRequest("Estacionamentos", params,onSuccess,onFail, "GET")

end

server.extendParking = function(parkingID, onSuccess,onFail)


    timer.performWithDelay( 1000, onSuccess )


    -- local params = {}

    -- params["login"] = email
    -- params["password"] = password

    --doRequest("Parking", params,onSuccess,onFail, "GET")
end


server.buyTicket = function(carPlate, onSuccess,onFail)
    
    -- local newParking = {
    --     id=os.time(),
    --     --DateTimeStart=AUX.getDateUTC(),
    --     streetName="Avenida Pasteur 138",
    --     lat="-22.9504977",
    --     long="-43.1776748",
    --     hourZone=4,
    -- }

    --local newParking = {id=1, streetName="Avenida Nestor Moreira 257", DateTimeStart="2016-06-26T14:00:01Z", hourZone=4, lat="-22.9497485",long="-43.1791603"}, 

local newParking = {id=1, streetName="Avenida Nestor Moreira 257", DateTimeStart=os.date("!%Y-%m-%dT%XZ") , hourZone=4, lat="-22.9497485",long="-43.1791603"}, 
    table.insert(serverData,newParking)

     serverData = {
       {id=1, streetName="Avenida Nestor Moreira 257", DateTimeStart=os.date("!%Y-%m-%dT%XZ"), hourZone=4, lat="-22.9497485",long="-43.1791603"}, 
        --{id=2,  streetName="Avenida Pasteur 456", DateTimeStart="2016-06-26T09:14:01Z"hours=1 },
    }
    timer.performWithDelay( 1000, onSuccess )

    
    -- local params = {}

    -- params["carPlate"] = carPlate

    --doRequest("Ticket", params,onSuccess,onFail, "GET")

end


return server

