-------------------------------------------------------------------------------------------------------------------------
-- RBG Library (based on Corona Library)                                                                              
-- Library: Display                                                                                                   
-- v 1.34                                                                                                              
-- Dependencies: None                                                                                                  
--       
-- 1.34 : added .OS, .model, .store and Windows device
-- 1.33: added FireTV
-- 1.32: added HTML5
-- 1.31: set isGoogle = false if is Glass 
-- 1.3: added Glass device 
--    
-------------------------------------------------------------------------------------------------------------------------


-- Project: Simple device detection flags
--
-- File name: main.lua
--
-- Author: Corona Labs
--
-- Abstract: Sets up some simple boolean flags that lets us do various device tests.
--
--
-- Target devices: simulator, device
--
-- Sample code is MIT licensed, see http://www.coronalabs.com/links/code/license
-- Copyright (C) 2012 Corona Labs Inc. All Rights Reserved.
---------------------------------------------------------------------------------------
local M = {}

--
-- Set up some defaults
--

M.isApple = false
M.isAndroid = false
M.isGoogle = false
M.isKindleFire = false
M.isNook = false
M.is_iPad = false
M.isTall = false
M.isSimulator = false
M.isSimulatorMac = false
M.isSimulatorWin = false
M.isWindows = false   -- all Windows Phone devices and Windows Phone emulator

M.OS = nil      -- operation system
M.store = system.getInfo("targetAppStore")   -- store to which the app was build for: "apple", "amazon", "google", "windows", ...      --  https://docs.coronalabs.com/api/library/system/getInfo.html#targetappstore
M.model = string.lower(system.getInfo("model"))

M.isGlass = false
M.is_iOS7 = false
M.isHTML5 = false
M.isFireTV = false



----------------------------
-- DEFINING THE DEVICE 
----------------------------

local model = system.getInfo("model")

-- Are we on the Corona simulator?

if "simulator" == system.getInfo("environment") then
    M.isSimulator = true
    if "Mac OS X" == system.getInfo("platformName") then
        M.isSimulatorMac = true
    elseif "Win" == system.getInfo("platformName") then
        M.isSimulatorWin = true        
    end
end

-- lets see if we are a tall device

M.isTall = false
if (display.pixelHeight/display.pixelWidth) > 1.5 then
    M.isTall = true
end

-- first, look to see if we are on some Apple platform.
-- All models start with iP, so we can check that.

if string.sub(model,1,2) == "iP" then 
     -- We are an iOS device of some sort
     M.isApple = true
     
     if string.sub(system.getInfo("platformVersion"),1,1) == "7" then
         M.is_iOS7 = true
     end

     if string.sub(model, 1, 4) == "iPad" then
         M.is_iPad = true
     end

elseif string.lower(system.getInfo("platformName")) == "html5" then
        M.isHTML5 = true
 
 elseif string.lower(system.getInfo("platformName")) == "winphone" then
        M.isWindows = true
 else
     
    -- Not Apple, then we must be one of the Android devices
    M.isAndroid = true

    -- lets assume we are Google for the moment
    M.isGoogle = true

    -- All the Kindles start with K, though Corona SDK before build 976's Kindle Fire 9 returned "WFJWI" instead of "KFJWI"

    if model == "Kindle Fire" or model == "WFJWI" or string.sub(model,1,2) == "KF" then
        M.isKindleFire = true
        M.isGoogle = false
    end

    -- is fireTV
    if model == "AFTB" then
        M.isFireTV = true
        M.isGoogle = false
    end

    -- Are we a nook?

    if string.sub(model,1,4) == "Nook" or string.sub(model,1,4) == "BNRV" then
        M.isNook = true
        M.isGoogle = false
    end
    
    -- is this Glass?
    if string.lower(string.sub(model,1,5)) == "glass" then
        M.isGlass = true
        M.isGoogle = false -- making this false to make it easier to separate Google Play devices from Glass
    end
    
        
end


----------------------------
-- DEFINING THE DEVICE OS
----------------------------

if isApple then
    M.OS =  "ios"
elseif isAndroid then
    M.OS =  "android"
elseif isWindows then
    M.OS =  "windows"           
else
    M.OS =  "unknown"    
end




return M

