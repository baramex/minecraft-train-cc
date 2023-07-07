os.loadAPI("json.lua")

local HOST = "http://localhost:8600"
local API_KEY = "4329414c-6c81-4dea-9080-aa6ee64766f4"

function request(endpoint, method, data)
    local url = HOST .. endpoint
    local headers = {
        Authorization = "Basic " .. API_KEY,
        ["Content-Type"] = "application/json"
    }
    local response
    if method == "GET" then
        response = http.get(url, headers)
    else
        response = http.post(url, json.encode(data), headers)
    end

    return response
end
