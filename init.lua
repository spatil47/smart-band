enduser_setup.start(
  function()
    print("Connected to wifi as:" .. wifi.sta.getip())
    dofile("srv.lua")
  end,
  function(err, str)
    print("enduser_setup: Err #" .. err .. ": " .. str)
  end,
  print -- Lua print function can serve as the debug callback
);

