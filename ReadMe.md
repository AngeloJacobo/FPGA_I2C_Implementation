Created by: Angelo Jacobo  
Date: July 28,2021  

[![image](https://user-images.githubusercontent.com/87559347/127265370-b189a2ca-7299-4331-a21f-5745ca604da7.png)](https://youtu.be/xc_hXEl5_Zc)

# Inside the src folder are:  
* ds1307_controller.v -> Combines i2c_top and LED_mux modules. Current time is retrieved from ds1307 then displayed  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;real-time on the seven-segment LEDs.  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;key[0] for writing date/time to ds1307 via i2c protocol  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;key[2] to change display between time(hh.mm.ss) and date(mm.dd.yy)  
* i2c_top -> i2c communication protocol controller  
* LED_mux -> Multiplexing circuit for seven-segments  
* ds1307_controller.ucf -> Constraint file for ds1307_controller.v  

Note: The constraint file is designed for Spartan 6 xc6slx9-2ftg256 FPGA (specifically the AX309 FPGA development board). Edit at your own risk.  

# UML_Chart (i2c bit-bang implementation):
![UML_Chart](https://user-images.githubusercontent.com/87559347/127259379-dd459274-89d2-4dc5-b9bc-6219f04505ff.jpg)


# TASK:  
This project implemented a bit-bang i2c protocol in order to communicate    
to ds1307 real time clock module. Retrieved data from the rtc is displayed  real time   
to the seven-segment LED display.  
* key[0] is for writing data(time/date) to ds1307  
* key[1] is for interchanging display between time(hh.mm.ss) and date(mm.dd.yy)  
