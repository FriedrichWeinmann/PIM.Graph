function Register-PIMRoleProvider {
	<#
	.SYNOPSIS
		Register a new Role Provider.
	
	.DESCRIPTION
		Register a new Role Provider.
		Role Providers are plugins that allow resolving role names using the logic provided within.
	
	.PARAMETER Name
		Name of the provider to create.
		Must be unique, otherwise it will overwrite an existing Provider.
	
	.PARAMETER Conversion
		Logic that processes input into results.
		The scriptblock must accept two parameters:
		- Identity
		- AsName
		Identity is the string input to convert.
		AsName is a boolean, whether to return the displayname of a role.
		By default, this scriptblock should be returning the ID.
	
	.PARAMETER ListNames
		A logic that, without any input, should return a list of role names.
		This is used for tab completion and you may leave this empty.
		Try to avoid including long-running logic or implement caching.
	
	.PARAMETER Description
		Description of the Role Provider.
		Used to give the user some impression of what and how it does.
	
	.PARAMETER Priority
		The priority of the Role Provider.
		The lower the number, the earlier it is executed.
		The first successful role resolution wins, causing Role Providers with a higher number to be skipped.
		Slower Role Providers should usually have a higher number.
		Defaults to 50.
	
	.PARAMETER Enabled
		Whether the Role Provider should be enabled.
		Only enabled Providers are used when resolving a role.
		Defaults to $true
	
	.EXAMPLE
		PS C:\> Resolve-PIMRoleProvider -Name 'custom-DB' -Conversion $conversion -ListNames { } -Priority 40
		
		Registers the 'custom-DB' Role Provider with the specified conversion logic, an empty name listing logic and priority 40.
	#>
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

		[string]
		$Description,

		[int]
		$Priority = 50,

		[bool]
		$Enabled = $true
	)

	$script:roleProviders[$Name] = [PSCustomObject]@{
		PSTypeName  = 'PIM.Graph.RoleProvider'
		Name        = $Name
		Conversion  = $Conversion
		ListNames   = $ListNames
		Priority    = $Priority
		Enabled     = $Enabled
		Description = $Description
	}
}