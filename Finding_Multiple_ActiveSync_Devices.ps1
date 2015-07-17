###################################################################################################################
# NOTES: 
# Script is ran on an Exchange Management Console Powershell Terminal and goes through the organization for users
# with multiple connected ActiveSync devices on their account. Then gathering all the users, an email will be sent
# to the administrator with all the user's information if their exists 2 or more devices on their account.
#
# For example, if a user has two connected devices (iPhone and Blackberry), then the script will catch person A's 
# name and device type. Then the information will be included in the HTML created email which will be sent to the
# administrator. 
#
# Update the following information below (email server, to, from, etc).
#
###################################################################################################################
$smtpServer="YOUR EMAILING SERVER"
$to = "FIRST_LAST <EMAIL_WITH_DOMAIN>"
$from = "FIRST_LAST <EMAIL_WITH_DOMAIN>"
$subject = "Multiple Devices Under Your Account."
$body = "<p>The following users have multiple devices under their account: </p>"
###################################################################################################################

$testing = $false
$sendEmail = $true
$detailed = $true
# Generate basic report
Get-Mailbox -ResultSize Unlimited| ForEach {Get-ActiveSyncDeviceStatistics -Mailbox:$_.Identity} | Select-Object Identity | out-file C:\userOutput.txt

# for testing purposes
if ($testing -eq $true) {
                # testing
                $emails = (Get-Content C:\userOutput.txt) | Sort-Object
                foreach ($email in $emails) {
                                Write-Output $email 
                }
}

if ($testing -eq $false) {
                # grabs the content of our file
                $emails = (Get-Content C:\userOutput.txt) | Sort-Object
                # grabs the first item of our file
                $currName = $emails[4]
                $counter = 0
                $timesPrint = 0
                # loops through all the emails 
                foreach ($email in $emails) {
                        # substring each email to only get the email portion
                        $email = $email.substring(0, $email.IndexOf(".ca")+3);
                        # if items are the same, increment
                        if ($email -eq $currName) {
                                $counter++
                        }
                        # update to body since the currName has more than 1 device associated with them
                        if (($counter -ne 0) -and ($counter -ne 1) -and ($currName -ne $email)) {
                                if (($currName -ne "") -and ($currName -ne "-")) {
                                        $body = $body + "<br>" + $currName + " with " + $counter + " devices."
                                }
                                # reset
                                $counter = 1
                                $currName = $email
                        }
                        # changes the currName if the counter is always 1 on the previous person
                        if ($currName -ne $email) {
                                $currName = $email
                        }
                }
                # Attach detailed report as an attachment, summary of report given in body of email
                if (($sendEmail -eq $true) -and ($detailed -eq $true)) {
                        # Generate detailed report, send as attachment
                        Get-Mailbox -ResultSize Unlimited| ForEach {Get-ActiveSyncDeviceStatistics -Mailbox:$_.Identity} | Select-Object Identity, DeviceType, DeviceID, DeviceUserAgent, LastSuccessSync | export-csv C:\detailedReport.csv
                        Send-Mailmessage -smtpServer $smtpServer -from $from -to $to -subject $subject -body $body -bodyasHTML -Attachments "C:\detailedReport.csv" -priority High
                }
                Elseif (($sendEmail -eq $true) -and ($detailed -eq $false)) {
                         Send-Mailmessage -smtpServer $smtpServer -from $from -to $to -subject $subject -body $body -bodyasHTML -priority High
                }
                else {
                        $nonHTML = $body.Replace("<br>", "`n") 
                        $nonHTML = $body.Replace("<p>", "") 
                        $nonHTML = $body.Replace("</p>", "")
                        write-output $nonHTML
                }
}
