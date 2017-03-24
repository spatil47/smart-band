target = "192.168.43.118"

gpio.mode(1,gpio.INT,gpio.PULLUP)
gpio.mode(12,gpio.INT,gpio.PULLUP)

udpSocket = net.createUDPSocket()
udpSocket:listen(5000)

gpio.trig(1,"down",function(level,when)
    print("on")
    cmd = file.open("Smart_outlet_on.dat", "r")
    udpSocket:send(80, target, cmd:read())
    cmd.close()
end)

gpio.trig(12,"down",function(level,when)
    print("off")
    cmd = file.open("Smart_outlet_off.dat", "r")
    udpSocket:send(80, target, cmd:read())
    cmd.close()
end)

port, ip = udpSocket:getaddr()
print(string.format("local UDP socket address / port: %s:%d", ip, port))
