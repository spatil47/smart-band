-- Starts the enduser_setup Web interface.
enduser_setup.start(
  function()
    dofile("web.lua")
  end,
  function(err, str)
    print("enduser_setup: Err #" .. err .. ": " .. str)
  end,
  print -- Lua print function can serve as the debug callback
);

