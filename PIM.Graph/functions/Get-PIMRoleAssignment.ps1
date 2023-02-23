function Get-PIMRoleAssignment {
	[CmdletBinding()]
	param (

	)

	process {
		$results = Invoke-PimGraphRequest -Uri 'v1.0/roleManagement/directory/roleAssignments?$expand=principal'
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