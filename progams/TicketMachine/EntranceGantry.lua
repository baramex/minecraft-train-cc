os.loadAPI("json.lua")
os.loadAPI("Api.lua")

local env = json.decode(fs.open("env.txt", "r").readAll())

local station = env.station
local cardReader = peripheral.find("mag_card_reader")
local monitor = peripheral.find("monitor")

if cardReader == nil or monitor == nil then
    print("Périphérique(s) manquant(s).")
    return
end

function init()
    cardReader.lightGreen()

    monitor.clear()
    monitor.setTextColor(0x2000)
    monitor.setCursorPos(1, 1)
    monitor.write("Prêt à")
    monitor.setCursorPos(1, 2)
    monitor.write("scanner !")

    redstone.setOutput("top", false)
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

        local usage = Api.request("/user/" .. uuid .. "/use", "POST", {
            station = station
        })
        if usage == nil then
            cardReader.lightRed()
            monitor.clear()
            monitor.setCursorPos(1, 1)
            monitor.setTextColor(0x4000)
            monitor.write("Vous n'")
            monitor.setCursorPos(1, 2)
            monitor.write("avez")
            monitor.setCursorPos(1, 3)
            monitor.write("plus de")
            monitor.setCursorPos(1, 4)
            monitor.write("tickets !")

            sleep(3)

            init()
            return magReader()
        end

        local remaining = #(json.decode(usage.readAll()).remainingUsages)

        cardReader.lightGreen()
        monitor.clear()
        monitor.setCursorPos(1, 1)
        monitor.setTextColor(0x800)
        monitor.write("Entrez!")
        monitor.setCursorPos(1, 2)
        monitor.write("Il vous")
        monitor.setCursorPos(1, 3)
        monitor.write("reste")
        monitor.setCursorPos(1, 4)
        monitor.write(tostring(remaining))
        monitor.setCursorPos(1, 5)
        monitor.write("tickets.")
        redstone.setOutput("top", true)

        while redstone.getInput("back") ~= true do
            sleep(.15)
        end

        init()
    end
end

init()
magReader()
