------------------------------------------
-- Red Beach Library                    
-- Library: Queue                   
-- v 0.02                               
--                  
-- 
-- Dependencies:                        
--  . none                              
------------------------------------------
------------------------------------------
--
--
--
--
--


local queue = {}
queue.type = "lifo"   -- types: "fifo" = First-In, First-Out ; "lifo" = Last-in First-Out. Using "lifo" as default

-- defining the indexes
queue.first = 1
queue.last = 0
    
-- creating the table that will hold the data
queue.data = {}




---------------------------------
-- PRIVATE FUNCTIONS
--------------------------------- 

-- inserts a new data at the Bottom
function queue.pushBottom (value)
    local first = queue.first - 1
    queue.first = first
    queue.data[first] = value
end

-- inserts a new data at the Top
function queue.pushTop (value)
    local last = queue.last + 1
    queue.last = last
    queue.data[last] = value
end

-- gets and removes a data from the Bottom
function queue.popBottom ()
    local first = queue.first
    if first > queue.last then 
        print("list is empty") 
    end
    local value = queue.data[first]
    queue.data[first] = nil        -- to allow garbage collection
    queue.first = first + 1
    return value
end


-- gets and removes a data from the Top
function queue.popTop ()
    local last = queue.last
    if queue.first > last then 
        print("list is empty") 
    end
    local value = queue.data[last]
    queue.data[last] = nil         -- to allow garbage collection
    queue.last = last - 1
    return value
end


---------------------------------
-- PUBLIC FUNCTIONS
--------------------------------- 

-- inserts the new data in the queue
queue.push = function (value, forceInsertAtBottom)
    if forceInsertAtBottom then
        queue.pushBottom(value)
    else
        queue.pushTop(value)
    end
        
end
    
-- get a data from the queue and removes it from it. Obeys the type of queue to determine what data to return (first or last of the queue)
queue.pop = function()
    
    if queue.type == "fifo" then
        return queue.popBottom()
    else --if queue.type == "lifo" then
        return queue.popTop()        
    end
        
end

-- allows the user to set the type of queue)
queue.setType = function(queueType)
    if queueType == nil or queueType == "filo" or queueType == "stack" then
        queueType = "lifo"  -- "Last In First Out"
    elseif queueType ~= "fifo" and queueType ~= "lifo" then
        print "[Error] Queue type not recognized"
        return false
    end        
    
    queue.type = queueType        
    
end

-- returns the all data inside the queue
function queue.getData ()
    
   return queue.data
        
end

-- returns the last item inside the queue without removing it
function queue.getLastItem ()
    
   return queue.data[queue.last]
        
end

function queue.print ()
   local data = queue.data
   print("Printing Queue Data - #data=", (queue.last - queue.first + 1))
   for i=queue.first, queue.last do
       print("data["..i.."]=", data[i])
   end
           
end

function queue.clear()
    
    -- clear all itens
    for i=queue.first, queue.last do
        queue.data[i] = nil     
    end
    
    -- reset indexes
    queue.first = 1
    queue.last = 0
    
end


return queue


