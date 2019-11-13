# Heating optimisation system for my home. 
## Server: RaspberryPi+Python 


Server works only for BFV zonebox. The zonebox provide a simple webserver to check current temperature on each thermostat and to change the settings.

To optymalize energy cost (electricity is much cheaper during night) but keep confortable temperature - the algorithm is based on two linear functions.
In `settings.csv` I specify minimal and maximal temperatures for each thermostat for night and day.

The python program is monitoring temperatures every 5minute and change thermostats settings. 

###### Note:
My Python skills are not great, therefore I don't want to share source code for the server publicly


## Client: RxSwift

Add `Config.plist` with url for the server


Screen recording<br/>
![Screenshot thermostats List](/HeatingClient/Screenshots/animation.gif)
