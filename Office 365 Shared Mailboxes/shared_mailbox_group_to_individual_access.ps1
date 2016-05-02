################################################################################################
#
# Allows the user to input a text file with all shared mailbox names. It grabs each shared
# mailbox, then goes to AD to get the group members, gives the member full and send-as
# access to the shared mailbox on Exchange Online.
#
# If there is a group inside a shared mailbox (Office 365), it will go into that group and
# grabs the users inside the group and give it individual access to the shared mailbox.
#
# Must be connected to AD.
#
# Created: Andy Truong
#
################################################################################################

# list of shared mailboxes (by name) in a text file
$mailboxes = Get-Content "C:\"

foreach ($mailbox in $mailboxes) {
	# gets the mailbox permissions from Exchange online
	$permissions = Get-MailboxPermission $mailbox | where user -notlike "*\*" | select user

	# for each user in the full access, open the group, if not a group, then ignore
	foreach($usr in $permissions) {

		# gets the type information
		#$type = Get-ADObject -filter {name -like $usr} 

		# list of group members
		$groupMembers = Get-ADGroupMember -identity $usr.user

		foreach($member in $groupMembers) {

			# gives $memeber full access to $mailbox
			Add-MailboxPermission $mailbox -User $member.name -AccessRights FullAccess -Automapping $False

			# gives $memeber send-as access to $mailbox
			Add-RecipientPermission $mailbox -Trustee $member.name -AccessRights SendAs -Confirm:$False
		}
	}
}