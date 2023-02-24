function Unregister-PIMRoleProvider {
	<#
	.SYNOPSIS
		Remove an existing Role Provider.
	
	.DESCRIPTION
		Remove an existing Role Provider.
		Role Providers are plugins that allow resolving role names using the logic provided within.
	
	.PARAMETER Name
		Name of the Role Provider to remove
	
	.EXAMPLE
		PS C:\> Unregister-PIMRoleProvider -Name Get-PIMRole
		
		Removes the 'Get-PIMRole' Role Provider
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[string[]]
		$Name
	)
	process {
		foreach ($providerName in $Name) {
			$script:roleProviders.Remove($providerName)
		}
	}
}