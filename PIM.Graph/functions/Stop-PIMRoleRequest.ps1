function Stop-PIMRoleRequest {
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