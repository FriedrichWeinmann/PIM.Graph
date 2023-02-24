$conversion = {
	param (
		$Identity,

		$AsName
	)

	foreach ($pair in $script:defaultBuiltinRoles.GetEnumerator()) {
		if ($AsName) {
			if ($pair.Key -eq $Identity) { return $pair.Value }
		}
		else {
			if ($pair.Value -eq $Identity) { return $pair.Key }
		}
	}
}
$listnames = {
	$script:defaultBuiltinRoles.Values
}

$param = @{
	Name       = 'builtin'
	Conversion = $conversion
	ListNames  = $listnames
	Priority   = 2
	Enabled    = $true
}

Register-PIMRoleProvider @param