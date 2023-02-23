function Invoke-PimGraphRequest {
	[CmdletBinding()]
	param (
		[string]
		$Uri,

		[string]
		$Method = 'GET',

		[hashtable]
		$Body
	)

	$param = @{
		Method = $Method
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
		else {
			if ($result -isnot [Hashtable]) { $result }
			else { [PSCustomObject]$result }
		}
		$nextLink = $result.'@odata.nextlink' -replace '^https://graph.microsoft.com/'
	}
}