local json = require('json')
local curl = require('lcurl')
local h = require('helper')
mime = require("mime")

-- define some variables
local package_name = "ph.telegra.Telegraph"
local host_address = "http://192.168.1.70:5003"
local package_shadow = "com.liguangming.Shadowrocket"
local vpn_command = "activator send switch-off.com.a3tweaks.switch.vpn"
local SCAN_MODE = false
-- define the task which is running
TASK = nil 
public_ip = {}

-- Get new task from server
function get_task()
    h.notif("4. Get task..")
    url = host_address .. '/generate_task'
    response = h.GET(url)
    h.notif(string.format("Task ID: %s\nPhone Number: %s",response['task_id'],response['user']['phone_number']),6)
    return response 
end

-- Get code from server by task id
function get_code()
    h.notif("x. Get code..")
    url = host_address .. '/get_code_sms?task_id='..TASK.task_id
    response = h.GET(url)
    return response 
end



-- change proxy by shadowrocket
function change_proxy()
    h.notif("1. Change proxy..")
    
    -- get old proxy
    response = h.GET('http://ip-api.com/json')
    local old_ip = response['query']

    -- get new proxy
    response = h.GET(host_address..'/get_proxy')
    local _proxy = response['proxy']
    h.notif(_proxy)
    local proxy = h.parse_proxy(_proxy)
    local b64 = "socks://"..mime.b64(proxy)
    
    -- change proxy
    openURL("shadowrocket://disconnect")
    h.sleep(1)
    openURL("shadowrocket://add/"..b64)
    h.sleep(20)
    tap(358,629) -- click the first line proxy
    h.sleep(1)
    openURL("shadowrocket://connect")
    h.sleep(5)
    appKill("com.liguangming.Shadowrocket")

    -- verify change proxy
    public_ip = h.GET('http://ip-api.com/json')
    public_ip['proxy'] = _proxy
    local new_ip = public_ip['query']
    local new_country = public_ip['country']
    message = string.format("-----PROXY-----\nOld IP: %s\nNew IP: %s\nCountry: %s", old_ip,new_ip,new_country)
    h.notif(message,6)
    return message
end 


-- reset device information
function reset_device()
    h.notif("3. Reset Device..")
    -- openURL("shadowios://wipeapp")
    -- h.sleep(10)
    openURL("shadowios://reset")
    h.sleep(5)

    -- sleep until the app closed
    for i=1,20 do 
        local state = appState("com.shadowtech.ShadowHelper");
        if state == "ACTIVATED" then 
            h.sleep(5)
        else
            break
        end   
    end 
    h.sleep(3)
end 

-- download telegram app from app store
function download_app()
    h.notif("4. Download App..")
    openURL("https://apps.apple.com/sg/app/telegram-messenger/id686449807")
    h.sleep(5)

    -- check download success for 100s
    for i=1,20 do 
        local appId = frontMostAppId();
        if appId == "ph.telegra.Telegraph" then 
            h.notif("Download success")
            return true;
        else
            h.sleep(5)
        end 
    end 

    h.notif("Download failed")
    return false;
end

--[[
Click continue and Enter phone
    Click continue
    Enter phone 
    Possible Cases:
        Phone banned
        Phone not valid
        Check Telegram Apps
        Code send to phone
]]
function enter_phone()
    h.notif("5. Enter Phone Number..")
    -- check color 
    local color = getColor(129, 1100) -- 16743168
    if color == 16743168 then 
        tap(371,1103)   -- tap start using
    else 
        tap(371,1229)   -- tap start using
    end 
    h.sleep(10)

    -- auto 
    inputText("\b\b\b\b\b"); -- delete +84
    h.sleep(1)
    inputText(TASK.user.phone_number)  -- enter phone number
    h.sleep(1)
    tap(374,806) -- click continue
    h.sleep(2)
    tap(376,830) -- click continue
    h.sleep(20)

    --[[
        Verify 
        these are 6 cases here
        - send sms 
        - receive sms. need click
        - enter email. more steps
        - telegram apps
        - your phone banned
        - no internet
    ]]
    -- case send sms success
    x,y = h.search_image('Screenshots/activation-code.PNG')
    if x then 
        h.notif("case 1. sms send to phone")
        TASK['status_sms'] = 'case 1. sms send to phone'
        return true;
    end 
    -- case send sms need click
    x,y = h.search_image('Screenshots/getcode-sms.PNG')
    if x then 
        h.notif("case 2. get code via sms")
        TASK['status_sms'] = 'case 2. get code via sms'
        tap(x,y)
        h.sleep(3)
        return true;
    end
    -- case 3 enter your email
    x,y = h.search_image('Screenshots/add-email2.PNG')
    if x then 
        h.notif("case 3. enter your email")
        TASK['status_sms'] = 'case 3. enter your email'
        return true;
    end

    -- case 0. register success
    x,y = h.search_image('Screenshots/search-bar.PNG')
    if x then 
        h.notif("case 0. register success")
        TASK['status_sms'] = 'case 0. register success'
        return true;
    end

    -- case 4. telegram apps
    x,y = h.search_image('Screenshots/telegram-app.PNG')
    if x then 
        h.notif("case 4. telegram apps")
        TASK['status_sms'] = 'case 4. telegram apps'
        return false;
    end
    -- case 5. your phone banned
    x,y = h.search_image('Screenshots/phone-banned.PNG')
    if x then 
        h.notif("case 5. your phone banned")
        TASK['status_sms'] = 'case 5. your phone banned'
        return false;
    end
    -- case 6. no internet
    x,y = h.search_image('Screenshots/check-internet.PNG')
    if x then 
        h.notif("case 6. no internet")
        TASK['status_sms'] = 'case 6. no internet'
        return false;
    end

    -- case 0. allow contact
    x,y = h.search_image('Screenshots/dont-allow.PNG')
    if x then 
        h.notif("case 0. allow contact")
        TASK['status_sms'] = 'case 0. register success'
        tap(x,y)
        h.sleep(3)
        return true;
    end

    -- case 7. unknown
    h.notif("case 7. unknown")
    TASK['status_sms'] = 'case 7. unknown'
    return false 
    
end

--[[
Get code from server and then enter code
    Possible Cases:
        Code not found
        Code not valid
]]
function enter_code()
    h.sleep(10)
    h.notif("6. Enter Code..")
    
    for i=1 , 10 do 
        h.notif("Get code #"..i)
        result = get_code()
        
        if result["error"] then
            print(result["error"])
            h.sleep(10)
        else
            code = result['success']
            TASK['status'] = "found code"
            log(code)
            inputText(code)
            h.sleep(5)
            return 1
        end
    end
end

--[[
Complete Register steps
Enter first name and last name
Check status register
To do:
    Add 2fa
    Add email
    Change username
]]
function complete_register()
    -- skip if not found code
    if TASK['status'] ~= "found code" then
        return 1
    end 
    h.notif("7. Complete Register..")

    inputText(TASK.user.first_name)
    h.sleep(3)
    tap(161,548)
    h.sleep(1)
    inputText(TASK.user.last_name)
    tap(379,723)
    h.sleep(5)
    appKill("ph.telegra.Telegraph")
    h.sleep(5)
    appRun("ph.telegra.Telegraph")
    h.sleep(5)
    -- we enter phone again an check
    enter_phone()

end

function enable_2fa()
    h.notif("8. Enable 2FA")
    h.sleep(3)
end 

-- Save RSS to file and post task to server
function save_data()
    if TASK['status'] ~= "found code" then
        return 1
    end 

    h.notif("8. Save Data RRS..")
    openURL('shadowios://backup?name=RRS_'..TASK.user.phone_number)
    h.sleep(15)
    h.notif("Success: RSS saved to RRS_"..TASK.user.phone_number)

end

-- get atomic state read file
function get_atomic()
    h.notif("9. Get atomic state..")
    local app_info = appInfo('ph.telegra.Telegraph')
    local app_group = app_info['groups']['group.ph.telegra.Telegraph']
    local atomic_path = app_group.."/telegram-data/accounts-metadata/atomic-state"
    local atomic_path = atomic_path:gsub("^file://", "")

    -- Open the file in read mode
    local file = io.open(atomic_path, "r")
    if file then
        local content = file:read("*all")
        file:close()
        print(content)
        TASK.atomic_state = content
        return content
    else
        print("File not found!")
    end

end

-- post task status to the server
function post_task(task)
    h.notif("10. Post task..")
    local response = ""

    -- Encode the task table into JSON
    local json_data = json.encode(TASK)

    -- HTTP POST request using lcurl
    curl.easy{
        url = host_address .. '/update_task',
        post = true,  -- Set the request type to POST
        httpheader = {
            "Content-Type: application/json"
        },
        postfields = json_data,  -- Add JSON encoded data to the POST body
        writefunction = function(data)
            response = response .. data  -- Accumulate response data
            return #data
        end
    }
    :perform()
    :close()

    -- Print or parse the response
    local response_data, err = json.decode(response)
    if not response_data then
        print("Error parsing response JSON: ".. err)
    else
        print("Server response: ".. response)
    end

    return response_data
end


-- Main funtion auto
index = 0
function main()
    appKill("ph.telegra.Telegraph")
    h.sleep(1)
    appKill("com.shadowtech.ShadowHelper")
    h.sleep(1)
    appKill("com.liguangming.Shadowrocket")
    h.sleep(3)
    
    -- Pharse 1: Preparing, Reset device, get necessary infor
    proxy_message = change_proxy()
    h.sleep(3)
    reset_device()
    h.sleep(3)
    local downloaded = download_app()
    h.sleep(3)
    -- if not download app success we return
    if not downloaded then
        return 0;
    end 
    
    -- get task from server
    TASK = get_task()
    TASK.client = getLocalIP()
    TASK.status = 'working'
    TASK.proxy = public_ip['proxy']
    h.sleep(3)

    -- Pharse 2: Auto actions
    has_sms = enter_phone()
    index = index + 1

    -- Scan mode 
    if SCAN_MODE then 
        h.notif(proxy_message,3)
        h.sleep(1)
        screenshot("Capture/screenshot_"..TASK['user']['phone_number']);
        post_task()
        h.sleep(3)
        return 
    end 

    -- we continue or not
    if not has_sms then
        return 
    end 
    
    enter_code()
    h.sleep(3)
    complete_register()
    h.sleep(3)
    enable_2fa()
    h.sleep(3)

    -- Phrase 3: Save and post data
    get_atomic()
    post_task()
    h.sleep(3)
    save_data()
    h.sleep(3)

    TASK = nil -- delete the task
end

-- Main Loop
while true do
    main()
    --stop(); -- run auto only 1 time
end