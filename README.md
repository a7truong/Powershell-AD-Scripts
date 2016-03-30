# Powershell Scripts

Powershell scripts used to connect to Active Directory Servers (AD) to manage users in a company. Special instructions to individual scripts will be located as comments in the respective script. In addition to AD scripts, there are Exchange and Office 365 scripts.

To run scripts for AD:

1. Log into an Active Directory Server.
2. Run Powershell as an administrator (right click on Powershell).
3. Type in the command, 'Set-ExecutionPolicy Unrestricted'. This will unrestrict the permissions to run scripts and will allow     all scripts to run on the server.
4. Copy/upload the script to the server, note down the path of where you placed it.
5. Change directory to the path noted in step 4.
      (i.e.: If the script was placed in C:\Scripts, 
            Type in 'cd C:\Scripts')
6. Once you have located your script, run the script by invoking '.\ScriptName'
      (i.e.: If the script is named ad_script.ps1, run the script by '.\ad_script.ps1')

To run scripts for Exchange/Office 365:

1. Open your Exchange server.
2. Connect to your Exchange online or on-prem.
3. Copy/upload the script to the server, note down the path of where you placed it.
4. Change directory to the path noted in step 3.
      (i.e.: If the script was placed in C:\Scripts, 
            Type in 'cd C:\Scripts')
5. Once you have located your script, run the script by invoking '.\ScriptName'
      (i.e.: If the script is named o365_script.ps1, run the script by '.\o365_script.ps1')
