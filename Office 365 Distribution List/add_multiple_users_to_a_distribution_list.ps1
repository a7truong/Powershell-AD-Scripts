################################################################################################
#
# Provide a list of users to a distribution list on Exchange Online.
#
# Created: Andy Truong
#
################################################################################################

# list of users in a text file
$users = Get-Content "C:\"

# input the name of the distribution list inside the quotations
$distributionList = ""

foreach ($usr in $users) {
	Add-DistributionGroupMember -identity $distributionList -member $usr
}