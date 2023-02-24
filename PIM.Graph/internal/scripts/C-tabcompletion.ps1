#region Role Names
$completion = {
	param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

	$providers = Get-PIMRoleProvider -Enabled
	$names = foreach ($provider in $providers) {
		& $provider.ListNames
	}
	$names | Sort-Object -Unique | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
		if ($_ -match "\s") { "'$_'" }
		else { $_ }
	}
}
Register-ArgumentCompleter -CommandName Resolve-PIMRole -ParameterName Identity -ScriptBlock $completion
Register-ArgumentCompleter -CommandName Enable-PIMRole -ParameterName Role -ScriptBlock $completion
Register-ArgumentCompleter -CommandName Get-PIMRoleAssignment -ParameterName Role -ScriptBlock $completion
#endregion Role Names

#region Role Provider
$completion = {
	param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

	(Get-PIMRoleProvider -Name "$wordToComplete*").Name | ForEach-Object {
		if ($_ -match "\s") { "'$_'" }
		else { $_ }
	}
}
Register-ArgumentCompleter -CommandName Get-PIMRoleProvider -ParameterName Name -ScriptBlock $completion
Register-ArgumentCompleter -CommandName Set-PIMRoleProvider -ParameterName Name -ScriptBlock $completion
Register-ArgumentCompleter -CommandName Unregister-PIMRoleProvider -ParameterName Name -ScriptBlock $completion
#endregion Role Provider