$conversion = {
	param (
		$Identity,

		$AsName
	)

	foreach ($pair in $script:manuallyMappedRoles.GetEnumerator()) {
		if ($AsName) {
			if ($pair.Key -eq $Identity) { return $pair.Value }
		}
		else {
			if ($pair.Value -eq $Identity) { return $pair.Key }
		}
	}
}
$listnames = {
	$script:manuallyMappedRoles.Values
}

$param = @{
	Name        = 'manual'
	Conversion  = $conversion
	ListNames   = $listnames
	Priority    = 1
	Enabled     = $true
	Description = 'Allows manually defining a name-to-role mapping using Set-PIMRoleMapping.'
}

Register-PIMRoleProvider @param