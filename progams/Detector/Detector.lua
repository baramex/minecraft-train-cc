os.loadAPI("Api.lua")
local detector = peripheral.wrap("top")
local beforeTag

if detector == nil then
    print("Périphérique manquant.")
    return
end

function detectStock()
    while true do
        if redstone.getInput("top") then
            if detector.getTag() ~= beforeTag then
                beforeTag = detector.getTag()  
                detectedStock()
            end
        end
        sleep(0.2)   
    end
end

function detectedStock()
    local stock = detector.info()
    local tag = stock.tag
    local apiStock = Api.request("/stock/" .. tag, "GET")
    if apiStock == nil then
        print("Unable to retrieve stock")
        return
    end
    local t = apiStock.readAll()
    apiStock = json.decode(apiStock.readAll())
    local train = Api.request("/stock/" .. tag .. "/train", "GET")
    if train == nil then
        print("Unable to retrieve train")
        return
    end
    train = train.readAll()
    print(t)
    print(train)
end

detectStock()
