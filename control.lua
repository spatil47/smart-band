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

svr:close()

target = "192.168.1.100"

if file.open("threshold", "r") then
    threshold = tonumber(file.read())
    file.close()
end

pulse_count = 0;
first_timestamp = 0;
pulse_rate_bpm = 0;

gpio.mode(1,gpio.INT,gpio.PULLUP)
gpio.mode(12,gpio.INT,gpio.PULLUP)

udpSocket = net.createUDPSocket()
udpSocket:listen(5000)

gpio.trig(1,"down",function(pulse_level,current_timestamp)
    if pulse_count == 0 then
        pulse_count = 1
        first_timestamp = current_timestamp
    elseif pulse_count == 3 then
        current_pulse_rate_bpm = (pulse_count*60*1000000*0.5) / (current_timestamp - first_timestamp);
        if (current_pulse_rate_bpm >= 48) and (current_pulse_rate_bpm <= 180) then
            if pulse_rate_bpm == 0 then
                pulse_rate_bpm = current_pulse_rate_bpm
            else
                pulse_rate_bpm = (pulse_rate_bpm + current_pulse_rate_bpm) / 2
            end
        end
        print("Pulse rate (BPM): " .. pulse_rate_bpm)
        if pulse_rate_bpm > threshold then
            print("Smart outlet on")
            cmd = file.open("Smart_outlet_on.dat", "r")
            udpSocket:send(80, target, cmd:read())
            cmd.close()
        else
            print("Smart outlet off")
            cmd = file.open("Smart_outlet_off.dat", "r")
            udpSocket:send(80, target, cmd:read())
            cmd.close()
        end
        pulse_count = 0
    else
        pulse_count = pulse_count + 1;
    end
    print("pulse: " .. pulse_count)
end)

gpio.trig(12,"down",function()
    print("off")
    pulse_count = 0
    cmd = file.open("Smart_outlet_off.dat", "r")
    udpSocket:send(80, target, cmd:read())
    cmd.close()
end)
