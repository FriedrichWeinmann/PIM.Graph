function Resolve-PIMRole
{
	<#
	.SYNOPSIS
		Resolve a role by ID or name.
	
	.DESCRIPTION
		Resolve a role by ID or name.
		Uses role providers to do the resolving with, some of which are provided out of the box:
		- builtin: Provides the default IDs for the builtin roles (such as Global Administrator)
		- manual: Allows manually mapping name to ID using Set-PIMRoleMapping.
		- Get-PIMRole: Uses Get-PIMRole to retrieve active roles from Azure AD.
		  This requires having the correct scopes and permissions to retrieve them.

		For more details on Role Providers, see the following commands:
		- Get-PIMRoleProvider: List available Role Providers.
		- Set-PIMRoleProvider: Modify existing Role Providers (most notably: Disable or enable)
		- Register-PIMRoleProvider: Create a new Role Provider
		- Unregister-PIMRoleProvider: Remove an existing Role Provider
	
	.PARAMETER Identity
		Role to resolve.
	
	.PARAMETER AsName
		Resolve to name rather than ID.
	
	.PARAMETER Lenient
		In case of not finding anything, return the specified Identity, rather than throwing an exception.
	
	.EXAMPLE
		PS C:\> Resolve-PIMRole -Identity 'Global Administrator'

		Returns the ID of the Global Administrator role.
	#>
	[OutputType([string])]
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true)]
		[string]
		$Identity,

		[switch]
		$AsName,

		[switch]
		$Lenient
	)
	
	begin {
		Assert-EntraConnection -Service $script:entraServices.Graph -Cmdlet $PSCmdlet
	}
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
		if ($Lenient) { return $Identity }
		throw "Unable to resolve $Identity"
	}
}
