function Unregister-PIMRoleProvider {
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