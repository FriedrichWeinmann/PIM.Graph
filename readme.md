# PIM.Graph

Welcome to a lightweight client module to manage temporary role activations in Entra via PowerShell.
This allows you to conveniently activate roles when needed and cancel them once done.

## Installing

To install this module, run the following command:

```powershell
Install-Module PIM.Graph -Scope CurrentUser
```

## Profit

> Connect

This module uses [EntraAuth](https://github.com/FriedrichWeinmann/EntraAuth) to authenticate and interact with Microsoft Graph.
To connect, run the following line:

```powershell
$scopes = 'User.ReadBasic.All','RoleAssignmentSchedule.ReadWrite.Directory','RoleEligibilitySchedule.ReadWrite.Directory','RoleManagement.Read.All'
Connect-EntraService -ClientID 14d82eec-204b-4c2f-b7e8-296a70dab67e -Scopes $scopes
```

This uses the same default application used by the `Microsoft.Graph` module.
If this has been blocked in your organization, [here's some guidance on how to set up your own application instead](https://github.com/FriedrichWeinmann/EntraAuth/blob/master/docs/overview.md).

> Enable a Role

Here's a quick example that will the `Security Reader` role for your account for 15 minutes:

```powershell
Enable-PIMRole -Role 'Security Reader' -TicketNumber 1234 -Reason Watever -Duration '00:15:00'
```

> Disable a Role

And this is how you cancel it once done:

```powershell
Disable-PIMRole -Role 'Security Reader'
```

Note: It is not possible to cancel requests that have been active for less than 5 minutes.

> Check your Role Assignments

To list your role memberships, this simple command will do:

```powershell
Get-PIMRoleAssignment
```

> Check your open role activations

To list what you have currently enabled, run this line:

```powershell
Get-PIMRoleRequest
```
