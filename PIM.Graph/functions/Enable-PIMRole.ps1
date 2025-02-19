function Enable-PIMRole {
	<#
	.SYNOPSIS
		Activate a temporary Role membership.
	
	.DESCRIPTION
		Activate a temporary Role membership.

		Scopes Needed:
		RoleAssignmentSchedule.ReadWrite.Directory
	
	.PARAMETER Role
		The role to activate.
	
	.PARAMETER TicketNumber
		The ticket number associated with the privilege activation.
	
	.PARAMETER Reason
		The reason you require the role to be activated
	
	.PARAMETER Duration
		For how long the role should be active.
		Must be at least 5 minutes, maximum duration is defined in PIM.
		Defaults to 8 hours.
	
	.PARAMETER StartTime
		When the activation should start.
		Defaults to "now"
	
	.PARAMETER TicketSystem
		What ticket system is associated with the ticket number offered.
		Defaults to 'N/A'
	
	.PARAMETER DirectoryScope
		What scope the the activation applies to.
		Defaults to '/'.
	
	.EXAMPLE
		PS C:\> Enable-PIMRole 'Global Administrator' '#1234' 'Updating global tenant settings.'

		Enables the 'Global Administrator' role for 8 hours.

	.LINK
		https://learn.microsoft.com/en-us/graph/api/rbacapplication-post-roleassignmentschedulerequests?view=graph-rest-1.0&tabs=http
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true)]
		[string]
		$Role,

		[Parameter(Mandatory = $true)]
		[string]
		$TicketNumber,

		[Parameter(Mandatory = $true)]
		[string]
		$Reason,

		[timespan]
		$Duration = "08:00:00",

		[datetime]
		$StartTime = (Get-Date),

		[string]
		$TicketSystem = "N/A",

		[string]
		$DirectoryScope = "/"
	)
	
	begin {
		Assert-EntraConnection -Service $script:entraServices.Graph -Cmdlet $PSCmdlet
	}
	process {
		$resolvedRole = Resolve-PIMRole -Identity $Role
		$body = [ordered]@{
			action           = "selfActivate"
			principalId      = (Invoke-EntraRequest -Service $script:entraServices.Graph -Path "me").id
			roleDefinitionId = $resolvedRole
			directoryScopeId = $DirectoryScope
			justification    = $Reason
			scheduleInfo     = @{
				startDateTime = $StartTime.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
				expiration    = @{
					type     = "AfterDuration"
					duration = "PT$($Duration.TotalMinutes)M"
				}
			}
			ticketInfo       = @{
				ticketNumber = $TicketNumber
				ticketSystem = $TicketSystem
			}
		}
		try { Invoke-EntraRequest -Service $script:entraServices.Graph -Path "roleManagement/directory/roleAssignmentScheduleRequests" -Method POST -Body $body -Header @{ 'Content-Type' = 'application/json' } -ErrorAction Stop }
		catch { $PSCmdlet.ThrowTerminatingError($_) }
	}
}
