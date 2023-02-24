function Get-PIMRoleProvider {
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