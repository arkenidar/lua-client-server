-- sudo luarocks install luasocket
-- sudo apt install lua-socket
local socket=require("socket")

local server=assert(socket.bind("127.0.0.1",8010))
server:settimeout(0) -- for server:accept()

local ip,port=server:getsockname()
print("(rlwrap) nc/ncat".." "..ip.." "..port)

local clients={}
while true do -- don't exit

-- new client
local client_new,err=server:accept()
if client_new then
  client_new:settimeout(0) -- for client:receive()
  table.insert(clients,client_new)
end

-- clients
for i,client in ipairs(clients) do
  ---print(i.." receive...") -- debug info
  local msg=client:receive()
  if msg then
    print("received: "..msg) -- debug info

    local filename=msg -- SECURITY concern: disallow opening some filenames!!!
    
    local f,errmsg
    function Set (list)
      local set = {}
      for _, l in ipairs(list) do set[l] = true end
      return set
    end
    local allowed_files=Set{"sample1.txt","sample2.lua","sample3.do.lua"}
    if allowed_files[filename]==nil then
      f,errmsg = nil,"filename not allowed"
    else
      f,errmsg = io.open(filename, "r")
    end
    local t
    if f~=nil then
      function string:endswith(suffix)
        return self:sub(-#suffix) == suffix end
      if filename:endswith(".do.lua") then
        t = dofile(filename) -- read & execute
      else
        t = f:read("*all") -- reads as-is
      end
      f:close()
    else
      t=errmsg
    end
    
    msg=t
    
    client:send(msg) -- send back
    client:close() -- send and close!

    clients[i]=nil
  end
end

end -- end while
server:close()
