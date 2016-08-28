#TUTORIAL WEB-SERVER

1) Buy "USB CONVERTER TTL CP2102" or "FTDI FT232"

2) See ESP8266_to_FT232.jpg and ESP8266.jpg

	ESP TX to FTDI RX
	ESP GND to FTDI GND
	ESP CH_PD to FTDI 3.3v
	ESP GPIO2 to nothing
	ESP RST to nothing
	ESP GPIO0 to FTDI GND (disconnect after flashing, to normal boot)
	ESP VCC to FTDI 3.3v
	ESP RX to FTDI TX

3) Plug FTDI to computer

	Open ESP8266Flasher.exe
	Touch tab Config and button Engine
	Select nodemcu Firmware/nodemcu_float_0.9.6-dev_20150704.bin
	In Advanced I used:
		Baudrate: 19200
		Flash size: 512KByte
		Flash speed: 40Mhz
		SPI Mode: QIO
	Go to Operation Tab and Flash it (If not work, unplug and plug FTDI)

4) Unplug FTDI from computer USB port

	Unplug the wire from ESP8266 GPIO0 that connect to FTDI GND. IMPORTANT !!!
	Plug FTDI to computer again

5) Open ESPlorer/ESPlorer.jar (require JAVA 7 or UP: http://java.com/download)
	
	Open with it int.lua
	Select 19200 Baudrate and click Open (Normal errors like: Cant autodetect firmware) 
	Change line wifi.sta.config("ssid","password")
	And select SAVE to ESP

	Problems: Nothing happens ? Try step 3 with firmware nodemcu_integer_x.bin (remeber reconnect wire GPIO0 before flash again)

6) Plug led to GPIO0 or GPIO2 with resistor to GND like final_circuit.jpg

7) Disconnect power and reconnect to reset all.

8) Wait a seconds and search the IP of ESP8266 ...

	You can use nmap 192.168.1.1/24
	Or enter to router and go to DHCP current Client list

9) Brwose IP on you web browser or use CURL