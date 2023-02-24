function Set-PIMRoleProvider {
	<#
	.SYNOPSIS
		Modifies an existing Role Provider.
	
	.DESCRIPTION
		Modifies an existing Role Provider.
		Role Providers are plugins that allow resolving role names using the logic provided within.
	
	.PARAMETER Name
		Name of the Provider to modify.
	
	.PARAMETER Conversion
		The conversion logic that reslves names to ID.
	
	.PARAMETER ListNames
		The logic listing all available names for tab completion purposes.
	
	.PARAMETER Priority
		The priority of the Role Provider.
		The lower the number, the earlier it is executed.
		The first successful role resolution wins, causing Role Providers with a higher number to be skipped.
		Slower Role Providers should usually have a higher number.
	
	.PARAMETER Enabled
		Whether the Role Provider should be enabled.
		Only enabled Providers are used when resolving a role.
	
	.EXAMPLE
		PS C:\> Set-PIMRoleProvider -Name Get-PIMRole -Enabled $false

		Disables the Role Provider 'Get-PIMRole'
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[string[]]
		$Name,

		[scriptblock]
		$Conversion,

		[scriptblock]
		$ListNames,

		[int]
		$Priority,

		[bool]
		$Enabled
	)
	
	process {
		foreach ($providerName in $Name) {
			$provider = $script:roleProviders[$providerName]
			if (-not $provider) {
				Write-Error "Provider not found: $providerName"
				continue
			}

			if ($Conversion) { $provider.Conversion = $Conversion }
			if ($ListNames) { $provider.ListNames = $ListNames }
			if ($PSBoundParameters.ContainsKey('Priority')) { $provider.Priority = $Priority }
			if ($PSBoundParameters.ContainsKey('Enabled')) { $provider.Enabled = $Enabled }
		}
	}
}
