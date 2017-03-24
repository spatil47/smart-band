gpio.mode(1,gpio.INT,gpio.PULLUP)

gpio.trig(1,"both",function(level,when)
    print(level);
end)
