local TRAIN_HASHES = {
    -1719006020 -- PASSENGER AND CARGO TRAIN [Carts - 10] -- [This one is pretty fast too]
}

CURRENT_TRAIN = nil

local stops = {
	{["distance"] = 15.0, ["x"] = 2768.62, ["y"] = -1417.07,["z"] = 46.00,  ["time"] = 60000, ["name"] = "Saint Denis Station"},
	{["distance"] = 15.0, ["x"] = 1268.25, ["y"] = -1349.71,["z"] = 76.42,  ["time"] = 60000, ["name"] = "Rhodes Station"},
	{["distance"] = 15.0, ["x"] = -358.08, ["y"] = -358.55, ["z"] = 87.28,  ["time"] = 30000, ["name"] = "Flatneck Station"},
	{["distance"] = 15.0, ["x"] = -1112.55,["y"] = -571.94, ["z"] = 82.36,  ["time"] = 30000, ["name"] = "Riggs Station"},
	{["distance"] = 15.0, ["x"] = -1311.3, ["y"] = 401.38,  ["z"] = 95.75,  ["time"] = 30000, ["name"] = "Wallace Station"},
	{["distance"] = 15.0, ["x"] = 610.54,  ["y"] = 1661.53, ["z"] = 188.0,  ["time"] = 30000, ["name"] = "Bacchus Station"},
	{["distance"] = 15.0, ["x"] = 2971.43, ["y"] = 1321.43, ["z"] = 44.26,  ["time"] = 60000, ["name"] = "Anusburg Station"},
	{["distance"] = 15.0, ["x"] = 2905.30, ["y"] = 683.17,  ["z"] = 57.73,  ["time"] = 60000, ["name"] = "Van Horn Tradin Post"},
	{["distance"] = 15.0, ["x"] = -174.73, ["y"] = 611.82,  ["z"] = 113.51, ["time"] = 60000, ["name"] = "Valentine Station"}
}

local trainspawned = false
local onstartup = true

Citizen.CreateThread(function()
    while onstartup == true do
        TriggerEvent('Trainroute')
        print("This train doesnt want to spawn.. bug somewhere..")
        Wait(5000)
        TriggerEvent('Trainroute')
        print("This train spawned just right outside Valentine, But it wont return back to Valentine. It loops around the map")
        onstartup = false
    end
end)

RegisterNetEvent('Trainroute')
AddEventHandler('Trainroute', function(n)

    --this is requestmodel--
    local n = math.random(#TRAIN_HASHES)
    local trainHash = TRAIN_HASHES[n]
    local trainWagons = N_0x635423d55ca84fc8(trainHash)
    for wagonIndex = 0, trainWagons - 1 do
    	DeleteAllTrains()
    	SetRandomTrains(false)
        local trainWagonModel = N_0x8df5f6a19f99f0d5(trainHash, wagonIndex)
        RequestModel(trainWagonModel, 1)
        --Citizen.InvokeNative(0xFA28FE3A6246FC30, trainWagonModel) -- This is requestModel only in hash
    end

    
    local ped = PlayerPedId()
    local train = N_0xc239dbd9a57d2a71(trainHash, 48.70, 16.49, 102.56, 0, 0, 1, 1)
    local coords = GetEntityCoords(train)
    local trainV = vector3(coords.x, coords.y, coords.z)
    local stopspeed = 0.0
    local cruisespeed = 14.0

    --blip--
    local blipname = "Train"
    local bliphash = -399496385
    local blip = Citizen.InvokeNative(0x23f74c2fda6e7c61, bliphash, train) -- BLIPADDFORENTITY
    SetBlipScale(blip, 1.5)
    --SetBlipNameFromPlayerString(blip, blipname)
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, blipname)

    --spawn--
    SetMissionTrainCoords(train, 48.70, 16.49, 102.56)
    SetMissionTrainAsNoLongerNeeded(train)
    SetTrainSpeed(train, stopspeed)
    SetTrainCruiseSpeed(train, cruisespeed)
    trainspawned = true
    CURRENT_TRAIN = train


    while trainspawned == true do --this is the loop for the train to stop at stations
    	for i = 1, #stops do
    		local coords = GetEntityCoords(CURRENT_TRAIN)
    		local trainV = vector3(coords.x, coords.y, coords.z)
    		local distance = #(vector3(stops[i]["x"], stops[i]["y"], stops[i]["z"]) - trainV)
            local tracknode = GetTrainCurrentTrackNode(CURRENT_TRAIN)
    		if distance < stops[i]["distance"] then
    			SetTrainCruiseSpeed(train, stopspeed)
    			Wait(stops[i]["time"])
    			SetTrainCruiseSpeed(train, cruisespeed)
    		elseif distance > stops[i]["distance"] then
    			SetTrainCruiseSpeed(train, cruisespeed)
    			Wait(50)
    		end
    	end
    end
end)
