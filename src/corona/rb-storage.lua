--------------------------------------------------
-- RB Library                                  
-- Library: Storage
-- v 2.0.1                                     
-- Dependencies:                                
--  . none                                      
--                                              
-- Last modifications: 
-- v2.0.1: added returnNilIfNotExist on .get                         
-- v2.0: refactored lib
-- v1.4: added handling loading empty file
-- v1.3: fixed free function to clear the data of the locally saved file
-- v1.2: cleaned functions. Now also using base64 encoding to save encripted data
-- v1.14: fixed random number geration to not generate the same number when calling twice
-- v1.13: fixed bug (making sure encrypt/decypt have the same cypher)
-- v1.12: added encrypt/decrypt functions
-- v1.1: restructured settings to not use flags 
--                                              
--------------------------------------------------


local storage = {}


local disableBase64Encode = false         -- by default, the data will be always encoded with base64. If you want to disable it for debug purposes, just set this variable to true
storage.cryptoKey = "t7tG6gMRT6Q6Doav"    -- key used to encrypt text. If not set and user specified to use Encode (above), it encode using mime b64



local json = require "json"

local cypher = "RC2-40-CBC" -- The "RC2-40-CBC" complies with the US export because it has less than 64 bits.


------------------------------------------
------ PRIVATE FUNCTIONS


-- encrypt the data
local function encrypt(data)
    
    local openssl = require "plugin.openssl"

    local cipher = openssl.get_cipher (cypher) --( "aes-256-cbc" )
    
    return cipher:encrypt ( data, storage.cryptoKey)
    
    --  to list all ciphers available, just run the code below    
    --    local c = openssl.get_cipher ( true )
    --    for i=1, #c do
    --            print(i,"=", c[i])                                -- this line prints the cypher code name. eg: aes-256-cbc
    --            local evp_cipher = openssl.get_cipher ( c[i] )      -- this line gets the cypher
    --            local t = evp_cipher:info()                         -- this line gets the cypher info
    --            print("t.name=", t.name)                            -- this line gets the name info
    --            print("t.block_size=", t.block_size)                -- this line gets block size in bytes (1 byte = 8 bits)
    --            print("t.key_length=", t.key_length)                -- this line gets key lenght in bytes (1 byte = 8 bits)
    --            print("t.iv_length=", t.iv_length)                  -- this line gets iv lenght in bytes (1 byte = 8 bits)
    --
    --            -- To comply with US export, needs to be no max 64 bits (= 8 bytes of key_lenght)
    --    end
end

-- decrypt the data
local function decrypt(data)
    
    local openssl = require "plugin.openssl"

    local cipher = openssl.get_cipher ( cypher )
    
    return cipher:decrypt ( data, storage.cryptoKey )
end

-- encode data using base64
local function encodeBase64(data)
        local mime=require('mime')
        local len = data:len()
        local t = {}
        for i=1,len,384 do
                local n = math.min(384, len+1-i)
                if n > 0 then
                        local s = data:sub(i, i+n-1)
                        local enc, _ = mime.b64(s)
                        t[#t+1] = enc
                end
        end

        return table.concat(t)
end

-- decode data encoded with base64
local function decodeBase64(data)
        local mime=require('mime')
        local len = data:len()
        local t = {}
        for i=1,len,384 do
                local n = math.min(384, len+1-i)
                if n > 0 then
                        local s = data:sub(i, i+n-1)
                        local dec, _ = mime.unb64(s)
                        t[#t+1] = dec
                end
        end
        return table.concat(t)
end


-- function that is called to encode the data
local function encode(data)
        
    if storage.cryptoKey then
        data = encrypt(data)        
    end
    if disableBase64Encode ~= true then
        data = encodeBase64(data)
    end    
    
    return data    
end


-- function that is called to decode the data
local function decode(data)
    
    if disableBase64Encode ~= true then
        data = decodeBase64(data)
    end
        
    if storage.cryptoKey then
        data = decrypt(data)
    end
    
    return data    
end


--------------------------------------------------------------------------------------------------------
-- save: save the content of dataGroup table in a JSON file named as the dataGroup variable name
-- @param dataGroup: name of the dataGroup (not the table!)
-- @return
local function writeToFile(dataGroup) 
    --print("writeToFile")   
    --_G.mark("storage.writeToFile")

    local path = system.pathForFile(dataGroup .. ".ini", system.DocumentsDirectory)

    local data = storage["_" .. dataGroup]
    if data == nil then -- No dataGroup in memory. Let's remove file        
        os.remove(path);
    else
        local fh = io.open(path, "w")        
        local text = encode(json.encode(data))
        
        fh:write(text)
        fh:close()
    end
        --print("closing file")
    --_G.mark("storage.save finished")
end

----------------------------------------------------------------------------------------------------
-- load: loads the dataGroup JSON file in the _dataGroup variable and retuns _dataGroup
-- @param dataGroup: name of the file to open
local function readFile(dataGroup, useResourceDirectory, returnNilIfNotExist) 
    local path = system.pathForFile(dataGroup .. ".ini", (useResourceDirectory and system.ResourceDirectory) or system.DocumentsDirectory)
    
    local fh, reason = io.open(path, "r")
    
    if fh then
        -- read all contents of file into a string
        local contents = fh:read("*a")
        
        local function readContent(value)
            
            value = json.decode(decode(value)) 

            return value
            
        end
        
        local succ, data = pcall(readContent,contents)  -- decodes the file inside a pcall to avoid crash
        
        if succ then
            storage["_" .. dataGroup] = data
        else
            -- file is corrupted. Creating a new one
            storage["_" .. dataGroup] = (returnNilIfNotExist and nil) or { }
        end
        
      --print("Loaded storage")
    else
      print("Couldn't load storage: " .. reason)
        storage["_" .. dataGroup] = { }
    end
    if fh then
        fh:close()
    end
    return storage["_" .. dataGroup]
end




------------------------------------------
------ PUBLIC FUNCTIONS

-- storage a value in memory and disk. You can also erasing a datagroup or key passing nil.
function storage.set(dataGroup, key, value)
    --print("storega.set=", dataGroup, key, value)
    --_G.mark("storage.set - ")
    --pt(storage["_" .. dataGroup], 'storage["_" .. dataGroup]==')
    if (value == nil) and key and type(key) == "table" then -- user wants to save an entire table or remove a key
        storage["_" .. dataGroup] = key        
    else
        
        --print("value was filled with " .. value)
        local data = storage["_" .. dataGroup] or {}    
         
        data[key] = value  -- sets/updates the key entry with value
        storage["_" .. dataGroup] = data
        
    end

    -- saving the update date to a file
    writeToFile(dataGroup)
    --_G.mark("storage.set finished")
end


-- returns the value of the key index in dataGroup and also loads the dataGroup table in the storage._dataGroup variable
function storage.get(dataGroup, key, returnNilIfNotExist)
    --print("storage.get(", dataGroup, ", ", key, ")")
    
    local data = storage["_" .. dataGroup]

    if data == nil then -- data is not in memory, try to read from file
        data = readFile(dataGroup, false, returnNilIfNotExist)        
    end

    if data == nil then -- handle cases where the contents of the file was erased
        return nil
    end

    if (key == nil) then
        return data
    else
        return data[key]

    end
end




storage.cryptoKey = storage.cryptoKey .. "Y7K3pQm8FmKMhKED"


return storage
