local json = require('json')
local curl = require('lcurl')

local helper = {}

-- sleep for few seconds
function helper.sleep(second)
    usleep(second*1000000)
end

-- notif text message for few second
function helper.notif(text, second)
    second = second or 3  
    toast(text, second)
    log(text)
end


-- find image at 0.8 precision
function helper.search_image(path, precision) 
    if not precision then precision = 0.7 end 
    local result = findImage(path, nil, precision)
    for i, v in pairs(result) do
        log(string.format("Found image:%s at: x:%f, y:%f",path , v[1], v[2]));
        if v[1] then 
            return v[1], v[2]
        end 
    end
    log(string.format("Image not found "..path));
    return nil, nil
end 

-- proxy_parser.lua
function helper.parse_proxy(_proxy)
    local host, port, user, pass = _proxy:match("([^:]+):([^:]+):([^:]*):([^:]*)")

    if user and pass and host and port then
        return string.format("%s:%s@%s:%s", user, pass, host, port)
    else
        -- Fallback for the case without username/password
        return _proxy
    end
end

-- perform Get request and return a table obj
function helper.GET(url)

    local response = ""

    -- HTTP Get using lcurl
    success, err_msg = pcall(function()
        curl.easy{
            url = url,
            writefunction = function(data)
                response = response .. data
                return #data
            end
        }
        :perform()
        :close()
    end)
    
    -- Parse the response as JSON using json library
    --h.notif(response)
    local task, err = json.decode(response)
    if not task then
        print("Error parsing JSON: ".. err)
        return nil
    else
        return task
    end
    
end 




-- Function to convert a table to a string
function helper.table_to_string(tbl, indent)
    if type(tbl) ~= "table" then
        return tostring(tbl)
    end

    indent = indent or 0
    local indent_str = string.rep("  ", indent)
    local result = "{\n"

    for key, value in pairs(tbl) do
        local key_str = type(key) == "string" and string.format("[\"%s\"]", key) or string.format("[%s]", tostring(key))
        
        if type(value) == "table" then
            result = result .. indent_str .. "  " .. key_str .. " = " .. table_to_string(value, indent + 1) .. ",\n"
        else
            result = result .. indent_str .. "  " .. key_str .. " = " .. tostring(value) .. ",\n"
        end
    end

    result = result .. indent_str .. "}"
    return result
end


-- simulate swapping horizontally
function helper.swipeHorizontally()
    for i = 1, 5 do
        touchDown(1, 900, 300)
        for x = 900, 100, -30 do
            usleep(8000)
            touchMove(1, x, 300)
        end
        touchUp(1, 100, 300)
        usleep(300000)
    end
end


-- simulate swapping vertically
function helper.swipeVertically()
    for i = 1, 5 do
        touchDown(1, 200, 300)
        for y = 300, 900, 30 do
            usleep(28000)
            touchMove(1, 200, y)
        end
        touchUp(1, 200, 900)
        usleep(300000)
    end
end

-- simulate swiping up
function helper.swipeUp()
    for i = 1, 1 do
        touchDown(1, 600, 900) -- Start the touch at the bottom
        for y = 600, 300, -20 do
            usleep(38000) -- Delay between touch movements
            touchMove(1, 200, y) -- Move the touch upward
        end
        touchUp(1, 200, 600) -- Lift the touch at the top
        usleep(300000) -- Wait before the next swipe
    end
end


return helper

-- local h = require("helper")
-- h.sleep(3)