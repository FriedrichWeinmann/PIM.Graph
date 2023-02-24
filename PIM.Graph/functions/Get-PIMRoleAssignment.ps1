function Get-PIMRoleAssignment {
	# RoleManagement.Read.Directory
	# Not used: EntitlementManagement.Read.All
	# API: https://learn.microsoft.com/en-us/graph/api/rbacapplication-list-roleassignments?view=graph-rest-1.0&tabs=http
	[CmdletBinding()]
	param (
		[string]
		$Role,

		[string]
		$User
	)

	begin {
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
		$results = Invoke-PimGraphRequest -Uri "v1.0/roleManagement/directory/roleAssignments?`$expand=principal$filterString"
		foreach ($result in $results) {
			[PSCustomObject]@{
				# General Info
				RoleID         = $result.roleDefinitionId
				PrincipalID    = $result.principalId
				DirectoryScope = $result.directoryScopeId

				# Principal Details
				PrincipalName  = $result.principal.displayName
				PrincipalType  = $result.principal.'@odata.type' -replace '#microsoft\.graph\.'

				# Assignment data
				AssignmentID   = $result.id
				Principal      = $result.principal
			}
		}
	}
}