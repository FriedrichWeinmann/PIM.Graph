function Get-PIMRoleRequest {
	[CmdletBinding()]
	param ()

	process {
		$requests = Invoke-PimGraphRequest -Uri 'v1.0/roleManagement/directory/roleAssignmentScheduleRequests?$expand=principal'
		foreach ($request in $requests) {
			[PSCustomObject]@{
				# IDs
				RequestID          = $request.id
				PrincipalID        = $request.principalId
				RoleID             = $request.roleDefinitionId
				
				# State
				Action             = $request.action
				Status             = $request.status

				# Schedule
				Start              = $request.scheduleInfo.startDateTime
				ExpirationType     = $request.scheduleInfo.expiration.type
				ExpirationDuration = $request.scheduleInfo.expiration.duration

				Created            = $request.createdDateTime
				Completed          = $request.completedDateTime

				# Metadata
				Reason             = $request.justification
				TicketNumber       = $request.ticketInfo.ticketNumber
				TicketSystem       = $request.ticketInfo.ticketSystem

				# Principal
				PrincipalType      = $request.principal.'@odata.type' -replace '#microsoft\.graph\.'
				PrincipalName      = $request.principal.displayName
				PrincipalUPN       = $request.principal.userPrincipalName

				Data               = $request
			}
		}
	}
}