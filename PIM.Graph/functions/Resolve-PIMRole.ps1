function Resolve-PIMRole
{
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true)]
		[string]
		$Identity,

		[switch]
		$AsName
	)
	
	process
	{
		# If no resolution is required and ID is provided, return ID
		if (-not $AsName -and $Identity -as [Guid]) { return $Identity }

		$providers = Get-PIMRoleProvider -Enabled | Sort-Object Priority
		foreach ($provider in $providers) {
			Write-Verbose "Resolving $Identity through $($provider.Name)"
			try {
				$result = & $provider.Conversion $Identity $AsName
				if ($result) { return $result }
			}
			catch {
				Write-Verbose "Error resolving $Identity through $($provider.Name): $_"
			}
		}
		throw "Unable to resolve $Identity"
	}
}
