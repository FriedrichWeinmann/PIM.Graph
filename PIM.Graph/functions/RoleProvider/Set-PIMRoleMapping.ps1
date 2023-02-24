function Set-PIMRoleMapping {
	<#
	.SYNOPSIS
		Maps a role name to a role ID.
	
	.DESCRIPTION
		Maps a role name to a role ID.
		This allows manually defining how a name should be resolved, enabling ...
		- Role resolution without any scopes / connection required.
		- Defining aliases / shortcuts for frequently resolved roles
	
	.PARAMETER Name
		Name of the role.
		May either be the full name or an abbreviation as desired.
	
	.PARAMETER ID
		ID the name maps to.
	
	.PARAMETER Register
		Whether the mapping should be remembered across sessions.
	
	.EXAMPLE
		PS C:\> Set-PIMRoleMapping -Name GA -ID 62e90394-69f5-4237-9190-012177145e10 -Register
		
		Creates a permanent role name alias for the Global Administrator
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true)]
		[string]
		$Name,

		[Parameter(Mandatory = $true)]
		[string]
		$ID,

		[switch]
		$Register
	)
	
	process {
		$script:manuallyMappedRoles[$ID] = $Name

		if (-not $Register) { return }

		$folder = Join-Path $env:APPDATA 'PowerShell/PIM.Graph'
		if (-not (Test-Path -Path $folder)) {
			$null = New-Item -Path $folder -Force -ItemType Directory
		}

		$rolesPath = "$folder/roles.clixml"
		if (Test-Path -Path $rolesPath) {
			$roles = Import-Clixml -Path $rolesPath
		}
		else {
			$roles = @{ }
		}
		$roles[$ID] = $Name
		$roles | Export-Clixml -Path $rolesPath
	}
}
