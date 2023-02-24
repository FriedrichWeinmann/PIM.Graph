function Stop-PIMRoleRequest {
	<#
	.SYNOPSIS
		Cancels a pending role request.
	
	.DESCRIPTION
		Cancels a pending role request.

		Scopes needed (least to most privileged):
		RoleEligibilitySchedule.ReadWrite.Directory, RoleManagement.ReadWrite.Directory
	
	.PARAMETER ID
		ID of the request to cancel.
	
	.EXAMPLE
		PS C:\> Get-PIMRoleRequest -User me | Where-Object Status -eq Granted | Stop-PIMRoleRequest
		
		Cancels all role requests still pending for the current user

	.LINK
		https://learn.microsoft.com/en-us/graph/api/unifiedroleeligibilityschedulerequest-cancel?view=graph-rest-1.0&tabs=http
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('RequestID')]
		[string[]]
		$ID
	)

	process {
		foreach ($requestID in $ID) {
			try { Invoke-PimGraphRequest -Method POST -Uri "v1.0/roleManagement/directory/roleAssignmentScheduleRequests/$requestID/cancel" -ErrorAction Stop }
			catch { $PSCmdlet.WriteError($_) }
		}
	}
}