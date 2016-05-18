print("Starting main.lua... \n")

gpio.mode(3, gpio.OUTPUT)
srv=net.createServer(net.TCP,28800)
print("Server created... \n")
local pinState=0
srv:listen(80,function(conn)
    conn:on("receive", function(conn,request)
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        
        local message={}
        print("Method:"..method);
        if(method == "POST")then
           if(pinState==0)then
              gpio.write(3,gpio.HIGH)
              pinState=1
              print("LED ON")
              message[#message + 1] = "HTTP/1.1 200 OK\r\n"
              message[#message + 1] = "Content-Type: text/html\r\n\r\n"
              message[#message + 1] = "POST request successfully received\r\n"
           elseif(pinState==1)then
              gpio.write(3,gpio.LOW)
              pinState=0
              print("LED OFF")
              message[#message + 1] = "HTTP/1.1 200 OK\r\n"
              message[#message + 1] = "Content-Type: text/html\r\n\r\n"
              message[#message + 1] = "POST request successfully received\r\n"
           end 
        elseif(method == "GET")then
           message[#message + 1] = "HTTP/1.1 200 OK\r\n"
           message[#message + 1] = "Content-Type: text/html\r\n\r\n"
           message[#message + 1] = "LED STATE="..tostring(pinState).."\r\n"
        end
        local function send()
          if #message > 0 then 
             conn:send(table.remove(message, 1))
          else
             conn:close()
          end
        end
        conn:on("sent", send)
        send()
        local message={}
        local _, _, method, path, vars= {}
        local heapSize=node.heap()
        if heapSize<1000 then
           node.restart()
        end
        collectgarbage()
        print("Memory Used:"..collectgarbage("count"))
        print("Heap Available:"..heapSize)
        
    end)
end)