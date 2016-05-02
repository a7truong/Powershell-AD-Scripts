#################################################################################################################
# 
# Version 1.0, April 2016
#
# Notification script that sends an email to the user's manager. It will send an email notifying the user's manager
# of their employee's account expiring 30 days, 15 days and 1 day before.
#
##################################################################################################################
#
$smtpServer = ""
$from = ""
#
###################################################################################################################

############################# TESTING AND VARIABLES #############################
#
# change between "Enabled" and "Disabled" to indicate if we want message pushed to certain people ("Enabled") or whole network ("Disabled")
#
$selectPeople = "Disabled"
#
############################# TESTING AND VARIABLES #############################


# Get Users From AD who are Enabled, only get enabled users with a valid expiry date
Import-Module ActiveDirectory

# only get enabled users with a valid expiry date
$users = Get-ADUser -filter * -properties * | where {$_.Enabled -eq "True"} | where {$_.accountexpirationdate -ne $null}

$today = Get-Date

# Processing for selected people
if ($selectPeople -eq "Enabled") {
    foreach ($user in $users) {
        $name = $user.name
        $sam = $user.samaccountname

        if ((($name) -eq "NAME1") -or 
            (($name) -eq "NAME2")
            # add more names HERE 
            ) {

            $userEmail = $user.emailaddress

            $emailTO = $user.emailaddress
            $manager = $user.manager

            # get user's account expiry
            $expiry = $user.accountexpirationdate

            # days until expiry, days calculation	
            $daystoexpire = ($expiry - $today).Days

            # manager info
            if ($user.manager -ne $null) {
            	$manager = Get-ADUser -filter {distinguishedname -like $user.manager} -properties *
            	$emailTO = $manager.emailaddress
            }

            $subMessage = "User account to expire on $expiry for $name"

            # Email Subject Set Here
            $subject="$subMessage"
                      
            # Email Body Set Here, Note You can use HTML, including Images.
            $body = "
                Hi,
                <p> This email is in regards to an account expiry. Please be advised that the following 
                user's account is about to expire.<br><br>
                Name: $name <br>
                Employee ID: $sam<br>
                Account Expires on: $expiry ($daystoexpire days remaining) <br>
				</p>				
				<p>Thank you for your cooperation. <br>
 
                <p><b>*Please do not reply to this automated message.*<br>
                </p>"

            # Send Email Message
            if (($daystoexpire -eq "30") -or ($daystoexpire -eq "15") -or ($daystoexpire -eq "1")) {
                # Send Email Message
                Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailTO -cc $userEmail -subject $subject -body $body -bodyasHTML -priority High 

            } # End Send Message
        }

    } # End User Processing
} # End Processing for Selected Users


# Processing for selected people
if ($selectPeople -eq "Disabled") {
    foreach ($user in $users) {
        $name = $user.name
        $sam = $user.samaccountname

        $userEmail = $user.emailaddress

        $emailTO = $user.emailaddress
        $manager = $user.name

        # get user's account expiry
        $expiry = $user.accountexpirationdate

        # days until expiry, days calculation
        $daystoexpire = ($expiry - $today).Days

        # manager info, if it is empty, then an email is sent directly to the user
        if ($user.manager -ne $null) {
            $manager = Get-ADUser -filter {distinguishedname -like $user.manager} -properties *
            $emailTO = $manager.emailaddress
        }

        # Set Greeting based on Number of Days to Expiry.

        $subMessage = "User account to expire on $expiry for $name"

        # Email Subject Set Here
        $subject="$subMessage"
                      
        # Email Body Set Here, Note You can use HTML, including Images.
        $body = "
            Dear $manager.name,
            <p> This email is in regards to an account expiry. Please be advised that the following 
            user's account is about to expire.<br><br>
            Name: $name <br>
            Employee ID: $sam<br>
            Account Expires on: $expiry ($daystoexpire remaining) <br>
			</p>				
			<p>Thank you for your cooperation. <br>
 
            <p><b>*Please do not reply to this automated message.*<br>
            </p>"

        # Send Email Message
        if (($daystoexpire -eq "30") -or ($daystoexpire -eq "15") -or ($daystoexpire -eq "1")) {
            # Send Email Message
            Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailTO -cc $userEmail -subject $subject -body $body -bodyasHTML -priority High

        } # End Send Message

    } # End User Processing
} # End Processing for Selected Users

# End
