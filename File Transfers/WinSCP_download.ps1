######################################## Introduction ############################################################
#
# NOTES: 
#
# Download from remote server.
#
# FTP Program Used: WinSCP
#
# Protocol used: FTP
# FTP Security: Explicit TLS
# Port: 21
# Mode: Passive
# Downloads a file from a src path (remote path) to a desination path.
#
# Downloads the most recent file (by time stamp) of a certain name specified below (if name has multiple files 
# of the same prefix or suffix). For example, TEST.001.txt, TEST.002.txt, TEST.003.txt, etc (will download the 
# latest one), in script, the wildcard search would be "TEST.*.txt"
#
# After a successful download, an email will be sent to the $to users to indicate the download from src to 
# destination.
#
######################################## Email Server ############################################################
#
$smtpServer = "EMAIL HUB SERVER"
$from = "FROM EMAIL"
$to = "TO EMAILS, separate with a comma"
#
################################## NEED TO CHANGE INFORMATION ABOVE ##############################################
#
######################################## Path Source/Destination #################################################
#
$remotePath = "ADD YOUR SOURCE PATH HERE"
$pathDest = "ADD YOUR DESINATION PATH HERE"
#
######################################### Code Begin #############################################################

# Load WinSCP .NET assembly
Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"

# Setup session options
$sessionOptions = New-Object WinSCP.SessionOptions
$sessionOptions.Protocol = [WinSCP.Protocol]::ftp
$sessionOptions.FtpMode = [WinSCP.FtpMode]::passive
$sessionOptions.FtpSecure = [WinSCP.FtpSecure]::ExplicitTls
$sessionOptions.PortNumber = "21"

############################## NEED TO CHANGE INFORMATION BELOW ################################################                
$sessionOptions.HostName = "HOST NAME"
$sessionOptions.UserName = "USERNAME"
$sessionOptions.Password = "PASSWORD"
$sessionOptions.TlsHostCertificateFingerprint = "FINGERPRINT CERTIFICATE of the HOST NAME ABOVE"
############################## NEED TO CHAGE INFORMATION ABOVE #################################################

$session = New-Object WinSCP.Session
# Connect
$session.Open($sessionOptions)

$directoryInfo = $session.ListDirectory($remotePath)

# gets the file name of most recent updated copy with the file name you want wildcard
$latestFile1 = $directoryInfo.Files | Where-Object { -Not $_.IsDirectory -and $_.name -like "NAME OF FILE YOU WANT TO FIND" } | Sort-Object LastWriteTime -Descending | Select-Object -First 1

$remotePathwithFile = $remotePath + $latestFile1
if (-Not ($session.FileExists($remotePathwithFile))) {
    write-host "No file $remotePathwithFile"
    $body = "<p>File name $latestFile1.name does not exist in $remotePathwithFile</p>"
    $subject = "ERROR: File $latestFile1.name does not exist."

    # Send email informing that file is not there
    Send-Mailmessage -smtpServer $smtpServer -from $from -to $to -subject $subject -body $body -bodyasHTML -priority High 
}
else {    
    # Upload files
    $transferOptions = New-Object WinSCP.TransferOptions
    $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary

    $transferResult = $session.GetFiles($session.EscapeFileMask($remotePathwithFile), $pathDest, $False, $transferOptions)

    write-host "$remotePathwithFile downloaded"
    $body = "<p>File has been successfully downloaded from $remotePathwithFile to $pathDesk</p>"
    $subject = "File $latestFile1 downloaded."

    # Send email informing that file is not there
    Send-Mailmessage -smtpServer $smtpServer -from $from -to $to -subject $subject -body $body -bodyasHTML -priority High 
}
################################################### Code End ###################################################
