#This script was created by Christian Burke to help simplify the Manual O365 Migration Process. 

#Shows you the current state of AD joined devices 
dsregcmd /status | find /I "AzureAdJoined"
dsregcmd /status | find /I "DomainJoined"

#Promtps the user if they need to leave the domain
@ECHO OFF
set /p userInput = "Is Device Azure and Domain Joined?"
If /i "%userInput%" == "yes" GOTO leave 
If /i "%userInput%" == "no" GOTO Workplace

#This section forces the device to leave the domain 
:leave 
dsregcmd /leave
goto workplace

#This section opens Access Work or School system settings which allows you to disconnect any old domain creds
:workplace
start ms-settings:workplace
pause 
goto creds

#This sectio0n opens credential manager which allows you to remove any credentials linked to the onld O365 tenant 
:creds
control /name Microsoft.CredntialManager 
pause
goto reg

#This section changes the registry keys to reflect the new tenant information 
:reg
dsregcmd /leave
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CDJ\AAD" /v "TenantId" /t REG_SZ /d TenantID Value /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CDJ\AAD" /v "TenantName" /t REG_SZ /d TenantName Value /f
REG QUERY HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CDJ\AAD
pause 
goto  end

#This section reboots the device to take the changes just made
:end
shutdown /r /f 
