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
		User for which to retrieve elevation requests.
		Defaults to the current user.

	.PARAMETER Current
		Only include role activation requests that are currently active.

	.PARAMETER Include
		What requests to include, that would usually not be returned.
		- All: All of the below.
		- Expired: Requests that have already expired. Allows historic searches, as long as data is retained by entra.
		- Revoked: Requests that were active but have been revoked before their natural conclusion.
		- Canceled: Requests that were scheduled in the future and cancelled before taking effect.

	.PARAMETER AllUsers
		Search for requests from all users.

	.PARAMETER RequestID
		Retrieve a specific role request by its ID.
	
	.EXAMPLE
		PS C:\> Get-PIMRoleRequest -User me
		
		Retrieve all requests for the current account.

	.EXAMPLE
		PS C:\> Get-PIMRoleRequest -Role 'Global Administrator'

		Retrieve all requests for Global Admin

	.LINK
		https://learn.microsoft.com/en-us/graph/api/rbacapplication-list-roleeligibilityschedulerequests?view=graph-rest-1.0&tabs=http
	#>
	[CmdletBinding(DefaultParameterSetName = 'Filter')]
	param (
		[Parameter(ParameterSetName = 'Filter')]
		[string]
		$Role,

		[Parameter(ParameterSetName = 'Filter')]
		[string]
		$User = 'me',

		[Parameter(ParameterSetName = 'Filter')]
		[switch]
		$Current,

		[Parameter(ParameterSetName = 'Filter')]
		[ValidateSet('All', 'Expired', 'Revoked', 'Canceled')]
		[string[]]
		$Include,

		[Parameter(ParameterSetName = 'Filter')]
		[switch]
		$AllUsers,

		[Parameter(Mandatory = $true, ParameterSetName = 'ByID')]
		[string]
		$RequestID
	)

	begin {
		Assert-EntraConnection -Service $script:entraServices.Graph -Cmdlet $PSCmdlet
		function Get-ExpirationTime {
			[CmdletBinding()]
			param (
				$ScheduleInfo,

				[switch]
				$Utc
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
			
			if ($Utc) { $end }
			else { $end.ToLocalTime() }
		}

		$includeRevoked = $Include -contains 'All' -or $Include -contains 'Revoked'
		$includeCanceled = $Include -contains 'All' -or $Include -contains 'Canceled'
		$includeExpired = $Include -contains 'All' -or $Include -contains 'Expired'

		$requestParam = @{
			Service = $script:entraServices.Graph
			Path    = "roleManagement/directory/roleAssignmentScheduleRequests"
			Query = @{
				'$expand' = "principal"
			}
		}
		if ($RequestID) {
			$requestParam.Path = "roleManagement/directory/roleAssignmentScheduleRequests/$RequestID"
			return # continues with Process
		}

		$filterSegments = @()
		if ($Role) {
			$roleID = Resolve-PIMRole -Identity $Role
			$filterSegments += "roleDefinitionId eq '$roleID'"
		}
		if ($User -and -not $AllUsers) {
			if ('me' -eq $User) { $userID = Resolve-User -Me }
			else { $userID = Resolve-User -Identity $User }
			$filterSegments += "principalId eq '$userID'"
		}
		
		if ($filterSegments) {
			$requestParam.Query['$filter'] = $filterSegments -join ' and '
		}
	}
	process {
		$requests = Invoke-EntraRequest @requestParam
		foreach ($request in $requests | Sort-Object { $_.ScheduleInfo.startDateTime }) {
			if (-not $includeCanceled -and $request.status -eq 'Canceled' -and -not $RequestID) { continue }
			if (-not $includeRevoked -and -not $RequestID) {
				if ($request.status -eq 'Revoked') { continue }
				$revocation = @($requests).Where{
					$_.status -eq 'Revoked' -and
					$_.principalId -eq $request.principalId -and
					$_.roleDefinitionId -eq $request.roleDefinitionId -and
					$_.scheduleInfo.startDateTime -eq $request.scheduleInfo.startDateTime -and
					$_.scheduleInfo.expiration.duration -eq $request.scheduleInfo.expiration.duration -and
					$_.scheduleInfo.expiration.endDateTime -eq $request.scheduleInfo.expiration.endDateTime
				}
				if ($revocation) { continue }
			}
			$start = $request.scheduleInfo.startDateTime.ToLocalTime()
			$end = Get-ExpirationTime -ScheduleInfo $request.scheduleInfo
			$now = Get-Date
			if ($end -lt $now -and -not $includeExpired -and -not $RequestID) { continue }
			if ($Current -and $start -gt $now) { continue }

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
				Start              = $request.scheduleInfo.startDateTime.ToLocalTime()
				StartUtc           = $request.scheduleInfo.startDateTime
				End                = Get-ExpirationTime -ScheduleInfo $request.scheduleInfo
				EndUtc             = Get-ExpirationTime -ScheduleInfo $request.scheduleInfo -Utc
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