local host, port = "127.0.0.1", 8010
local socket = require("socket")
local tcp = assert(socket.tcp())

tcp:connect(host, port)
--note the newline below
tcp:send(arg[1].."\n")

while true do
    local s, status, partial = tcp:receive()
    io.write(s or partial)
    if status == "closed" then break end
end
tcp:close()
print()
