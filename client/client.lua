local TRAIN_HASHES = {
    -1719006020 -- PASSENGER AND CARGO TRAIN [Carts - 10] -- [This one is pretty fast too]
}

CURRENT_TRAIN = nil

local stops = {
    {["dst"] = 180.0, ["dst2"] = 3.0, ["x"] = -142.67, ["y"] = 654.18,  ["z"] = 113.52, ["time"] = 60000, ["name"] = "Valentine Station"},
    {["dst"] = 180.0, ["dst2"] = 3.0, ["x"] = 2768.62, ["y"] = -1417.07,["z"] = 46.00,  ["time"] = 60000, ["name"] = "Saint Denis Station"},
    {["dst"] = 180.0, ["dst2"] = 3.0, ["x"] = 1268.25, ["y"] = -1349.71,["z"] = 76.42,  ["time"] = 60000, ["name"] = "Rhodes Station"},
    {["dst"] = 180.0, ["dst2"] = 3.0, ["x"] = -358.08, ["y"] = -358.55, ["z"] = 87.28,  ["time"] = 30000, ["name"] = "Flatneck Station"},
    {["dst"] = 180.0, ["dst2"] = 3.0, ["x"] = -1112.55,["y"] = -571.94, ["z"] = 82.36,  ["time"] = 30000, ["name"] = "Riggs Station"},
    {["dst"] = 180.0, ["dst2"] = 3.0, ["x"] = -1311.3, ["y"] = 401.38,  ["z"] = 95.75,  ["time"] = 30000, ["name"] = "Wallace Station"},
    {["dst"] = 180.0, ["dst2"] = 3.0, ["x"] = 610.54,  ["y"] = 1661.53, ["z"] = 188.0,  ["time"] = 30000, ["name"] = "Bacchus Station"},
    {["dst"] = 180.0, ["dst2"] = 3.0, ["x"] = 2971.43, ["y"] = 1321.43, ["z"] = 44.26,  ["time"] = 60000, ["name"] = "Anusburg Station"},
    {["dst"] = 180.0, ["dst2"] = 3.0, ["x"] = 2905.30, ["y"] = 683.17,  ["z"] = 57.73,  ["time"] = 60000, ["name"] = "Van Horn Tradin Post"}
}

local trainspawned = false
local onstartup = true

Citizen.CreateThread(function()
    while onstartup == true do
        TriggerEvent('Trainroute')
        Wait(5000)
        onstartup = false
    end
end)

RegisterNetEvent('Trainroute')
AddEventHandler('Trainroute', function(n)
    DeleteAllTrains()
    SetRandomTrains(false) 

        --this is requestmodel--
    local n = math.random(#TRAIN_HASHES)
    local trainHash = TRAIN_HASHES[n]
    local trainWagons = N_0x635423d55ca84fc8(trainHash)
    for wagonIndex = 0, trainWagons - 1 do
        local trainWagonModel = N_0x8df5f6a19f99f0d5(trainHash, wagonIndex)
        while not HasModelLoaded(trainWagonModel) do
            Citizen.InvokeNative(0xFA28FE3A6246FC30,trainWagonModel,1)
            Citizen.Wait(100)
        end
    end
    --spawn--
    local ped = PlayerPedId()
    local train = N_0xc239dbd9a57d2a71(trainHash, 48.70, 16.49, 102.56, 0, 0, 1, 1)
    local coords = GetEntityCoords(train)
    local trainV = vector3(coords.x, coords.y, coords.z)
    --Citizen.InvokeNative(0xBA8818212633500A, train, 0, 1) -- this makes the train undrivable for players
         
    --blip--
    local blipname = "Train"
    local bliphash = -399496385
    local blip = Citizen.InvokeNative(0x23f74c2fda6e7c61, bliphash, train) -- BLIPADDFORENTITY
    SetBlipScale(blip, 1.5)
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, blipname) -- SetBlipNameFromPlayerString
    trainspawned = true
    CURRENT_TRAIN = train
    trainroute()
end)


function trainroute()
    while trainspawned == true do --this is the loop for the train to stop at stations
        for i = 1, #stops do
            local coords = GetEntityCoords(CURRENT_TRAIN)
            local trainV = vector3(coords.x, coords.y, coords.z)
            local distance = #(vector3(stops[i]["x"], stops[i]["y"], stops[i]["z"]) - trainV)
    
            --speed--
            local stopspeed = 0.0
            local cruisespeed = 5.0
            local fullspeed = 15.0
            if distance < stops[i]["dst"] then
                SetTrainCruiseSpeed(CURRENT_TRAIN, cruisespeed)
                Wait(200)
                if distance < stops[i]["dst2"] then
                    SetTrainCruiseSpeed(CURRENT_TRAIN, stopspeed)
                    Wait(stops[i]["time"])
                    SetTrainCruiseSpeed(CURRENT_TRAIN, cruisespeed)
                    Wait(10000)
                end
            elseif distance > stops[i]["dst"] then
                SetTrainCruiseSpeed(CURRENT_TRAIN, fullspeed)
                Wait(25)
            end
        end
    end
end
