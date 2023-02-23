function Get-PIMRole
{
	[CmdletBinding()]
	Param (
	
	)
	
	begin
	{
		
	}
	process
	{
		Invoke-MgGraphRequest -Uri "v1.0/"
	}
	end
	{
	
	}
}
