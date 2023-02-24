function Get-PIMRole {
	<#
	.SYNOPSIS
		Search AAD for directory roles.
	
	.DESCRIPTION
		Search AAD for directory roles.

		Scopes:
		RoleManagement.Read.Directory, Directory.Read.All, RoleManagement.ReadWrite.Directory, Directory.ReadWrite.All
	
	.PARAMETER Name
		The name to filter the roles by.
	
	.EXAMPLE
		PS C:\> Get-PIMRole

		Retrieve all active roles.
	#>
	[CmdletBinding()]
	Param (
		[string]
		$Name = '*'
	)
	
	process {
		Invoke-PimGraphRequest -Uri "v1.0/directoryRoles" | Where-Object displayName -Like $Name
	}
}
