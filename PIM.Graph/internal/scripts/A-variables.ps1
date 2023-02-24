# Registered role providers, logic resolving and listing roles
$script:roleProviders = @{ }

# Roles that come with every tenant. Their roleTemplateId is global across all tenants.
$script:defaultBuiltinRoles = @{
	'62e90394-69f5-4237-9190-012177145e10' = 'Global Administrator'
	'd29b2b05-8046-44ba-8758-1e26182fcf32' = 'Directory Synchronization Accounts'
	'88d8e3e3-8f55-4a1e-953a-9b9898b8876b' = 'Directory Readers'
	'e6d1a23a-da11-4be4-9570-befc86d067a7' = 'Compliance Data Administrator'
	'f28a1f50-f6e7-4571-818b-6a12f2af6b6c' = 'SharePoint Administrator'
	'5d6b6bb7-de71-4623-b4af-96380a352509' = 'Security Reader'
	'69091246-20e8-4a56-aa4d-066075b2a7a8' = 'Teams Administrator'
	'f70938a0-fc10-4177-9e90-2178f8765737' = 'Teams Communications Support Engineer'
	'2b499bcd-da44-4968-8aec-78e1674fa64d' = 'Device Managers'
	'194ae4cb-b126-40b2-bd5b-6091b380977d' = 'Security Administrator'
	'baf37b3a-610e-45da-9e62-d9d1e5e8914b' = 'Teams Communications Administrator'
	'17315797-102d-40b4-93e0-432062caca18' = 'Compliance Administrator'
	'f2ef992c-3afb-46b9-b7cf-a126ee74c451' = 'Global Reader'
	'29232cdf-9323-42fd-ade2-1d097af3e4de' = 'Exchange Administrator'
	'a9ea8996-122f-4c74-9520-8edcd192826c' = 'Power BI Administrator'
	'9360feb5-f418-4baa-8175-e2a00bac4301' = 'Directory Writers'
}

# Mapping of manually defined roles
$script:manuallyMappedRoles = @{ }
$manualRolesPath = Join-Path $env:APPDATA 'PowerShell/PIM.Graph/roles.clixml'
if (Test-Path $manualRolesPath) {
	try { $script:manuallyMappedRoles = Import-Clixml -Path $manualRolesPath -ErrorAction Stop }
	catch { Write-Warning "Error loading roles mapping configuration file. File may be corrupt. Delete or repair the file. Path: $manualRolesPath" }
}