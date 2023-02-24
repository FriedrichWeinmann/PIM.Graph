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