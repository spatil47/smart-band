udpSocket = net.createUDPSocket()
udpSocket:listen(5000)
udpSocket:on("receive", function(s, data, port, ip)
    print(string.format("received"))
    if(data=="on") then
        cmd = file.open("Smart_outlet_on.dat", "r")
        s:send(80, "192.168.1.100", cmd:read())
        cmd.close()
    elseif(data=="off") then
        cmd = file.open("Smart_outlet_off.dat", "r")
        s:send(80, "192.168.1.100", cmd:read())
        cmd.close()
    end
end)
port, ip = udpSocket:getaddr()
print(string.format("local UDP socket address / port: %s:%d", ip, port))
