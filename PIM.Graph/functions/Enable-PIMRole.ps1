function Enable-PIMRole
{
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory)]
		[string]
		$Role,

		[Parameter(Mandatory)]
		[string]
		$TicketNumber,

		[Parameter(Mandatory)]
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
	
	process
	{
		$body = @{
			action = "SelfActivate"
			principalId = (Invoke-MgGraphRequest -Uri "v1.0/me").id
			roleDefinitionId = $Role
			directoryScopeId = $DirectoryScope
			justification = $Reason
			scheduleInfo = @{
				startDateTime = $StartTime.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
				expiration = @{
					type = "AfterDuration"
					duration = "PT$($Duration.TotalMinutes)M"
				}
			}
			ticketInfo = @{
				ticketNumber = $TicketNumber
				ticketSystem = $TicketSystem
			}
		}
		Invoke-MgGraphRequest -Uri "v1.0/roleManagement/directory/roleAssignmentScheduleRequests" -Method POST -Body $body
	}
	end
	{
	
	}
}
