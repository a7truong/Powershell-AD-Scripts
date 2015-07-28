
######################################## Introduction ############################################################
# 
# NOTES:
# This script is used to transfer file securely through a Windows machine to a Linux machine. It will use WinSCP, 
# WinSCPnet.dll must be available. In addition, this script takes a file, specified by path, and transfers it to 
# a Linux machine, if errors exist, an email will be sent out. After a successful transfer, an email will also
# sent out.
#
# A SSH Fingerprint key is required for file transfer. To get the key, either log into the Linux machine through
# Putty and a popup should appear, or check Putty's registry files.
#
# The format of the key should be: ssh-rsa 2048 xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx
#
#
######################################## Email Server ############################################################
#
$smtpServer="YOUR EMAILING SERVER"
$from = "FROM EMAIL"
$to = "TO EMAIL"     #### $to = "person1@domain.com", "person2@domain.com", "person3@domain.com"
#
######################################## Path Source/Destination #################################################
######################################## NEED TO CHANGE INFORMATION ##############################################
$currDate = Get-Date -format yyyyMMdd
$pre = "PREFIX OF FILENAME"
$suf = "FILE TYPE (.txt, .exe, etc)"
$fileName = $pre + $currDate + $suf
$fName = "NEW FILE NAME, if you need it to be renamed"
$pathSource = "SOURCE PATH"
$noDate = $pathSource + $fName
$server1path1 = $pathSource + $fileName
$server1path2 = $pathSource + "*"
#
$pathDestLinux = "DESTINATION LINUX PATH"
$server2path2 = $pathDestLinux + $fileName
#
######################################### Code Begin #############################################################

# if there is a file starting with ccbglint in the path, but not with today's date
if ((Test-Path $server1path2 -include FILENAME*.txt) -and (-Not (Test-Path $server1path1))) {

    $body = "<p>Please be advised that the file you are looking for, $fileName does not exist in the following path $server1path. But a file with the prefix FILENAME text file does exist in the path.<br><br><br><br>Do not reply to this automated message.</p>"
    $subject = "ERROR: File $fileName does not exist, others located."

    # Send email informing that file is not there
    Send-Mailmessage -smtpServer $smtpServer -from $from -to $to -subject $subject -body $body -bodyasHTML -priority High 

    exit 1
}

# test path to see if file exist in directory
if (-Not (Test-Path $server1path1)) {

    $body = "<p>Please be advised that the file you are looking for, $fileName does not exist in the following path $server1path1.<br><br><br><br>Do not reply to this automated message.</p>"
    $subject = "ERROR: File $fileName does not exist."

    # Send email informing that file is not there
    Send-Mailmessage -smtpServer $smtpServer -from $from -to $to -subject $subject -body $body -bodyasHTML -priority High 

    exit 1
}

# if file with todays date exist in path
if (Test-Path $server1path1) {
                
    # Duplicates the file without the date, then deletes it before exiting
    Copy-Item -force $server1path1 $noDate

    # Load WinSCP .NET assembly
    Add-Type -Path "F:\Program Files (x86)\WinSCP\WinSCPnet.dll"

    # Setup session options
    $sessionOptions = New-Object WinSCP.SessionOptions
    $sessionOptions.Protocol = [WinSCP.Protocol]::Sftp
    ############################## NEED TO CHANGE INFORMATION BELOW ################################################                
    $sessionOptions.HostName = "SERVER IP/HOST NAME"
    $sessionOptions.UserName = "LOGIN INFORMATION FOR Linux Box"
    $sessionOptions.Password = "PASSWORD"
    $sessionOptions.SshHostKeyFingerprint = "HOSTKEY FINGERPRINT KEY - can be found in Putty registry"
    ############################## NEED TO CHAGE INFORMATION ABOVE ###################################################
    $session = New-Object WinSCP.Session
    # Connect
    $session.Open($sessionOptions)

    # Upload files
    $transferOptions = New-Object WinSCP.TransferOptions
    $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary

    $transferResult = $session.PutFiles($noDate, $pathDestLinux, $False, $transferOptions)

    $body = "<p>Please be advised that the file, $fileName has been successfully transferred. A copy without the date has been placed in $pathSource and $pathDestLinux.<br><br><br><br>Do not reply to this automated message.</p>"
    $subject = "File $fileName transferred."

    # Send email informing that file is not there
    Send-Mailmessage -smtpServer $smtpServer -from $from -to $to -subject $subject -body $body -bodyasHTML -priority High 

    # removes the duplicate file created
    Remove-Item $noDate

    exit 0
}

##########################################Code End################################################################
