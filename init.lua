function wait_wifi()
  local wifi_ip = wifi.sta.getip() -- get your ESP's IP address
  if wifi_ip ~= "192.168.1.91" then --enter your ESP's IP address
    tmr.alarm(0, 2000,1,wait_wifi) -- will recall wait_wifi function every 2 sec (2000 ms)
  else
    print("Got IP "..wifi_ip.."\n")
    print("CONNECTED \n")
    tmr.stop(0) -- stop the timer
    dofile("main.lua") -- call our main.lua file
  end
end

print("Starting init.lua... \n") -- print to your serial terminal (for debugging)
wifi.setmode(wifi.STATION) -- set the module in STATION mode
wifi.sta.config("OpenROV","openadventure")
wifi.sta.autoconnect(1)
wait_wifi()

