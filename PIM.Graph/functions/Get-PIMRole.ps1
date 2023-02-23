function Get-PIMRole {
	[CmdletBinding()]
	Param (
		[string]
		$Name = '*'
	)
	
	process {
		Invoke-PimGraphRequest -Uri "v1.0/directoryRoles" | Where-Object displayName -Like $Name
	}
}
