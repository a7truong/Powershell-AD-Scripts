######################################## Introduction ############################################################
#
# NOTES: 
#
# Upload to remote server.
#
# FTP Program Used: WinSCP
#
# Protocol used: FTP
# FTP Security: Explicit TLS
# Port: 21
# Mode: Passive
# Uploads a file from a src path (local path) to a desination path (remote path).
#
# Uploads a file of certain name to the remote FTP server.
#
# After a successful upload, an email will be sent to the $to users to indicate the upload from src to 
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
$remotePath = "DESTINATION PATH, where to upload to"
$pathSrc = "SOURCE PATH, where the file is coming from"
$currDate = Get-Date -format yyyyMMdd
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

#$sessionOptions = New-Object WinSCP.SessionOptions
#$sessionOptions.Protocol = [WinSCP.Protocol]::Sftp

############################## NEED TO CHANGE INFORMATION BELOW ################################################                
$sessionOptions.HostName = "HOST NAME"
$sessionOptions.UserName = "USERNAME"
$sessionOptions.Password = "PASSWORD"
$sessionOptions.TlsHostCertificateFingerprint = "FINGERPRINT CERTIFICATE of the HOST NAME ABOVE"
############################## NEED TO CHAGE INFORMATION ABOVE #################################################
$session = New-Object WinSCP.Session

try {
    # Connect
    $session.Open($sessionOptions)

    $fileName = "FILE NAME YOU WANT TO UPLOAD"

    $pathSrcwithFile = $pathSrc + $filename + "\"

    if (-Not (Test-Path $pathSrcwithFile)) {
        write-host "Not here. $pathSrcwithFile"
        $body = "<p>File name $fileName does not exist in $pathSrc</p>"
        $subject = "ERROR: File $latestFile1.name does not exist."

        # Send email informing that file is not there
        Send-Mailmessage -smtpServer $smtpServer -from $from -to $to -subject $subject -body $body -bodyasHTML -priority High
    }
    elseif (Test-Path $pathSrcwithFile) {
        # Upload files
        $transferOptions = New-Object WinSCP.TransferOptions
        $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary

        $transferResult = $session.PutFiles($pathSrcwithFile, $remotePath, $False, $transferOptions)
        $body = "<p>File has been successfully uploaded from $pathSrcwithFile to $remotePath</p>"
        $subject = "File $fileName uploaded."

        # Send email informing that file is not there
        Send-Mailmessage -smtpServer $smtpServer -from $from -to $to -subject $subject -body $body -bodyasHTML -priority High 
        write-host "Successful upload from $pathSrcwithFile to $remotePath"
    }
}
catch [Exception] {
    $body = "<p>Error connecting to server.</p>"
    $subject = "Connection Terminated"

    # Send email informing that file is not there
    Send-Mailmessage -smtpServer $smtpServer -from $from -to $to -subject $subject -body $body -bodyasHTML -priority High 
    Write-Host $_.Exception.Message
    exit 1
}
finally {
    $session.Dispose()
}

################################################### Code End ###################################################
