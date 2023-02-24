function Register-PIMRoleProvider {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Name,

		[Parameter(Mandatory = $true)]
		[scriptblock]
		$Conversion,

		[Parameter(Mandatory = $true)]
		[scriptblock]
		$ListNames,

		[int]
		$Priority = 50,

		[bool]
		$Enabled = $true
	)

	$script:roleProviders[$Name] = [PSCustomObject]@{
		PSTypeName = 'PIM.Graph.RoleProvider'
		Name       = $Name
		Conversion = $Conversion
		ListNames  = $ListNames
		Priority   = $Priority
		Enabled    = $Enabled
	}
}