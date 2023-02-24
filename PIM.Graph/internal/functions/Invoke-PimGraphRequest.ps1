function Invoke-PimGraphRequest {
	<#
	.SYNOPSIS
		Execute a graph request.
	
	.DESCRIPTION
		Execute a graph request.
		Wrapper command around Invoke-MgGraphRequest with better output processing.
	
	.PARAMETER Uri
		Relative link to call.
		Passed through to Invoke-MgGraphRequest.
		If no 'beta' or 'v1.0' prefix is used, it automatically injects 'v1.0'
	
	.PARAMETER Method
		What REST Method to call.
		Defaults to GET.
	
	.PARAMETER Body
		A body to pass to the request.
	
	.EXAMPLE
		PS C:\> Invoke-PimGraphRequest me

		Retrieves information about the current user.
	#>
	[CmdletBinding()]
	param (
		[string]
		$Uri,

		[string]
		$Method = 'GET',

		[hashtable]
		$Body
	)

	if ($Uri -notmatch '^v1.0/|^beta/') {
		$Uri = 'v1.0/{0}' -f $Uri
	}

	$param = @{
		Method = $Method
		ErrorAction = 'Stop'
	}
	if ($Body) { $param.Body = $Body }

	$nextLink = $Uri
	while ($nextLink) {
		$result = Invoke-MgGraphRequest @param -Uri $nextLink
		if ($result.value) {
			foreach ($entry in $result.value) {
				if ($entry -isnot [hashtable]) { $entry }
				else { [PSCustomObject]$entry }
			}
		}
		elseif ($result.Keys.Count -eq 2 -and $result.Keys -contains 'value') {
			# Do nothing, there are no results
		}
		else {
			if ($result -isnot [Hashtable]) { $result }
			else { [PSCustomObject]$result }
		}
		$nextLink = $result.'@odata.nextlink' -replace '^https://graph.microsoft.com/'
	}
}