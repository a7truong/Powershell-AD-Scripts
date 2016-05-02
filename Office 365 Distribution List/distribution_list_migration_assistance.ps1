##############################################################
#
# Migration of DLs
#
# Given a list of distribution lists (DLs), it creates the DL in Exchange Online
# and then goes to AD and finds that DL with the members.
# Add those members to the newly created DL.
#
# Must be connected to AD.
#
# Script Steps:
# 1. Creates all DLs in list given
# 2. For each DL created, goes through AD of the DL to find the members
#    and adds the user
#
# Creator: Andy Truong
#
##############################################################

# reads a list of distribution lists from a text file
$dls = Get-Content "C:\"

# enter your domain here
$domain = ""

# create the distribution lists in Exchange 2013 Online
foreach ($dl in $dls) {
	# create new DL
	New-DistributionGroup -name $dl

	# get the domain UPN
	$smtp = (Get-DistributionGroup $dl).primarysmtpaddress
	$begin = $smtp.substring(0,$smtp.indexof("@"))
	$newSMTP = "$begin@$domain"

	# set the SMTP to end in @$domain
	Set-DistributionGroup $smtp -WindowsEmailAddress $newSMTP
}


# find members in DL in AD, add them to newly created DL above
foreach ($dl in $dls) {
	# iteratively add group members to the new group created in Exchange Online
	Get-ADGroupMember -identity $dl | select name | foreach-object {Add-DistributionGroupMember -identity $dl -member $_.name}

	# get ownership and add the owner
	$ou = (Get-ADGroup -identity $dl -properties managedby).managedby

	# get last, first format
	$manage = ($ou.substring(0,$ou.indexof(",OU"))).replace("CN=","").replace("\","")

	# add to ownership list
	Set-DistributionGroup $dl -managedby @{add=$manage}
}