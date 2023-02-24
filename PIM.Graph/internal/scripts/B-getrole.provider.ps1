$conversion = {
	param (
		$Identity,

		$AsName
	)

	$roles = Get-PIMRole
	if ($AsName) {
		$roles | Where-Object {
			$_.Id -eq $Identity -or
			$_.roleTemplateId -eq $Identity
		} | Select-Object -First 1 | ForEach-Object displayName
	}
	else {
		$roles | Where-Object displayName -EQ $Identity | Select-Object -First 1 | ForEach-Object displayName
	}
}
$listnames = {
	(Get-PIMRole).displayName
}

$param = @{
	Name       = 'Get-PIMRole'
	Conversion = $conversion
	ListNames  = $listnames
	Priority   = 60
	Enabled    = $true
	Description = 'Uses Get-PIMRole to resolve roles against graph. Requires scope RoleManagement.Read.Directory'
}

Register-PIMRoleProvider @param