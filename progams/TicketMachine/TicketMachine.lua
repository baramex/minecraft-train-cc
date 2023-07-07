os.loadAPI("json.lua")
os.loadAPI("Api.lua")

local env = json.decode(fs.open("env.txt", "r").readAll())

local station = env.station
local cardReader = peripheral.find("mag_card_reader")
local monitor = peripheral.find("monitor")

local publicChest = peripheral.find("minecraft:barrel")
local privateChest = peripheral.find("minecraft:chest")

local credits = 0

if cardReader == nil or monitor == nil or publicChest == nil or privateChest == nil then
    print("Périphérique(s) manquant(s).")
    return
end

function init()
    cardReader.lightGreen()

    monitor.clear()
    monitor.setTextScale(.9)
    monitor.setTextColor(0x1)
    monitor.setCursorPos(1, 1)
    monitor.write("3$ = 1 ticket")
    monitor.setCursorPos(1, 2)
    monitor.write("1$/5$ acceptés")
    monitor.setCursorPos(1, 4)
    monitor.write("Crédits: " .. credits .. "$")
    monitor.setCursorPos(1, 5)
    monitor.setTextColor(0x2)
    monitor.write("= " .. math.floor(credits / 3) .. " tickets")
    monitor.setCursorPos(1, 7)
    monitor.setTextColor(0x1)
    monitor.write("Scannez pour")
    monitor.setCursorPos(1, 8)
    monitor.write("valider/voir le")
    monitor.setCursorPos(1, 9)
    monitor.write("solde !")
end

function magReader()
    while true do
        local event, side, uuid, data = os.pullEvent("mag_swipe")

        cardReader.lightYellow()
        monitor.clear()
        monitor.setCursorPos(1, 1)
        monitor.setTextColor(0x2)
        monitor.write("Scan...")

        local user = Api.request("/user/" .. uuid, "GET")
        if user == nil then
            user = Api.request("/user", "POST", {
                cardId = uuid
            })
            if user == nil then
                print("Unable to create user")
                init()
                return magReader()
            end
        end

        local tickets = math.floor(credits / 3)

        if tickets > 0 then
            credits = credits - tickets * 3
            Api.request("/user/" .. uuid .. "/purchase", "POST", {
                count = tickets
            })

            cardReader.lightGreen()
            monitor.clear()
            monitor.setTextScale(.9)
            monitor.setCursorPos(1, 1)
            monitor.setTextColor(0x2000)
            monitor.write(tickets .. " ticket(s)")
            monitor.setCursorPos(1, 2)
            monitor.write("ajouté(s):")
            monitor.setCursorPos(1, 3)
            monitor.write(tostring(#(json.decode(user.readAll()).remainingUsages) + tickets) .. " tickets !")

            sleep(3)
        else
            cardReader.lightGreen()
            monitor.clear()
            monitor.setTextScale(1)
            monitor.setCursorPos(1, 1)
            monitor.setTextColor(0x2000)
            monitor.write("Vous")
            monitor.setCursorPos(1, 2)
            monitor.write("avez")
            monitor.setCursorPos(1, 3)
            monitor.write(tostring(#(json.decode(user.readAll()).remainingUsages)))
            monitor.setCursorPos(1, 4)
            monitor.write("tickets !")

            sleep(3)
        end
        init()
    end
end

function moneyCounter()
    while true do
        items = publicChest.list()
        local c = 0
        for slot, item in pairs(items) do
            if item.name == "economyinc:item_oneb" then
                local count = publicChest.pushItems(peripheral.getName(privateChest), slot)
                c = c + 1 * count
            end
            if item.name == "economyinc:item_fiveb" then
                local count = publicChest.pushItems(peripheral.getName(privateChest), slot)
                c = c + 5 * count
            end
        end
        credits = credits + c
        if c > 0 then init() end
        sleep(.5)
    end
end

init()
parallel.waitForAll(magReader, moneyCounter)
