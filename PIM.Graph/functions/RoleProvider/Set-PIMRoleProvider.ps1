function Set-PIMRoleProvider {
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
