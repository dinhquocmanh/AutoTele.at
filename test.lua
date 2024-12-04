local json = require('json')
local curl = require('lcurl')
local h = require("helper")

-- define some variables
local package_name = "ph.telegra.Telegraph"
local host_address = "http://192.168.1.70:5003"
local package_shadow = "com.liguangming.Shadowrocket"
local vpn_command = "activator send switch-off.com.a3tweaks.switch.vpn"
TASK = nil 

-- sleep for few seconds
function sleep(second)
    usleep(second*1000000)
end

-- notif text message for few second
function notif(text, second)
    second = second or 3  
    toast(text, second)
end

-- get atomic state
function get_atomic()
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
        return content
    else
        print("File not found!")
    end

end

--get_atomic()

-- local ip = getLocalIP();
-- --alert(ip)
-- local dir = currentDir();
-- log(dir);



-- change proxy by shadowrocket
function change_proxy2()
    h.notif("2. Change proxy..")
    openURL("shadowrocket://disconnect")
    h.sleep(5)
    tap(662,639) -- click info icon
    h.sleep(1)
    tap(703,542) -- click in the end line
    h.sleep(1)
    inputText("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"); -- delete username
    h.sleep(1)
    inputText("\b\b\b\b\b\b\b\b\b\b"); -- delete username
    h.sleep(1)
    inputText("\b\b\b\b\b\b\b\b\b\b"); -- delete username
    h.sleep(1)
    math.randomseed(os.time());
    local randomNumber = math.random(1, 4900)
    inputText("quocmanh-IN-"..randomNumber) -- enter new username
    h.sleep(1)
    tap(669,82) -- click done
    h.sleep(1)
    openURL("shadowrocket://connect")
    h.sleep(5)
    appKill("com.liguangming.Shadowrocket")

    -- verify change proxy
    curl.easy{
        url = 'http://ip-api.com/json',
        httpheader = {
            "Content-Type: application/json"
        },
        writefunction = h.notif -- use io.stderr:write()
    }
    :perform()
    :close()
    h.sleep(1)
end 

-- local x,y = search_image('Screenshots/activation-code.PNG')
-- h.sleep(3)

-- if x then 
--     tap(x,y)
-- else
--     log("Not found image")
-- end 
mime = require("mime")

function change_proxy(_proxy)
    local proxy = h.parse_proxy(_proxy)
    local b64 = "socks://"..mime.b64(proxy)
    --copyText(b64) 
    openURL("shadowrocket://disconnect")
    h.sleep(1)
    openURL("shadowrocket://add/"..b64)
    h.sleep(20)
    tap(358,629) -- click the first line proxy
    h.sleep(1)
    openURL("shadowrocket://connect")
    h.sleep(5)
    appKill("com.liguangming.Shadowrocket")
end 
-- appKill("group.ph.telegra.Telegraph")
-- appKill("com.shadowtech.ShadowHelper")

appKill("com.liguangming.Shadowrocket")
local _proxy = "p.webshare.io:80:quocmanh-ID-IN-MY-123:quocmanh"
local proxy = 'user:pass@p.webshare.io:20421'
-- change_proxy(_proxy)
-- h.sleep(5)
-- data = h.safe_request_get("http://ip-api.com/json")
-- print(tostring(data))
-- h.notif(tostring(data))

-- Example usage
-- local _proxy1 = "p.webshare.io:20421:user:pass"
-- local proxy1 = parse_proxy(_proxy1)
-- print(proxy1) -- Output: user:pass@p.webshare.io:20421
-- h.notif(proxy1)
-- local _proxy2 = "p.webshare.io:20421"
-- local proxy2 = parse_proxy(_proxy2)
-- print(proxy2) -- Output: p.webshare.io:20421
--h.notif(proxy2)

-- change proxy by shadowrocket
function change_proxy()
    h.notif("2. Change proxy..")
    
    -- get old proxy
    response = h.GET('http://ip-api.com/json')
    local old_ip = response['query']

    -- get new proxy
    response = h.GET(host_address..'/get_proxy')
    local _proxy = response['proxy']
    notif(_proxy)
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
    response = h.GET('http://ip-api.com/json')
    local new_ip = response['query']
    local new_country = response['country']
    notif(string.format("===PROXY===\nOld IP: %s\nNew IP: %s\nCountry: %s", old_ip,new_ip,new_country),6)
end 

-- local color = getColor(129, 1100) -- 16743168
-- alert(string.format("Pixel color is :%d", color))

-- simulate swapping horizontally
function swipeHorizontally()
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
function swipeVertically()
    for i = 1, 5 do
        touchDown(1, 200, 300)
        for y = 300, 900, 30 do
            usleep(8000)
            touchMove(1, 200, y)
        end
        touchUp(1, 200, 900)
        usleep(300000)
    end
end


function complete_register()
    h.notif("7. Complete Register..")

    tap(619, 1273) -- click settings
    h.sleep(1)
    tap(619, 1273) -- click settings
    h.sleep(1)
    
    h.swipeUp() -- swipe up
    h.sleep(5) 

    -- click privacy and security
    local x,y = h.search_image('Screenshots/privacy-security.PNG',0.2)
    if x then 
        tap(x, y)
        h.sleep(3)
    end 
    tap(366, 400) -- click two step
    h.sleep(3)
    tap(366, 1163) -- click set additional password
    h.sleep(3)
    inputText("8886666") -- enter password
    h.sleep(3)
    tap(366, 657) -- click retype
    h.sleep(1)
    inputText("8886666")
    h.sleep(3)
    tap(366, 788) -- click create password
    h.sleep(3)
    inputText("86") -- input hint
    h.sleep(3)
    tap(366, 783) -- click continue
    h.sleep(3)
    inputText("thanhlong998@shopmmo.store") -- input recovery email
    h.sleep(3)
    tap(366, 783) -- click continue
    h.sleep(10)

    -- Check email sent
    local x,y = h.search_image('Screenshots/recovery-email.PNG')
    if x then 
        tap(366, 858)
        h.sleep(3)
    end 
    
    -- TODO GET CODE
    inputText("123456") -- input code
    h.sleep(16)

    -- verify
    local x,y = h.search_image('Screenshots/password-set.PNG')
    if x then 
        h.notif("Set 2fa Success")
        return true
    else 
        h.notif("Set 2fa Failed")
        return false
    end 
end

complete_register()