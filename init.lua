print("Ready to start ")

local mode=1;
local forceApMode=nil;
local waiter=0;
local ssid = nil;
local pwd = nil;

if file.open("ap.cfg") then
    ssid = (file.readline());
    pwd = (file.readline());
    file.close();
end

if (ssid ~= nil and pwd ~= nil) then
    mode=2;

    gpio.mode(3, gpio.OUTPUT);
    gpio.mode(4, gpio.INPUT);
    gpio.write(3, gpio.LOW);
    
    forceApMode = (gpio.read(4));

    if (forceApMode == 0) then
        mode=1;
        print("Mode 1 forced");
    end
end

gpio.mode(3, gpio.OUTPUT);
gpio.mode(4, gpio.OUTPUT);
gpio.write(3, gpio.HIGH);
gpio.write(3, gpio.HIGH);
    
if mode == 1 then
    ssid = nil;
    pwd = nil;
    
    print("Mode 1")

    local str=wifi.ap.getmac();
    
    local ssidTemp=string.format("%s%s%s",string.sub(str,10,11),string.sub(str,13,14),string.sub(str,16,17));
    
    print(ssidTemp);
    
    cfg={}
    cfg.ssid="ESP8266_"..ssidTemp;
    cfg.pwd="12345678";
    wifi.ap.config(cfg);
     
    cfg={}
    cfg.ip="192.168.4.1";
    cfg.netmask="255.255.255.0";
    cfg.gateway="192.168.1.1";
    wifi.ap.setip(cfg);
    wifi.setmode(wifi.SOFTAP)
    
    str=nil;
    ssidTemp=nil;
    collectgarbage();

    tmr.alarm(1,5000, 1, function() if wifi.ap.getip()==nil then print(" Wait to IP address!") else print("New IP address is "..wifi.ap.getip()) tmr.stop(1) end end)
        
    if srv~=nil then
        srv:close()
    end
    
    srv=net.createServer(net.TCP)
    srv:listen(80,function(conn)
        conn:on("receive", function(client,request)
            local buf = "";
            local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
            if(method == nil)then
                _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP")
            end
            local _GET = {}
            if (vars ~= nil)then
                for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                    _GET[k] = v;
                    if (k == "ssid")then
                        print(k..": "..v);
                        ssid = v;
                    end
                    if (k == "password")then
                        print(k..": "..v);
                        pwd = v;
                    end
                end
            end

            if (ssid ~= nil and pwd ~= nil) then
                buf = buf.."<h1>Configured. Shutting down Access Point</h1>";
            else
                buf = buf.."<h1> ESP8266 Web Server</h1>";
                buf = buf.."<form method=\"GET\" action=\"\"><p>SSID <input type=\"text\" placeholder=\"Ssid\" name=\"ssid\"></p>";
                buf = buf.."<p>PASSWORD: <input type=\"text\" placeholder=\"Password\" name=\"password\"></p><input type=\"submit\" value=\"EnviaR\" name=\"send\"></form>";
            end
            client:send(buf);
            client:close();
            collectgarbage();

            if (ssid ~= nil and pwd ~= nil) then
                
                tmr.alarm(1,3000, 1, function() if waiter<=3 then print(" Restarting..."); waiter = waiter + 1; else node.restart() tmr.stop(1) end end)
                file.open("ap.cfg", "w")
                file.writeline(ssid)
                file.writeline(pwd)
                file.close()
                --redirect with JS cooldown...
            end
            
        end)
    end)
else
    print("Mode 2");
    ssid = string.gsub(ssid, "\n", "");
    pwd = string.gsub(pwd, "\n", "");
    print("SSID: "..ssid);
    print("PWD: "..pwd);

    wifi.setmode(wifi.STATION)
    wifi.sta.config(ssid, pwd)
    wifi.sta.connect()
    
    print("Waiting for IP")
    ip = wifi.sta.getip()

    tmr.alarm(1,5000, 1, function() if wifi.sta.getip()==nil then print(" Wait to IP address!") else print("New IP address is "..wifi.sta.getip()) tmr.stop(1) end end)
    
    led1 = 3
    led2 = 4
    gpio.mode(led1, gpio.OUTPUT)
    gpio.mode(led2, gpio.OUTPUT)
    
    if srv~=nil then
        srv:close()
    end
        
    srv=net.createServer(net.TCP)
    srv:listen(80,function(conn)
        conn:on("receive", function(client,request)
            local buf = "";
            local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
            if(method == nil)then
                _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP")
            end
            local _GET = {}
            if (vars ~= nil)then
                for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                    _GET[k] = v
                end
            end
            buf = buf.."<h1> ESP8266 Web Server</h1>";
            buf = buf.."<p>GPIO0 <a href=\"?pin=ON1\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF1\"><button>OFF</button></a></p>";
            buf = buf.."<p>GPIO2 <a href=\"?pin=ON2\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF2\"><button>OFF</button></a></p>";
            local _on,_off = "",""
            if(_GET.pin == "ON1")then
                  gpio.write(led1, gpio.LOW);
            elseif(_GET.pin == "OFF1")then
                  gpio.write(led1, gpio.HIGH);
            elseif(_GET.pin == "ON2")then
                  gpio.write(led2, gpio.LOW);
            elseif(_GET.pin == "OFF2")then
                  gpio.write(led2, gpio.HIGH);
            end
            client:send(buf);
            client:close();
            collectgarbage();
        end)
    end)


    
end
