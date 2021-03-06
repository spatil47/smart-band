-- Simple NodeMCU web server (done is a not so nodeie fashion :-)
-- (http://robotshop.com/letsmakerobots/nodemcu-esp8266-simple-httpd-web-server-example)
--
-- Written by Scott Beasley 2015
-- Open and free to change and use. Enjoy.
--
-- Modifications copyright (c) 2017 Siddharth Patil
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

local function connect (conn, data)
   local query_data

   conn:on ("receive",
      function (cn, req_data)
         query_data = get_http_req (req_data)
         print (query_data["METHOD"] .. " " .. " " .. query_data["User-Agent"])
         if(query_data["REQUEST"]["threshold"] == nil) then
            srv = file.open("index.html", "r")
            cn:send ("HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n")
            cn:send (srv:read())
            srv:close()
         elseif((tonumber(query_data["REQUEST"]["threshold"]) <= 48) or (tonumber(query_data["REQUEST"]["threshold"]) >= 180)) then
            srv = file.open("error.html", "r")
            cn:send ("HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n")
            cn:send (srv:read())
            srv:close()
         else
            set = file.open("threshold", "w+")
            set:write(query_data["REQUEST"]["threshold"])
            cn:send ("HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n")
            cn:send ("<html><head><title>Smart band Web interface</title>")
            cn:send ("</head><body><h1>Smart band Web interface</h1>")
            cn:send ("<p>Setting has been submitted.</p>")
            cn:send ("<p>Entered value: " .. query_data["REQUEST"]["threshold"] .. "</p>")
            cn:send ("<p>You may close this page now.</p>")
            cn:send ("</body></html>")
            set:close()
            dofile("control.lua")
         end
      end)
   conn:on ("sent",
      function(cn)
         cn:close ( )
      end)
end

function wait_for_wifi_conn ( )
   tmr.alarm (1, 1000, 1, function ( )
      if wifi.sta.getip ( ) == nil then
         print ("Waiting for Wifi connection")
      else
         tmr.stop (1)
         print ("ESP8266 mode is: " .. wifi.getmode ( ))
         print ("The module MAC address is: " .. wifi.ap.getmac ( ))
         print ("Config done, IP is " .. wifi.sta.getip ( ))
      end
   end)
end

-- Build and return a table of the http request data
function get_http_req (instr)
   local t = {}
   local first = nil
   local key, v, strt_ndx, end_ndx
   local rk, rv

   for str in string.gmatch (instr, "([^\n]+)") do
      -- First line in the method and path
      if (first == nil) then
         first = 1
         strt_ndx, end_ndx = string.find (str, "([^ ]+)")
         v = trim (string.sub (str, end_ndx + 2))
         key = trim (string.sub (str, strt_ndx, end_ndx))
         t["METHOD"] = key
         t["REQUEST"] = {}
         if (v ~= nil) then
            for rk, rv in string.gmatch (v, "(%w+)=(%w+)&*") do
                t["REQUEST"][rk] = rv
            end
         end
      else -- Process and reamaining ":" fields
         strt_ndx, end_ndx = string.find (str, "([^:]+)")
         if (end_ndx ~= nil) then
            v = trim (string.sub (str, end_ndx + 2))
            key = trim (string.sub (str, strt_ndx, end_ndx))
            t[key] = v
         end
      end
   end

   return t
end

-- String trim left and right
function trim (s)
  return (s:gsub ("^%s*(.-)%s*$", "%1"))
end

-- Hang out until we get a wifi connection before the httpd server is started.
wait_for_wifi_conn ( )

-- Create the httpd server
svr = net.createServer (net.TCP, 30)

-- Server listening on port 80, call connect function if a request is received
svr:listen (8000, connect)
