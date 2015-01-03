#!/usr/bin/expect -f 

# ubloxtest.sh
# 
#
# Created by Giovanni Genna on 23/12/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

set timeout 8
#debug -now
spawn wermit -c
expect "enabled"
send "at\r"
expect "OK"

sleep 1

send "atz\r"
expect "OK"

sleep 1
# messaggi di errore abilitati
send "AT+CMEE=2\r"
expect "OK"
sleep 1


set timemio 0
#GPS receiver powered ON
sleep 1
send "at+ugps=1,0\r"
expect {
"OK" { 
send "at+ugps?\r"
while 1 {

expect {
		"1,0" { break }
		timeout { incr timemio
         if { $timemio < 10 } {
		 continue
		  }
		  else
		  {
		  
		  exit
		   } 
		}
		
}
}
}
"already set" {  } 
timeout {  }

}

set timeout 20
#Check network registration

#Check network registration status
sleep 1

send "AT+COPS=0\r"

expect { "OK" {  }
		timeout { exit }
 }
 
 sleep 1
send "AT+COPS?\r"
expect {
 "TIM" {  }
 timeout { exit }
 }
sleep 1


#Check GPRS attach status
send "AT+CGATT?\r"
expect {
"OK" {  }

timeout { exit }
}

#Setup APN
sleep 1

send "AT+UPSD=0,1,\"ibox.tim.it\"\r"
expect "OK"

#Setup the dynamic IP address assignment
send "AT+UPSD=0,7,\"0.0.0.0\"\r"
expect "OK"
#Save GPRS profile in the NVM
send "AT+UPSDA=0,1\r"
expect "OK"
# show list upsda
send "AT+UPSD=0\r"
expect "UPSD: 0,1,\"ibox.tim.it\""
#Activate the GPRS connection
send "AT+UPSDA=0,3\r"
expect "OK"
#Check the assigned IP address
send "AT+UPSND=0,0\r"
expect "OK"


sleep 20


# WHILE 
while 1 {

	sleep 10

	# check nuovi mess ricevuti
	send "AT+CSMS=1\r"
	expect ""
	#send "AT+CPMS=\"BM\",\"SM\",\"SM\"r"
	#expect ""
	send "CMGF=1\r"  # formato test mode
	expect ""
	# read a new sms
	send "AT+CMGR=<index>\r"
	expect ""
	#delete read sms
	send "AT+CMGD=<index>\r"
	expect ""


	# stato GPS
	send "AT+UGGLL=1\r"
	expect { "OK"{
	# lettura punto
	send "AT+UGGLL?\r"
	expect -re "" # memorizza punto
	set punto $expect_out(buffer)}
	timeout {continue}
    }

	
	#connetti al socket
	send "at+usoco=$Numsocket,\"95.227.182.153\",22037\r"
	expect{ 
	
	"OK" {
					send "at+usowr=1,dimstringapuntoGPS\r"
					expect{ "@"{send "$punto\r"}
					timeout {continue}
					}
					
		}	
	"ERR"
	{
	#crea socket e  memorizzo NumSocket
	send "at+usocr=6\n"
	expect{ -re "[0-9]$"{ set Numsocket $expect_out(1,string) 
						  send "at+usoco=$Numsocket,\"95.227.182.153\",22037\n"
						  expect "OK"					}
	        timeout {continue}
	
			}
	}
	
			}
	

}
#expect eof

interact

# end script