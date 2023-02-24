﻿function Resolve-User {
	<#
	.SYNOPSIS
		Resolves a user into an ID
	
	.DESCRIPTION
		Resolves a user into an ID
	
	.PARAMETER Identity
		ID or UPN or mail of the user to resolve.
	
	.PARAMETER Me
		Whether to retrieve the ID of the current user.
	
	.EXAMPLE
		PS C:\> Resolve-User -Me

		Retrieve the ID of the current user

	.EXAMPLE
		PS C:\> Resolve-User -Identity max.mustermann@contoso.com

		Retrieve the ID of max.mustermann@contoso.com
	#>
	[OutputType([string])]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
		[string]
		$Identity,

		[Parameter(Mandatory = $true, ParameterSetName = 'Me')]
		[switch]
		$Me
	)

	process {
		if ($Me) {
			try { (Invoke-PimGraphRequest -Uri 'me' -ErrorAction Stop).Id }
			catch { $PSCmdlet.ThrowTerminatingError($_) }
			return
		}

		if ($Identity -as [guid]) {
			return $Identity
		}

		try { $user = Invoke-PimGraphRequest -Uri "users?`$select=id&`$filter=userPrincipalName eq '$Identity' or mail eq '$Identity'" -ErrorAction Stop }
		catch { $PSCmdlet.ThrowTerminatingError($_) }

		if (-not $user) { throw "User not found: $user" }
		$user.id
	}
}