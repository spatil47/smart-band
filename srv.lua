srv=net.createServer(net.TCP)
srv:listen(8000,function(conn)
  conn:on("receive",function(conn,payload)
    print(payload)
    local buf = "HTTP/1.1 200 OK\r\n"
    buf = buf.."Content-Type: text/html; charset=utf-8\r\n\r\n"
    buf = buf.."<html><head><title>SPS Web Interface</title></head><body>"
    buf = buf.."<button onClick=\"show()\">IP address</button><br><br>"
    buf = buf.."<span id='ip' style='visibility:hidden;font-family:monospace'>"
    buf = buf..wifi.sta.getip()
    buf = buf.."</span>"
    buf = buf.."<script>function show() { document.getElementById('ip').style.visibility = 'visible'; }</script>"
    buf = buf.."</body></html>"
    conn:send(buf)
  end)
  conn:on("sent",function(conn) conn:close() end)
end)