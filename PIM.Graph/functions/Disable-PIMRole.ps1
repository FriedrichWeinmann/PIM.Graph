function Disable-PIMRole {
	<#
	.SYNOPSIS
		Disables / cancels a role membership activation.
	
	.DESCRIPTION
		Disables / cancels a role membership activation.

		Already active memberships must have been active for at least 5 minutes before being cancelled.
	
	.PARAMETER Role
		Name of the role, whose membership you want to disable again.
		Only applies to the current user.
	
	.PARAMETER RequestId
		Specific ID of the request that activated an eligible role membership.
		Can be from any role or user.
	
	.EXAMPLE
		PS C:\> Disable-PIMRole -Role 'Security Reader'

		Deactivates temporary role memberships of the current user and the role "Security Reader".

	.EXAMPLE
		PS C:\> Get-PIMRoleRequest -User example@contoso.onmicrosoft.com | Disable-PIMRole

		Deactivates all temporary role memberships active for example@contoso.onmicrosoft.com
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true, ParameterSetName = 'ByRole')]
		[string]
		$Role,

		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByID')]
		[string]
		$RequestId
	)
	
	begin {
		Assert-EntraConnection -Service $script:entraServices.Graph -Cmdlet $PSCmdlet
	}
	process {
		if ($Role) {
			$requests = Get-PIMRoleRequest -Role $Role -User me -ErrorAction $ErrorActionPreference | Where-Object Action -eq 'selfActivate'
		}
		else {
			$requests = Get-PIMRoleRequest -RequestID $RequestID -ErrorAction $ErrorActionPreference
		}
		if (-not $requests) { return }

		foreach ($request in $requests) {
			if ($request.Action -ne 'selfActivate') {
				Write-Error "Only revoking privilege requests. $($request.RequestID): $($request.Action)" -TargetObject $request
				continue
			}

			# Case: Request Scheduled for the future
			if ($request.Status -eq 'Granted') {
				try { $null = Invoke-EntraRequest -Service $script:entraServices.Graph -Method POST -Path "roleManagement/directory/roleAssignmentScheduleRequests/$($request.RequestID)/cancel" -ErrorAction Stop }
				catch { $PSCmdlet.WriteError($_) }
				continue
			}

			# Case: Active Request Schedule
			$limit = (Get-Date).AddMinutes(-5)
			if ($request.Start -ge $limit) {
				Write-Error "Cannot cancel a request that has been open less than 5 minutes! $($request.Role) | $($request.Start)"
				continue
			}

			$body = [ordered]@{
				action           = "selfDeactivate"
				principalId      = $request.PrincipalID
				roleDefinitionId = $request.RoleID
				directoryScopeId = $request.Data.directoryScopeId
				scheduleInfo     = $request.Data.scheduleInfo
			}
			try { Invoke-EntraRequest -Service $script:entraServices.Graph -Path "roleManagement/directory/roleAssignmentScheduleRequests" -Method POST -Body $body -Header @{ 'Content-Type' = 'application/json' } -ErrorAction Stop }
			catch { $PSCmdlet.WriteError($_) }
		}
	}
}