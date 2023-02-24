function Set-PIMRoleMapping {
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
