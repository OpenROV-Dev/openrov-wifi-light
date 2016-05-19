print("Starting main.lua... \n")

gpio.mode(3, gpio.OUTPUT)
srv=net.createServer(net.TCP,28800)
print("Server created... \n")
srv:listen(80,function(conn)
    conn:on("receive", function(conn,request)
        local _,_,method,path= string.find(request, "([A-Z]+) (.+)?(.+) HTTP")
        local _, _, key,light_level = string.find(request, "(%a+)%s*:%s*(%d+)")
        if(method == nil)then
            _,_,method,path = string.find(request, "([A-Z]+) (.+) HTTP")
        end
        local duty=light_level*1023/100
        pwm.setup(3, 500, duty)
        local message={}
        print("Level:"..light_level)
        if(method == "POST")then --light_level was sent from node.js as the header of the request
           if(duty>0)then
              pwm.start(3)
              print("LED ON, POWER:"..light_level)
              message[#message + 1] = "HTTP/1.1 200 OK\r\n"
              message[#message + 1] = "Content-Type: text/html\r\n\r\n"
              message[#message + 1] = "POST request successfully received\r\n"
           elseif(duty==0)then
              pwm.stop(3)
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
        local method,path,key,light_level= {}
        local heapSize=node.heap()
        if heapSize<2000 then
           node.restart()
        end
        collectgarbage()
        print("Memory Used:"..collectgarbage("count"))
        print("Heap Available:"..heapSize)
    end)
end)
