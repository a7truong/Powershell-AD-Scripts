##############################################################
#
# Given a list of distribution lists (DLs), it goes to AD and 
# finds that DL with the members and adds them to the 
# Exhange Online DL already created.
#
# Must be connected to AD.
#
# Creator: Andy Truong
#
##############################################################

# givn a list of distribution lists in a text file
$dls = Get-Content "C:\"

# add users to DLs

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