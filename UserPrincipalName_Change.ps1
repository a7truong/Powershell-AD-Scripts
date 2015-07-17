#################################################################################################################
# Notes:
# 
# Script used to change the UPN of specific users in a specified Organizational Unit (OU). Also, specify the DC. 
# Once given, it will gather users from the OU and DC and change their UPN to first.last@DOMAIN.COM
#
# This script is helpful for organizations to mass change the UPN for all users to newly implement Office 365/Azure/
# Intune. The requirements of the applications requires no special characters and all lower case.
#
#
##################################################################################################################

# Allows the script to gather information from AD
Import-Module ActiveDirectory

# specify the OU and DC that you would like to change the UPN for
$users = get-aduser -filter * -SearchBase 'OU=,DC=' -Properties userPrincipalName

foreach ($user in $users) {
    # gets user by name (last, first)
    $Name = (Get-ADUser $user | foreach { $_.Name})
    $pos = $Name.IndexOf(", ")
    $first = $Name.Substring($pos+2)
    $last = $Name.Substring(0, $pos)

    # Replaces special characters with nothing
    $first = $first.Replace(" ", "")
    $first = $first.Replace("(", "")
    $first = $first.Replace("'", "")
    $first = $first.Replace("-", "")
    $first = $first.ToLower()

    $last = $last.Replace(" ", "")
    $last = $last.Replace("(", "")
    $last = $last.Replace("'", "")
    $last = $last.Replace("-", "")
    $last = $last.ToLower()

    # specify the domain 
    if ($pos -ne -1) {
                set-aduser $user -UserPrincipalName "$($first + "." + $last + "@DOMAIN.COM")"
    }
}
