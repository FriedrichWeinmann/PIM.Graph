function Get-PIMRoleAssignment {
	<#
	.SYNOPSIS
		Retrieve permanent role assignments.
	
	.DESCRIPTION
		Retrieve permanent role assignments.

		Scopes Needed: RoleManagement.Read.Directory
	
	.PARAMETER Role
		Role for which to find assignees.
	
	.PARAMETER User
		User for which to retrieve assignments.
		Specify either "me" for the current user or UPN/mail of specific user.

	.PARAMETER AllUsers
		Retrieve all assignments for all users.
	
	.EXAMPLE
		PS C:\> Get-PIMRoleAssignment

		Retrieve ALL role assignments.

	.EXAMPLE
		PS C:\> Get-PIMRoleAssignment -User me

		Retrieve all role assignments of the current user.

	.EXAMPLE
		PS C:\> Get-PIMRoleAssignment -Role 'Global Administrator'

		Retrieve all memberships in the 'Global Administrator' role.

	.LINK
		https://learn.microsoft.com/en-us/graph/api/rbacapplication-list-roleassignments?view=graph-rest-1.0&tabs=http
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingEmptyCatchBlock", "")]
	[CmdletBinding()]
	param (
		[string]
		$Role,

		[string]
		$User = 'me',

		[switch]
		$AllUsers
	)

	begin {
		Assert-EntraConnection -Service $script:entraServices.Graph -Cmdlet $PSCmdlet

		$typeMap = @{
			$true  = 'Temporary'
			$false = 'Permanent'
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
		$queryHash = @{
			'$expand' = "principal"
		}
		if ($filterSegments) {
			$queryHash['$filter'] = $filterSegments -join ' and '
		}
	}
	process {
		$active = Invoke-EntraRequest -Service $script:entraServices.Graph -Path "roleManagement/directory/roleAssignments" -Query $queryHash
		$eligible = Invoke-EntraRequest -Service $script:entraServices.Graph -Path "roleManagement/directory/roleEligibilitySchedules" -Query $queryHash
		$roleHash = @{ }
		try {
			$roles = Get-PIMRole -ErrorAction Stop
			foreach ($roleItem in $roles) { $roleHash[$roleItem.templateId] = $roleItem }
		}
		catch { }

		foreach ($assignment in $active) {
			$eligibleItem = @($eligible).Where{
				$_.principalId -eq $assignment.principalId -and
				$_.roleDefinitionId -eq $assignment.roleDefinitionId -and
				$_.directoryScopeId -eq $assignment.directoryScopeId
			}

			[PSCustomObject]@{
				PSTypeName     = 'PIM.Graph.RoleAssignment'
				# General Info
				RoleID         = $assignment.roleDefinitionId
				RoleName       = $roleHash[$assignment.roleDefinitionId].displayName
				PrincipalID    = $assignment.principalId
				DirectoryScope = $assignment.directoryScopeId
				Type           = $typeMap[($eligibleItem -as [bool])]

				# Principal Details
				PrincipalName  = $assignment.principal.displayName
				PrincipalType  = $assignment.principal.'@odata.type' -replace '#microsoft\.graph\.'

				# Assignment data
				AssignmentID   = $assignment.id
				EligibilityID  = $eligibleItem.id
				Principal      = $assignment.principal
			}
		}

		foreach ($assignment in $eligible) {
			$activeItem = @($active).Where{
				$_.principalId -eq $assignment.principalId -and
				$_.roleDefinitionId -eq $assignment.roleDefinitionId -and
				$_.directoryScopeId -eq $assignment.directoryScopeId
			}
			if ($activeItem) { continue }

			[PSCustomObject]@{
				PSTypeName     = 'PIM.Graph.RoleAssignment'
				# General Info
				RoleID         = $assignment.roleDefinitionId
				RoleName       = $roleHash[$assignment.roleDefinitionId].displayName
				PrincipalID    = $assignment.principalId
				DirectoryScope = $assignment.directoryScopeId
				Type           = 'Eligible'

				# Principal Details
				PrincipalName  = $assignment.principal.displayName
				PrincipalType  = $assignment.principal.'@odata.type' -replace '#microsoft\.graph\.'

				# Assignment data
				AssignmentID   = $null
				EligibilityID  = $assignment.id
				Principal      = $assignment.principal
			}
		}
	}
}