function Get-PIMRoleRequest {
	<#
	.SYNOPSIS
		Retrieve previously submitted role elevation requests.
	
	.DESCRIPTION
		Retrieve previously submitted role elevation requests.
		Returns both requests created in the Portal and those created by commandline.

		Scopes needed (least to most privileged):
		RoleEligibilitySchedule.Read.Directory, RoleManagement.Read.Directory, RoleManagement.Read.All, RoleEligibilitySchedule.ReadWrite.Directory, RoleManagement.ReadWrite.Directory
	
	.PARAMETER Role
		Role for which to retrieve elevation requests.
	
	.PARAMETER User
		User for which to retrieve elevation requests
	
	.EXAMPLE
		PS C:\> Get-PIMRoleRequest -User me
		
		Retrieve all requests for the current account.

	.EXAMPLE
		PS C:\> Get-PIMRoleRequest -Role 'Global Administrator'

		Retrieve all requests for Global Admin

	.LINK
		https://learn.microsoft.com/en-us/graph/api/rbacapplication-list-roleeligibilityschedulerequests?view=graph-rest-1.0&tabs=http
	#>
	[CmdletBinding()]
	param (
		[string]
		$Role,

		[string]
		$User
	)

	begin {
		function Get-ExpirationTime {
			[CmdletBinding()]
			param (
				$ScheduleInfo
			)

			if ($ScheduleInfo.expiration.endDateTime) {
				return $ScheduleInfo.expiration.endDateTime
			}

			$start = $ScheduleInfo.startDateTime
			$duration = $ScheduleInfo.expiration.duration -replace '^PT'
			$end = $start
			$minutes = $duration -replace '^.{0,}?(\d+)M.{0,}$', '$1'
			if ($minutes -and $minutes -ne $duration) { $end = $end.AddMinutes($minutes) }
			$hours = $duration -replace '^.{0,}?(\d+)H.{0,}$', '$1'
			if ($hours -and $hours -ne $duration) { $end = $end.AddHours($hours) }
			$end
		}

		$filterSegments = @()
		if ($Role) {
			$roleID = Resolve-PIMRole -Identity $Role
			$filterSegments += "roleDefinitionId eq '$roleID'"
		}
		if ($User) {
			if ('me' -eq $User) { $userID = Resolve-User -Me }
			else { $userID = Resolve-User -Identity $User }
			$filterSegments += "principalId eq '$userID'"
		}
		$filterString = ''
		if ($filterSegments) {
			$filterString = '&$filter={0}' -f ($filterSegments -join ' and ')
		}
	}
	process {
		$requests = Invoke-PimGraphRequest -Uri "roleManagement/directory/roleAssignmentScheduleRequests?`$expand=principal$($filterString)"
		foreach ($request in $requests) {
			[PSCustomObject]@{
				PSTypeName         = 'PIM.Graph.RoleRequest'

				# IDs
				RequestID          = $request.id
				PrincipalID        = $request.principalId
				RoleID             = $request.roleDefinitionId
				
				# State
				Action             = $request.action
				Status             = $request.status

				# Schedule
				Start              = $request.scheduleInfo.startDateTime
				End                = Get-ExpirationTime -ScheduleInfo $request.scheduleInfo
				ExpirationType     = $request.scheduleInfo.expiration.type
				ExpirationDuration = $request.scheduleInfo.expiration.duration
				ExpirationTime     = $request.scheduleInfo.expiration.endDateTime

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

				# Role
				Role               = Resolve-PIMRole -Identity $request.roleDefinitionId -AsName -Lenient

				Data               = $request
			}
		}
	}
}