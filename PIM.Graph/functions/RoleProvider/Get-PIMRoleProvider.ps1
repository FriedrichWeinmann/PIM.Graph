function Get-PIMRoleProvider {
	<#
	.SYNOPSIS
		Lists all registered Role Providers.
	
	.DESCRIPTION
		Lists all registered Role Providers.
		Role Providers are plugins that allow resolving role names using the logic provided within.
	
	.PARAMETER Name
		Name of the Role Provider to retrieve.
		Defaults to '*'
	
	.PARAMETER Enabled
		Only return enabled Role Providers.
	
	.EXAMPLE
		PS C:\> Get-PIMRoleProvider
		
		Lists all registered Role Providers.

	.EXAMPLE
		PS C:\> Get-PIMRoleProvider -Enabled
		
		Lists all enabled Role Providers.
	#>
	[CmdletBinding()]
	Param (
		[string]
		$Name = '*',

		[switch]
		$Enabled
	)

	process {
		$enabledSet = $PSBoundParameters.ContainsKey('Enabled')
		($script:roleProviders.Values) | Where-Object {
			$_.Name -Like $Name -and
			(-not $enabledSet -or $_.Enabled -eq $Enabled)
		}
	}
}