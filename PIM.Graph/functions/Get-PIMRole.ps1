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
	
	begin {
		Assert-EntraConnection -Service $script:entraServices.Graph -Cmdlet $PSCmdlet
	}
	process {
		Invoke-EntraRequest -Service $script:entraServices.Graph -Path "roleManagement/directory/roleDefinitions" | Where-Object displayName -Like $Name | ForEach-Object {
			$_.PSObject.TypeNames.Insert(0, 'PIM.Graph.Role')
			$_
		}
	}
}
