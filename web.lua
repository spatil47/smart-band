-- Copyright (c) 2017 Siddharth Patil
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

target = "192.168.1.100"

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
