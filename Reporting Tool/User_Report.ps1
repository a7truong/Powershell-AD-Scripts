#################################################################################################################
# 
# Gathers the information of all the accounts on the Regional Network given a list of display names (Last, First).
#
# Input file: list of users in a text file with display name
#
# Output file: Text file delimited with "|", export file to Excel and choose delimited with "|".
#
# Creator: Andy Truong
#
##################################################################################################################


# list of users in a text file
$users = Get-Content "C:\"
write-output "Display Name|Email|Department|Description|Last Logon Date|When Created|When Changed|Expiry Date|Enabled|OU" | out-file -filepath C:\UserInfo -append -noclobber

foreach ($usr in $users) {
	$info = Get-aduser -filter {name -like $usr} -properties *

	$displayName = $info.displayname
	$lastlogon = $info.lastlogondate
	$created = $info.whencreated
	$expiry = $info.accountexpirationdate
	$en = $info.enabled
	$changed = $info.whenchanged
	$dept = $info.department
	$email = $info.userprincipalname
	$des = $info.description
	$ou = $info.canonicalname

	write-output "$usr|$email|$dept|$des|$lastlogon|$created|$changed|$expiry|$en|$ou" | out-file -filepath C:\UserInfo -append -noclobber
}